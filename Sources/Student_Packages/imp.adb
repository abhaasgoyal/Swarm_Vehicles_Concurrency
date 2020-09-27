with Ada.Real_Time;         use Ada.Real_Time;
with Exceptions;            use Exceptions;
with Real_Type;             use Real_Type;
with Vectors_3D;            use Vectors_3D;
with Vehicle_Interface;     use Vehicle_Interface;
with Vehicle_Message_Type;  use Vehicle_Message_Type;
with Swarm_Structures_Base; use Swarm_Structures_Base;
with Ada.Numerics;          use Ada.Numerics;

package body Vehicle_Task_Type is

   task body Vehicle_Task is

      Vehicle_No    : Positive;
      Vehicle_Class : Natural;
      Rot_Ang       : Real := 0.0;
      Angle_Vehicle : Real := 0.0;
      Outer_Message : Inter_Vehicle_Messages;
      Local_Message : Inter_Vehicle_Messages;
      function Sin (X : Real) return Real renames
        Real_Elementary_Functions.Sin;
      function Cos (X : Real) return Real renames
        Real_Elementary_Functions.Cos;
      function Vector_Distance
        (V_1 : Vector_3D; V_2 : Vector_3D) return Real is
        (abs (V_1 - V_2));
      function Y_Axis_Rotate (A : Vector_3D) return Vector_3D is
        ((A (x) * Cos (Rot_Ang) - A (y) * Sin (Rot_Ang),
          A (x) * Sin (Rot_Ang) + A (y) * Cos (Rot_Ang), A (z)));
      function Inner_Circle (R : Real) return Vector_3D is
        (Y_Axis_Rotate
           ((Local_Message.Globe_Position (x) + R * Sin (Angle_Vehicle),
             Local_Message.Globe_Position (y),
             Local_Message.Globe_Position (z) + R * Cos (Angle_Vehicle))));

      -- Checking timestamps to get the newest message
      procedure Check_Info is
      begin
         -- if the receiving time is newest then updating the local information
         if Outer_Message.Time_Checker > Local_Message.Time_Checker then
            Local_Message := Outer_Message;
         else
            Outer_Message := Local_Message;
         end if;
      end Check_Info;

   begin

      accept Identify (Set_Vehicle_No : Positive; Local_Task_Id : out Task_Id)
      do
         Vehicle_No    := Set_Vehicle_No;
         Local_Task_Id := Current_Task;
         Vehicle_Class := Vehicle_No mod 4; -- from 0 to 3
         Angle_Vehicle := Long_Float (Vehicle_No mod 16) * (Pi / 8.0);
         Rot_Ang       := Long_Float (Vehicle_Class) * (Pi / 4.0);
      end Identify;
      select

         Flight_Termination.Stop;

      then abort

         Outer_task_loop :
         loop

            -- Try to find the energy globe
            declare
               Globes        : constant Energy_Globes := Energy_Globes_Around;
               Closest_Globe : Vector_3D;
            begin
               if Globes'Length > 0 then
                  Closest_Globe := Globes (1).Position;
                  for G of Globes loop
                     Outer_Message.Globe_Position := G.Position;
                     if Vector_Distance (G.Position, Position) >
                       Vector_Distance (Closest_Globe, Position)
                     then
                        Closest_Globe := G.Position;
                     end if;
                     Outer_Message.Time_Checker := Clock;
                     Send (Outer_Message);
                     exit;
                  end loop;
                  Local_Message                := Outer_Message;
                  Local_Message.Globe_Position := Closest_Globe;
               end if;
            end;

            -- Try to conserve as much energy as you can by setting the
            -- throttle low But not too low to cause problems when reaching
            Set_Throttle (0.4);

            if Current_Charge < 0.3 or Messages_Waiting then
               -- Wait to Receive any kinda message
               Receive (Outer_Message);
               Check_Info;
               if Current_Charge < 0.3 then
                  Set_Throttle (Full_Throttle);
                  Set_Destination (Local_Message.Globe_Position);
               else
                  Set_Destination (Inner_Circle (Real (Current_Charge * 0.3)));
               end if;
               Send (Outer_Message);
            end if;

            Angle_Vehicle := Angle_Vehicle + Pi / 180.0;

            Wait_For_Next_Physics_Update;
         end loop Outer_task_loop;
      end select;
   exception
      when E : others =>
         Show_Exception (E);
   end Vehicle_Task;
end Vehicle_Task_Type;
