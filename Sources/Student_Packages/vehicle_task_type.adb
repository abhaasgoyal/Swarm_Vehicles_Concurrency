with Ada.Real_Time;         use Ada.Real_Time;
with Exceptions;            use Exceptions;
with Real_Type;             use Real_Type;
with Vectors_3D;            use Vectors_3D;
with Vehicle_Interface;     use Vehicle_Interface;
with Vehicle_Message_Type;  use Vehicle_Message_Type;
with Swarm_Structures_Base; use Swarm_Structures_Base;
with Ada.Numerics;          use Ada.Numerics;

package body Vehicle_Task_Type is
   use Real_Elementary_Functions;
   -- Dials to adjust for optimization
   No_Of_Vehicle_Sets  : constant Positive        := 4;
   Low_Battery         : constant Vehicle_Charges := 0.3;
   Norm_Radius         : constant Vehicle_Charges := 0.25;
   Low_Throttle        : constant Throttle_T      := 0.4;
   Initial_Degree_Step : constant Positive        := 2;

   type Degrees is mod 360;
   Radians_List : array (Degrees) of Real;
   task body Vehicle_Task is
      Radians_Index : Degrees;
      Local_Record  : Inter_Vehicle_Messages;
      Vehicle_No    : Positive;
      Vehicle_Set   : Natural;
      -- Phi is w.r.t z-axis and Theta w.r.t xy-plane
      Phi   : Real;
      Theta : Real;

      -- Could have placed in the declared block but definining the procedures
      -- everytime in define block may slow down the program
      function Vector_Distance (V_1, V_2 : Vector_3D) return Real is
        (abs (V_1 - V_2));

      function Y_Axis_Rotate (A : Vector_3D) return Vector_3D is
        ((A (x) * Cos (Phi) - A (y) * Sin (Phi),
          A (x) * Sin (Phi) + A (y) * Cos (Phi), A (z)));
      function Orbit_Position (R : Real) return Vector_3D is
        (Y_Axis_Rotate
           (Local_Record.Globe_Pos + (R * Sin (Theta), 0.0, R * Cos (Theta))));
      procedure Spiral_Orbit (Charge : Vehicle_Charges) is
      begin
         Radians_Index := Degrees'Succ (Radians_Index);
         Theta         := Radians_List (Radians_Index);
         Set_Throttle (Low_Throttle);
         Set_Destination (Orbit_Position (Real (Norm_Radius * Charge)));
      end Spiral_Orbit;
   begin
      -- Construct Angle lookup table
      for I in Radians_List'Range loop
         Radians_List (I) := Real (I) * Pi / 180.0;
      end loop;
      accept Identify (Set_Vehicle_No : Positive; Local_Task_Id : out Task_Id)
      do
         Vehicle_No    := Set_Vehicle_No;
         Local_Task_Id := Current_Task;
      end Identify;
      Vehicle_Set   := Vehicle_No mod No_Of_Vehicle_Sets;
      Radians_Index := Degrees (Vehicle_No * Initial_Degree_Step);
      Theta         := Radians_List (Radians_Index);
      Phi := Radians_List (Degrees (Vehicle_Set * (180 / No_Of_Vehicle_Sets)));

      select
         Flight_Termination.Stop;

      then abort

         Outer_task_loop :
         loop
            declare
               Globes : constant Energy_Globes := Energy_Globes_Around;
               Closest_Globe   : Vector_3D;
               Received_Record : Inter_Vehicle_Messages;
            begin
               if Globes'Length > 0 then
                  Closest_Globe := Globes (1).Position;
                  for G of Globes loop
                     if Vector_Distance (G.Position, Position) >
                       Vector_Distance (Closest_Globe, Position)
                     then
                        Closest_Globe := G.Position;
                     end if;
                     -- Propagate the position of the globe
                     Send ((G.Position, Clock));
                     exit;
                  end loop;
                  Local_Record.Message_Time := Clock;
                  Local_Record.Globe_Pos    := Closest_Globe;
               end if;

               if Current_Charge < Low_Battery or else Messages_Waiting then
                  -- Would a blocking operation for low Low_Battery emergency
                  -- TODO Edge case : If You don't receive any record here
                  -- after low battery ?
                  Receive (Received_Record);
                  -- Update Local Record to latest value
                  if Local_Record.Message_Time < Received_Record.Message_Time
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
                  Send (Local_Record);
               else
                  -- Move normally and provide graceful degradation in case
                  -- globe dies and no incoming calls are present
                  Spiral_Orbit (Current_Charge);
               end if;
            end;
            Wait_For_Next_Physics_Update;
         end loop Outer_task_loop;

      end select;

   exception
      when E : others =>
         Show_Exception (E);

   end Vehicle_Task;

end Vehicle_Task_Type;
