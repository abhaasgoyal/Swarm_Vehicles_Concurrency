--  with Ada.Numerics; use Ada.Numerics; with Ada.Real_Time; use Ada.Real_Time;
--  with Exceptions; use Exceptions; with Real_Type; use Real_Type; with
--  Vectors_3D; use Vectors_3D; with Vehicle_Interface; use Vehicle_Interface;
--  with Vehicle_Message_Type; use Vehicle_Message_Type; with
--  Swarm_Structures_Base; use Swarm_Structures_Base;

--  package body Vehicle_Task_Type is

--     task body Vehicle_Task is
--        Local_Record : Inter_Vehicle_Messages;
--        Vehicle_No   : Positive;
--        -- Phi is w.r.t z-axis and Theta w.r.t xy-plane
--        Phi   : Real := 0.0;
--        Theta : Real := 0.0;
--        -- Vehicle Set (0 - 3)
--        Vehicle_Set        : Natural;
--        No_Of_Vehicle_Sets : constant Positive        := 4;
--        Low_Battery        : constant Vehicle_Charges := 0.3;
--        Norm_Radius        : constant Vehicle_Charges := 0.3;

--        function Vector_Distance
--          (V_1 : Vector_3D; V_2 : Vector_3D) return Real is
--          (abs (V_1 - V_2));

--        -- Could have placed in the declared block but definining the procedures
--        -- everytime in define block slows down the program
--        function Sin (X : Real) return Real renames
--          Real_Elementary_Functions.Sin;
--        function Cos (X : Real) return Real renames
--          Real_Elementary_Functions.Cos;
--        function Y_Axis_Rotate (A : Vector_3D) return Vector_3D is
--          ((A (x) * Cos (Phi) - A (y) * Sin (Phi),
--            A (x) * Sin (Phi) + A (y) * Cos (Phi), A (z)));
--        function Orbit_Position (R : Real) return Vector_3D is
--          (Y_Axis_Rotate
--             ((Local_Record.Globe_Pos (x) + R * Sin (Theta),
--               Local_Record.Globe_Pos (y),
--               Local_Record.Globe_Pos (z) + R * Cos (Theta))));
--        procedure Spiral_Orbit (Charge : Vehicle_Charges) is
--        begin
--           Set_Throttle (0.4);
--           Set_Destination (Orbit_Position (Real (Norm_Radius * Charge)));
--        end Spiral_Orbit;

--     begin

--        accept Identify (Set_Vehicle_No : Positive; Local_Task_Id : out Task_Id)
--        do
--           Vehicle_No    := Set_Vehicle_No;
--           Local_Task_Id := Current_Task;
--        end Identify;

--        Vehicle_Set := Vehicle_No mod No_Of_Vehicle_Sets;
--        Theta       := Real (Vehicle_No mod 180) * (Pi / 90.0);
--        Phi         := Real (Vehicle_Set) * (Pi / Real (No_Of_Vehicle_Sets));

--        select

--           Flight_Termination.Stop;

--        then abort

--           Outer_task_loop :
--           loop
--              Theta := Theta + Pi / 180.0;

--              declare
--                 Globes : constant Energy_Globes := Energy_Globes_Around;
--                 Closest_Globe   : Vector_3D;
--                 Received_Record : Inter_Vehicle_Messages;
--              begin
--                 if Globes'Length > 0 then
--                    Closest_Globe := Globes (1).Position;
--                    for G of Globes loop
--                       if Vector_Distance (G.Position, Position) >
--                         Vector_Distance (Closest_Globe, Position)
--                       then
--                          Closest_Globe := G.Position;
--                       end if;
--                       -- Propagate the position of the globe
--                       Send ((G.Position, Clock));
--                       exit;
--                    end loop;
--                    Local_Record.Message_Time := Clock;
--                    Local_Record.Globe_Pos    := Closest_Globe;
--                 end if;

--                 if Current_Charge < Low_Battery or else Messages_Waiting then
--                    -- Would a blocking operation for low battery since on
--                    -- emergency case
--                    Receive (Received_Record);
--                    -- Update Records to latest value
--                    if To_Duration
--                        (Received_Record.Message_Time -
--                         Local_Record.Message_Time) >
--                      0.0
--                    then
--                       Local_Record := Received_Record;
--                    else
--                       Received_Record := Local_Record;
--                    end if;
--                    -- Vehicle destination decision
--                    if Current_Charge < Low_Battery then
--                       Set_Throttle (Full_Throttle);
--                       Set_Destination (Local_Record.Globe_Pos);
--                    else
--                       Spiral_Orbit (Current_Charge);
--                    end if;
--                    -- Propagate the signal further
--                    Send (Received_Record);
--                 else
--                    -- Move normally and provide graceful degradation in case
--                    -- globe dies and no incoming calls
--                    Spiral_Orbit (Current_Charge);
--                 end if;
--              end;
--              Wait_For_Next_Physics_Update;
--           end loop Outer_task_loop;
--        end select;
--     exception
--        when E : others =>
--           Show_Exception (E);
--     end Vehicle_Task;
--  end Vehicle_Task_Type;

-- Task A

-- Get the Globe and store it in Common Position
--  declare
--     Globes : constant Energy_Globes := Energy_Globes_Around;
--  begin
--     for G of Globes loop
--        Shared_Globe_Position := G.Position;
--     end loop;
--  end;

--  if Current_Charge < Half_Charge then
--     Set_Throttle (Full_Throttle);
--     Set_Destination (Shared_Globe_Position);
--  else
--     Set_Throttle (Half_Throttle);
--     Set_Destination (Shared_Globe_Position + (0.1, 0.0, 0.0));
--  end if;

-- Get the Globe and store it in Common Position
--  declare
--     Globes : constant Energy_Globes := Energy_Globes_Around;
--  begin
--     for G of Globes loop
--        Shared_Globe_Position := G.Position;
--     end loop;
--  end;
--  if Current_Charge > 0.5 then
--     Set_Throttle (Idle_Throttle);
--  elsif Current_Charge > 0.2 then
--     Set_Throttle (Half_Throttle);
--  else
--     Set_Throttle (Full_Throttle);
--     Set_Destination (Shared_Globe_Position);
--  end if;
