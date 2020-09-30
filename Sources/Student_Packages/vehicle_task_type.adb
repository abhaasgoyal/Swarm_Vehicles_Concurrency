with Ada.Real_Time;         use Ada.Real_Time;
with Exceptions;            use Exceptions;
with Real_Type;             use Real_Type;
with Vectors_3D;            use Vectors_3D;
with Vehicle_Interface;     use Vehicle_Interface;
with Vehicle_Message_Type;  use Vehicle_Message_Type;
with Swarm_Structures_Base; use Swarm_Structures_Base;
with Ada.Numerics;          use Ada.Numerics;
with Concrete_Order;
with Ada.Text_IO;           use Ada.Text_IO;
package body Vehicle_Task_Type is
   use Real_Elementary_Functions;
   use Abstract_List;
   -- Dials to adjust for optimization
   No_Of_Vehicle_Sets      : constant Positive        := 4;
   Low_Battery             : constant Vehicle_Charges := 0.4;
   Norm_Radius             : constant Vehicle_Charges := 0.3;
   Low_Throttle            : constant Throttle_T      := 0.3;
   Initial_Degree_Step     : constant Positive        := 2;
   Consensus_Time_Interval : constant Duration        := 180.0;

   type Degrees is mod 360;
   type Angles_List is array (Degrees) of Real;
   -- Construct Angle lookup table
   function Initialize_Radian_Array return Angles_List is
      Temp_Arr : Angles_List;
   begin
      for I in Temp_Arr'Range loop
         Temp_Arr (I) := Real (I) * Pi / 180.0;
      end loop;
      return Temp_Arr;
   end Initialize_Radian_Array;

   Radians_List      : constant Angles_List := Initialize_Radian_Array;
   Invalid_Globe_Pos : constant Vector_3D                   := (0.0, 0.0, 0.0);
   Invalid_Time      : constant Time                        := Time_Last;
   Invalid_List      : constant Temp_List.List (Data_Index) := (others => 0);

   -- Printing the lookup table for all vehicles after stipulated time for
   -- consensus
   protected Print_Stuff is
      procedure Print_Arr (Input : Temp_List.List; Vehicle_No : Positive);
   end Print_Stuff;
   protected body Print_Stuff is
      procedure Print_Arr (Input : Temp_List.List; Vehicle_No : Positive) is
      begin
         Put ("For Vehicle" & Natural'Image (Vehicle_No) & " : ");
         for I of Input loop
            Put (Natural'Image (I));
         end loop;
         Put_Line ("");
      end Print_Arr;
   end Print_Stuff;

   task body Vehicle_Task is
      Start_Time   : constant Time := Clock;
      Radians_Ix   : Degrees;
      Local_Record : Inter_Vehicle_Messages;
      Vehicle_No   : Positive;
      Vehicle_Set  : Natural;
      Check_Shrink : Boolean       := True;

      -- Phi is w.r.t z-axis and Theta w.r.t xy-plane
      Phi   : Real;
      Theta : Real;
      package Local_List is new Concrete_Order (Abstract_List);

      function Distance (V_1, V_2 : Vector_3D) return Real is
        (abs (V_1 - V_2));
      function Send_Type_X
        (Globe_Pos : Vector_3D; Message_Time : Time)
         return Inter_Vehicle_Messages is

        ((Message_Type => Type_X, Globe_Pos => Globe_Pos,
          Message_Time => Message_Time, List_Full_Time => Invalid_Time,
          Vehicle_List => Temp_List.List (Invalid_List)));
      function Send_Type_Y
        (Vehicle_List : Temp_List.List; List_Full_Time : Time)
         return Inter_Vehicle_Messages is

        ((Message_Type => Type_Y, Globe_Pos => Invalid_Globe_Pos,
          Message_Time => Invalid_Time, List_Full_Time => List_Full_Time,
          Vehicle_List => Vehicle_List));
      -- Functions for detemining next position of orbit
      function Y_Axis_Rotate (A : Vector_3D) return Vector_3D is
        ((A (x) * Cos (Phi) - A (y) * Sin (Phi),
          A (x) * Sin (Phi) + A (y) * Cos (Phi), A (z)));
      function Orbit_Position (R : Real) return Vector_3D is
        (Y_Axis_Rotate
           (Local_Record.Globe_Pos + (R * Sin (Theta), 0.0, R * Cos (Theta))));
      procedure Spiral_Orbit (Charge : Vehicle_Charges) is
      begin
         Radians_Ix := Degrees'Succ (Radians_Ix);
         Theta      := Radians_List (Radians_Ix);
         Set_Throttle (Low_Throttle);
         Set_Destination (Orbit_Position (Real (Norm_Radius * Charge)));
      end Spiral_Orbit;
   begin
      accept Identify (Set_Vehicle_No : Positive; Local_Task_Id : out Task_Id)
      do
         Vehicle_No    := Set_Vehicle_No;
         Local_Task_Id := Current_Task;
      end Identify;
      Vehicle_Set := Vehicle_No mod No_Of_Vehicle_Sets;
      -- mod 360 is done w.r.t safety in Development mode
      Radians_Ix := Degrees ((Vehicle_No * Initial_Degree_Step) mod 360);
      Theta      := Radians_List (Radians_Ix);
      Phi := Radians_List (Degrees (Vehicle_Set * (180 / No_Of_Vehicle_Sets)));

      Local_List.Add_To_List (Vehicle_No);
      -- Uncomment below operation when wanting to implement Stage D This is
      -- the bootstrapper for the stage
      --  Send
      --    (Send_Type_Y
      --       (List_Full_Time => Time_First,
      --        Vehicle_List   => Temp_List.List (Local_List.Read_List)));
      select
         Flight_Termination.Stop;

      then abort

         Outer_task_loop :
         loop
            declare
               Globes : constant Energy_Globes := Energy_Globes_Around;
               Closest_Globe   : Vector_3D;
               Received_Record : Inter_Vehicle_Messages;
               package Rec_List is new Concrete_Order (Abstract_List);
               use Rec_List;
--               Check_Same_List : Local_List.List (Data_Index);
            begin
               if Globes'Length > 0 then
                  Closest_Globe := Globes (1).Position;
                  for G of Globes loop
                     if Distance (G.Position, Position) >
                       Distance (Closest_Globe, Position)
                     then
                        Closest_Globe := G.Position;
                     end if;
                     -- Propagate the position of the globe
                     Send
                       (Send_Type_X
                          (Globe_Pos => G.Position, Message_Time => Clock));
                     exit;
                  end loop;
                  Local_Record.Message_Time := Clock;
                  Local_Record.Globe_Pos    := Closest_Globe;
               end if;
               if Current_Charge < Low_Battery or else Messages_Waiting then
                  Receive (Received_Record);
                  -- Stage D lookup table case
                  if Received_Record.Message_Type = Type_Y then
                     Rec_List.Write_List (List (Received_Record.Vehicle_List));
                     if Rec_List.List_Full then
                        if Local_List.List_Full then
                           if Received_Record.List_Full_Time <
                             Local_Record.List_Full_Time
                           then
                              Local_List.Write_List
                                (Local_List.List (Rec_List.Read_List));
                              Local_Record.List_Full_Time :=
                                Received_Record.List_Full_Time;
                           else
                              null;
                           end if;
                        else
                           Local_List.Write_List
                             (Local_List.List (Rec_List.Read_List));
                           Local_Record.List_Full_Time :=
                             Received_Record.List_Full_Time;
                        end if;
                        Send
                          (Send_Type_Y
                             (List_Full_Time => Local_Record.List_Full_Time,
                              Vehicle_List   =>
                                Temp_List.List (Local_List.Read_List)));
                     elsif Local_List.List_Full then
                        Send
                          (Send_Type_Y
                             (List_Full_Time => Local_Record.List_Full_Time,
                              Vehicle_List   =>
                                Temp_List.List (Local_List.Read_List)));
                     else
                        Local_List.Max_Union
                          (Local_List.List (Rec_List.Read_List));
                        if Local_List.List_Full then
                           Send
                             (Send_Type_Y
                                (List_Full_Time => Clock,
                                 Vehicle_List   =>
                                   Temp_List.List (Local_List.Read_List)));
                        else
                           Send
                             (Send_Type_Y
                                (List_Full_Time => Local_Record.List_Full_Time,
                                 Vehicle_List   =>
                                   Temp_List.List (Local_List.Read_List)));
                        end if;
                     end if;
                     -- Update Local Record to latest value (Stage B and C
                     -- case)
                  else
                     if Local_Record.Message_Time <
                       Received_Record.Message_Time
                     then
                        Local_Record := Received_Record;
                     end if;
                     -- Vehicle destination decision
                     if Current_Charge < Low_Battery then
                        Set_Throttle (Full_Throttle);
                        Set_Destination (Local_Record.Globe_Pos);
                     else
                        Spiral_Orbit (Current_Charge);
                     end if;
                     -- Propagate the latest signal
                     Send
                       (Send_Type_X
                          (Globe_Pos    => Local_Record.Globe_Pos,
                           Message_Time => Local_Record.Message_Time));
                  end if;
               else
                  -- Move normally and provide graceful degradation in case
                  -- globe dies and no incoming calls are present
                  Spiral_Orbit (Current_Charge);
               end if;
            end;
            if To_Duration (Clock - Start_Time) > Consensus_Time_Interval
              and then Check_Shrink
            then
               Check_Shrink := False;
               Print_Stuff.Print_Arr
                 (Temp_List.List (Local_List.Read_List), Vehicle_No);
               if not Local_List.Found_In_List (Vehicle_No) then
                  loop
                     -- Graceful Death of Vehicle (Shake @ Position)
                     Spiral_Orbit (Current_Charge);
                  end loop;
               end if;
               -- Could do muliple iterations of Lookup_Tables but problem of
               -- uncertainity
            end if;
            Wait_For_Next_Physics_Update;
         end loop Outer_task_loop;

      end select;

   exception
      when E : others =>
         Show_Exception (E);

   end Vehicle_Task;

end Vehicle_Task_Type;
