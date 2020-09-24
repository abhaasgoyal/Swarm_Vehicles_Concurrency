--
-- Jan & Uwe R. Zimmer, Australia, 2013
--

with Ada.Containers;                    use Ada.Containers;
with Ada.Numerics;                      use Ada.Numerics;
with Ada.Numerics.Float_Random;         use Ada.Numerics.Float_Random;
with Ada.Real_Time;                     use Ada.Real_Time;
with Ada.Text_IO;                       use Ada.Text_IO;
with Graphics_Configuration;            use Graphics_Configuration;
with Rotations;                         use Rotations;
with Swarm_Data;                        use Swarm_Data;
with Vectors_Conversions;               use Vectors_Conversions;
with Vectors_3D_LF;                     use Vectors_3D_LF;
with Vehicle_Message_Type;              use Vehicle_Message_Type;
with Vehicle_Task_Type;                 use Vehicle_Task_Type;

package body Swarm_Control is

   use Real_Elementary_Functions;
   use Swarm_Vectors;

   protected body Swarm_Monitor is

      function Id_Task return Swarm_Element_Index is

      begin
         for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
            if Element (Swarm_State, Element_Index).Process_Id = Current_Task then
               return (Element_Index);
            end if;
         end loop;
         raise No_Such_Task;
      end Id_Task;

      function Id_Task (Id : Task_Id) return Swarm_Element_Index is

      begin
         for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
            if Element (Swarm_State, Element_Index).Process_Id = Id then
               return (Element_Index);
            end if;
         end loop;
         raise No_Such_Task;
      end Id_Task;

      function Position (Id : Task_Id) return Protected_Point_3D.Monitor_Ptr is
         (Element (Swarm_State, Swarm_Monitor.Id_Task (Current_Task)).Position);

      function Velocity (Id : Task_Id) return Protected_Vector_3D.Monitor_Ptr is
         (Element (Swarm_State, Swarm_Monitor.Id_Task (Current_Task)).Velocity);

      function Acceleration (Id : Task_Id) return Protected_Vector_3D.Monitor_Ptr is
        (Element (Swarm_State, Swarm_Monitor.Id_Task (Current_Task)).Acceleration);

      function Controls (Id : Task_Id) return Vehicle_Controls_P is
         (Element (Swarm_State, Swarm_Monitor.Id_Task (Current_Task)).Controls);

      function Comms (Id : Task_Id) return Vehicle_Comms_P is
        (Element (Swarm_State, Swarm_Monitor.Id_Task (Current_Task)).Comms);

      function Charge (Id : Task_Id) return Charge_Info is
        (Element (Swarm_State, Swarm_Monitor.Id_Task (Current_Task)).Charge);

      function Process_abort return Barrier_Ptr is
        (Element (Swarm_State, Swarm_Monitor.Id_Task).Process_abort);
      --
      --
      --

      procedure Append_Random_Swarm (No_Of_Swarm_Elements : Positive  := Initial_No_of_Elements;
                                     Centre               : Positions := Initial_Swarm_Position;
                                     Volume_Edge_Length   : Real      := Initual_Edge_Length) is

         Random_Float : Generator;

      begin
         Reset (Random_Float);
         Reserve_Capacity (Swarm_State, Length (Swarm_State) + Count_Type (No_Of_Swarm_Elements));
         for i in 1 .. No_Of_Swarm_Elements loop
            select
               pragma Warnings (Off, "potentially blocking operation in protected operation");
               delay Tolerated_Vehicle_Activation_Delay;
               pragma Warnings (On,  "potentially blocking operation in protected operation");
               raise Vehicle_could_not_be_created;
            then abort
               declare
                  New_Element : Swarm_Element_State :=
                    (Position      => Protected_Point_3D.Allocate
                       ((Centre (x) + (Real (Random (Random_Float)) * Volume_Edge_Length) - Volume_Edge_Length / 2.0,
                         Centre (y) + (Real (Random (Random_Float)) * Volume_Edge_Length) - Volume_Edge_Length / 2.0,
                         Centre (z) + (Real (Random (Random_Float)) * Volume_Edge_Length) - Volume_Edge_Length / 2.0)),
                     Rotation      => Protected_Rotation.Allocate (Zero_Rotation),
                     Velocity      => Protected_Vector_3D.Allocate (Zero_Vector_3D),
                     Acceleration  => Protected_Vector_3D.Allocate (Zero_Vector_3D),
                     Charge        => (Level => Full_Charge, Charge_Time => Protected_Time.Allocate (Clock), Charge_No => 0, Globes_Touched => No_Globes_Touched),
                     Neighbours    => new Distance_Vectors.Vector,
                     Controls      => new Vehicle_Controls,
                     Comms         => new Vehicle_Comms,
                     Process       => new Vehicle_Task,
                     Process_abort => new Barrier,
                     Process_Id    => Null_Task_Id,
                     Vehicle_Id    => Natural'Succ (Last_Vehicle_Id),
                     Last_Update   => Clock);
               begin
                  Last_Vehicle_Id := New_Element.Vehicle_Id;
                  pragma Warnings (Off, "potentially blocking operation in protected operation");
                  -- Freshly created vehicle tasks need to respond to this call.
                  select
                     New_Element.Process.all.Identify (New_Element.Vehicle_Id, New_Element.Process_Id);
                  or delay Tolerated_Identify_Call_Delay;
                     raise Task_did_not_repond_to_Identfiy_Call;
                  end select;
                  pragma Warnings (On,  "potentially blocking operation in protected operation");
                  Append (Swarm_State, New_Element);
               end;
            end select;
         end loop;
      end Append_Random_Swarm;

      --
      --
      --

      procedure Remove_Vehicle (Element_Ix : Swarm_Element_Index) is

      begin
         if Length (Swarm_State) > 1 and then Element_Ix >= First_Index (Swarm_State) and then Element_Ix <= Last_Index (Swarm_State) then
            declare
               This_Element : Swarm_Element_State := Element (Swarm_State, Element_Ix);
            begin
               Free_Process             (This_Element.Process);
               Free                     (This_Element.Process_abort);
               Free_Neighbours          (This_Element.Neighbours);
               Free_Comms               (This_Element.Comms);
               Free_Controls            (This_Element.Controls);
               Protected_Time.Free      (This_Element.Charge.Charge_Time);
               Protected_Point_3D.Free  (This_Element.Position);
               Protected_Rotation.Free  (This_Element.Rotation);
               Protected_Vector_3D.Free (This_Element.Velocity);
               Protected_Vector_3D.Free (This_Element.Acceleration);
               Delete (Swarm_State, Element_Ix);
            end;
         end if;
      end Remove_Vehicle;

      --
      --
      --

      function Centre_Of_Gravity return Vector_3D is

         Acc_Positions : Vector_3D_LF := Zero_Vector_3D_LF;

      begin
         for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
            Acc_Positions := Acc_Positions + To_Vector_3D_LF (Element (Swarm_State, Element_Index).Position.all.Read);
         end loop;
         return To_Vector_3D ((1.0 / Long_Float (Length (Swarm_State))) * Acc_Positions);
      end Centre_Of_Gravity;

      --
      --
      --

      function Mean_Velocity return Vector_3D is

         Acc_Velocity : Vector_3D_LF := Zero_Vector_3D_LF;

      begin
         for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
            Acc_Velocity := Acc_Velocity + To_Vector_3D_LF (Element (Swarm_State, Element_Index).Velocity.all.Read);
         end loop;
         return To_Vector_3D ((1.0 / Long_Float (Length (Swarm_State))) * Acc_Velocity);
      end Mean_Velocity;

      --
      --
      --

      function Mean_Velocity return Real is

         Acc_Velocity : Real := 0.0;

      begin
         for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
            Acc_Velocity := Acc_Velocity + Real (abs (To_Vector_3D_LF (Element (Swarm_State, Element_Index).Velocity.all.Read)));
         end loop;
         return Real (Acc_Velocity / Real (Length (Swarm_State)));
      end Mean_Velocity;

      --
      --
      --

      function Maximal_Radius return Real is

         CoG    : constant Vector_3D := Centre_Of_Gravity;

         Radius : Real := 0.0;

      begin
         for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
            declare
               Distance_from_CoG : constant Real := abs (CoG - Element (Swarm_State, Element_Index).Position.all.Read);
            begin
               Radius := Real'Max (Radius, Distance_from_CoG);
            end;
         end loop;
         return Radius;
      end Maximal_Radius;

      --
      --
      --

      function Mean_Radius return Real is

         CoG : constant Vector_3D := Centre_Of_Gravity;

         Acc_Radius : Real := 0.0;

      begin
         for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
            declare
               Distance_from_CoG : constant Real := abs (CoG - Element (Swarm_State, Element_Index).Position.all.Read);
            begin
               Acc_Radius := Acc_Radius + Distance_from_CoG;
            end;
         end loop;
         return Real (Acc_Radius / Real (Length (Swarm_State)));
      end Mean_Radius;

      --
      --
      --

      function Mean_Closest_Distance return Real is

         Acc_Distance : Real := 0.0;

      begin
         for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
            declare
               This_Element     : constant Swarm_Element_State     := Element (Swarm_State, Element_Index);
               Neighbours       : constant Distance_Vectors.Vector := This_Element.Neighbours.all;
            begin
               if Distance_Vectors.Length (Neighbours) > 0 then
                  declare
                     Closest_Distance : constant Real                    :=
                       Distance_Vectors.Element (Neighbours, Distance_Vectors.First_Index (Neighbours)).Distance;
                  begin
                     Acc_Distance := Acc_Distance + Closest_Distance;
                  end;
               end if;
            end;
         end loop;
         return Real (Acc_Distance / Real (Length (Swarm_State)));
      end Mean_Closest_Distance;

      --

   end Swarm_Monitor;

   --
   --
   --

   procedure Remove_Vehicle_in_Stages (Element_Ix : Swarm_Element_Index) is

      Tolerated_Termination_Time : constant Duration := To_Duration (Milliseconds (100));

   begin
      Element (Swarm_State, Element_Ix).Process_abort.all.Open;
      select
         delay Tolerated_Termination_Time;
         Put_Line (Current_Error, "Warning: Vehicle task termination request ignored - attempting task abort now");
         select
            delay Tolerated_Termination_Time;
            Put_Line (Current_Error, "Error: Vehicle task stuck in non-abortable code region - task abort failed");
         then abort
            Abort_Task (Element (Swarm_State, Element_Ix).Process_Id);
            loop
               exit when Is_Terminated (Element (Swarm_State, Element_Ix).Process_Id);
               delay 0.0;
            end loop;
         end select;
      then abort
         loop
            exit when Is_Terminated (Element (Swarm_State, Element_Ix).Process_Id);
            delay 0.0;
         end loop;
      end select;
      Swarm_Monitor.Remove_Vehicle (Element_Ix);
   end Remove_Vehicle_in_Stages;

   procedure Remove_Vehicles (No_Of_Swarm_Elements : Positive  := 1) is

   begin
      if Natural (Length (Swarm_State)) >= No_Of_Swarm_Elements then
         for Element_Index in Last_Index (Swarm_State) - No_Of_Swarm_Elements + 1 .. Last_Index (Swarm_State) loop
            Remove_Vehicle_in_Stages (Element_Index);
         end loop;
      end if;
   end Remove_Vehicles;

   --
   --
   --

   procedure Sorted_Close_Distances (Close_Dist    : in out Distance_Vectors.Vector;
                                     Element_Index : Swarm_Element_Index;
                                     Max_Distance  : Distances) is

      This_Element  : constant Swarm_Element_State := Element (Swarm_State, Element_Index);
      This_Position : constant Positions           := This_Element.Position.all.Read;

   begin
      Distance_Vectors.Clear (Close_Dist);
      Distance_Vectors.Reserve_Capacity (Close_Dist, Length (Swarm_State) - 1);
      for Scan_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
         if Element_Index /= Scan_Index then
            declare
               Test_Element   : constant Swarm_Element_State := Element (Swarm_State, Scan_Index);
               Test_Position  : constant Positions           := Test_Element.Position.all.Read;
               Test_Direction : constant Vector_3D           := This_Position - Test_Position;
               Test_Distance  : constant Distances           := abs (Test_Direction);
            begin
               if Test_Distance <= Max_Distance then
                  Distance_Vectors.Append (Close_Dist, (Index         => Scan_Index,
                                                        Distance      => Test_Distance,
                                                        Position_Diff => Test_Direction,
                                                        Velocity_Diff => This_Element.Velocity.all.Read - Test_Element.Velocity.all.Read));
               end if;
            end;
         end if;
      end loop;
      Sort_Distances.Sort (Close_Dist);
   end Sorted_Close_Distances;

   --
   --
   --

   procedure Set_Acceleration (Element_Index : Swarm_Element_Index) is

      This_Element  : constant Swarm_Element_State := Element (Swarm_State, Element_Index);
      Acceleration  :          Accelerations       := Zero_Vector_3D;

   begin
      Sorted_Close_Distances (This_Element.Neighbours.all, Element_Index, Detection_Range);
      for Distance_Index in Distance_Vectors.First_Index (This_Element.Neighbours.all) .. Distance_Vectors.Last_Index (This_Element.Neighbours.all) loop
         declare
            Distance_Entry : constant Distance_Entries := Distance_Vectors.Element (This_Element.Neighbours.all, Distance_Index);
         begin

            -- Uncontrolled vehicles
            if This_Element.Controls.all.Read_Throttle = 0.0 then

               -- Attraction and repulsion forces between vehicles
               Acceleration := Acceleration + Inter_Swarm_Acceleration (Distance_Entry.Distance) * Norm (Distance_Entry.Position_Diff);

               -- Alignment forces
               if Distance_Entry.Distance <= Velocity_Matching_Range then
                  Acceleration := Acceleration + Velocity_Matching (This_Element.Velocity.all.Read, Distance_Entry.Velocity_Diff);
               end if;

               -- Controlled vehicles
            elsif Distance_Entry.Distance <= Unconditional_Repulse_Dist then

               -- Unconditional repulsion for controlled vehicles
               Acceleration := Acceleration + Inter_Swarm_Repulsion (Distance_Entry.Distance) * Norm (Distance_Entry.Position_Diff);

            end if;

         end;
      end loop;

      -- Controlled vehicles
      if This_Element.Controls.all.Read_Throttle /= 0.0 then

         -- Approach the set target
         declare
            Target_Vector                     : constant Vector_3D := This_Element.Controls.all.Read_Steering - This_Element.Position.all.Read;
            Norm_Target_Vector                : constant Vector_3D := Norm (Target_Vector);
            Abs_Target_Vector                 : constant Real := abs (Target_Vector);
            Abs_Velocity                      : constant Real := abs (This_Element.Velocity.all.Read);
            Angle_Between_Target_and_Velocity : constant Real := Angle_Between (Target_Vector, This_Element.Velocity.all.Read);
         begin
            if Abs_Target_Vector < Target_Fetch_Range then
               -- Target reached, switch to idle throttle
               This_Element.Controls.all.Set_Throttle (Idle_Throttle);
            else
               -- Accelerate to constant speed towards target, dampen lateral velocities
               Acceleration := Acceleration
                 + (This_Element.Controls.all.Read_Throttle
                    * Approach_Acceleration (Abs_Velocity * Cos (Angle_Between_Target_and_Velocity))
                    * Norm_Target_Vector)
                 - Norm (This_Element.Velocity.all.Read) * (Intented_Framerate / 5.0) * Abs_Velocity * Sin (Angle_Between_Target_and_Velocity);
            end if;
         end;
      end if;

      -- Friction
      This_Element.Acceleration.all.Write (Acceleration - Norm (This_Element.Velocity.all.Read) * (abs (This_Element.Velocity.all.Read) * Friction)**2);

      Replace_Element (Swarm_State, Element_Index, This_Element);
   end Set_Acceleration;

   --
   --
   --

   procedure Set_All_Accelerations is

   begin
      for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
         Set_Acceleration (Element_Index);
      end loop;
   end Set_All_Accelerations;

   --
   --
   --

   procedure Forward_Messages (Element_Index : Swarm_Element_Index) is

      This_Element              : constant Swarm_Element_State := Element (Swarm_State, Element_Index);
      Message_To_Be_Distributed : Inter_Vehicle_Messages;

   begin
      while This_Element.Comms.all.Has_Outgoing_Messages loop
         This_Element.Comms.all.Fetch_Message (Message_To_Be_Distributed);
         Check_Neighbours : for Distance_Index in Distance_Vectors.First_Index (This_Element.Neighbours.all) .. Distance_Vectors.Last_Index (This_Element.Neighbours.all) loop
            declare
               Distance_Entry : constant Distance_Entries := Distance_Vectors.Element (This_Element.Neighbours.all, Distance_Index);
            begin
               if Distance_Entry.Distance <= Comms_Range then
                  Element (Swarm_State, Distance_Entry.Index).Comms.all.Push_Message (Message_To_Be_Distributed);
               else
                  exit Check_Neighbours;
               end if;
            end;
         end loop Check_Neighbours;
      end loop;
   end Forward_Messages;

   --
   --
   --

   procedure Forward_All_Messages is

   begin
      for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
         Forward_Messages (Element_Index);
      end loop;
   end Forward_All_Messages;

   --
   --
   --

   procedure Move_Element (Element_Index : Swarm_Element_Index) is

      This_Element : Swarm_Element_State := Element (Swarm_State, Element_Index);
      Interval     : constant Real       := Real'Min (Real (To_Duration (Clock - This_Element.Last_Update)), Max_Update_Interval);

   begin
      This_Element.Velocity.all.Write (This_Element.Velocity.all.Read + (Interval * This_Element.Acceleration.all.Read));

      declare
         Move_Start : constant Positions := This_Element.Position.all.Read;
         Move_End   : constant Positions := Move_Start + (Interval * This_Element.Velocity.all.Read);
      begin
         This_Element.Position.all.Write (Move_End);

         This_Element.Charge.Level := Vehicle_Charges
           (Real'Max (Real (Empty_Charge),
            Real'Min (Real (Full_Charge),
              Real (This_Element.Charge.Level)
              - (Interval
                * (Charging_Setup.Constant_Discharge_Rate_Per_Sec
                  + Charging_Setup.Propulsion_Discharge_Rate_Per_Sec * abs (This_Element.Acceleration.all.Read))))));

         for Globe_Ix in Globes'Range loop

            declare
               Globe_Pos    : constant Positions := Globes (Globe_Ix).Position.all.Read;
               Interratio   : constant Real      := (Globe_Pos - Move_Start) * ((Move_End - Move_Start) / (abs (Move_End - Move_Start)));
               Intersection : constant Positions := Move_Start + Interratio * (Move_End - Move_Start);
               Touching     : constant Boolean   := Globes (Globe_Ix).Active and then abs (Intersection - Globe_Pos) <= Energy_Globe_Detection and then Interratio >= 0.0 and then Interratio <= 1.0;
               Slot_Passed  : constant Boolean   := Clock - This_Element.Charge.Charge_Time.all.Read > Charging_Setup.Max_Globe_Interval;
            begin
               if (not This_Element.Charge.Globes_Touched (Globe_Ix) or else Slot_Passed) and then Touching then

                  if Slot_Passed then
                     This_Element.Charge.Globes_Touched := No_Globes_Touched;
                     This_Element.Charge.Charge_No      := 0;
                  end if;

                  This_Element.Charge.Charge_No                 := This_Element.Charge.Charge_No + 1;
                  This_Element.Charge.Globes_Touched (Globe_Ix) := True;
                  This_Element.Charge.Charge_Time.all.Write (Clock);

                  if This_Element.Charge.Charge_No = Charging_Setup.Globes_Required then
                     This_Element.Charge.Level          := Full_Charge;
                     This_Element.Charge.Charge_No      := 0;
                     This_Element.Charge.Globes_Touched := No_Globes_Touched;
                  end if;

               end if;
            end;
         end loop;
      end;

      This_Element.Last_Update := Clock;
      Replace_Element (Swarm_State, Element_Index, This_Element);
   end Move_Element;

   --
   --
   --

   procedure Move_All_Elements is

   begin
      for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
         Move_Element (Element_Index);
      end loop;
   end Move_All_Elements;

   --
   --
   --

   procedure Update_Rotation (Element_Index : Swarm_Element_Index) is

      function Vector_Yaw (In_Vector : Vector_3D) return Real is
        (if In_Vector (x) = 0.0 and then In_Vector (z) = 0.0
         then 0.0
         else Arctan (In_Vector (x), In_Vector (z)));

      function Vector_Pitch (In_Vector : Vector_3D) return Real is
        ((Pi / 2.0) - Angle_Between (In_Vector, (0.0, 1.0, 0.0)));

      This_Element : constant Swarm_Element_State := Element (Swarm_State, Element_Index);

      Velocity      : constant Vector_3D := This_Element.Velocity.all.Read;
      Element_Yaw   : constant Real      := Vector_Yaw   (Velocity);
      Element_Pitch : constant Real      := Vector_Pitch (Velocity);

      Rotation      : constant Quaternion_Rotation := To_Rotation (0.0, -Element_Pitch, Element_Yaw + Pi);
      Norm_Acc      : constant Vector_3D := Rotate (This_Element.Acceleration.all.Read, Rotation);
      Lateral_Acc   : constant Real      := Norm_Acc (x) * abs (Velocity);
      Element_Roll  : constant Real :=
        Real'Max (-Pi / 2.0,
                  Real'Min (Pi / 2.0,
                    Lateral_Acc * (Pi / 2.0) / Max_Assumed_Acceleration));

   begin
      This_Element.Rotation.all.Write (To_Rotation (Element_Roll, -Element_Pitch, -Element_Yaw + Pi));
      Replace_Element (Swarm_State, Element_Index, This_Element);
   end Update_Rotation;

   ---
   ---
   ---

   procedure Update_All_Rotations is

   begin
      for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
         Update_Rotation (Element_Index);
      end loop;
   end Update_All_Rotations;

   --
   --
   --

   procedure Remove_Empties is

   begin
      if Length (Swarm_State) > 1 then
         declare
            Element_Index : Swarm_Element_Index := First_Index (Swarm_State);
         begin
            while Element_Index <= Last_Index (Swarm_State) and then Length (Swarm_State) > 1 loop
               if Element (Swarm_State, Element_Index).Charge.Level = Empty_Charge then
                  Remove_Vehicle_in_Stages (Element_Index);
               else
                  Element_Index := Element_Index + 1;
               end if;
            end loop;
         end;
      end if;
   end Remove_Empties;

end Swarm_Control;
