--
-- Uwe R. Zimmer, Australia, September 2019
--

with Ada.Task_Identification;    use Ada.Task_Identification;

with Swarm_Configuration;        use Swarm_Configuration;
with Swarm_Control;              use Swarm_Control;
with Swarm_Data;                 use Swarm_Data;
with Swarm_Structures;           use Swarm_Structures;

package body Vehicle_Interface is

--     use Swarm_Vectors;

   -----------
   -- State --
   -----------

   function Position return Positions is
     (Swarm_Monitor.Position (Current_Task).all.Read);

   function Velocity return Velocities is
     (Swarm_Monitor.Velocity (Current_Task).all.Read);

   function Acceleration return Accelerations is
     (Swarm_Monitor.Acceleration (Current_Task).all.Read);

   --------------
   -- Steering --
   --------------

   procedure Set_Destination (V : Vector_3D) is

   begin
      Swarm_Monitor.Controls (Current_Task).all.Set_Steering (V);
   end Set_Destination;

   --------------
   -- Thruttle --
   --------------

   procedure Set_Throttle (T : Throttle_T) is

   begin
      Swarm_Monitor.Controls (Current_Task).all.Set_Throttle (T);
   end Set_Throttle;

   function Throttle_Is_On_Idle return Boolean is
     (Swarm_Monitor.Controls (Current_Task).all.Read_Throttle = Idle_Throttle);

   ---------------
   -- Messaging --
   ---------------

   procedure Send (Message : Inter_Vehicle_Messages) is

   begin
      Swarm_Monitor.Comms (Current_Task).all.Send (Message);
   end Send;

   procedure Receive (Message : out Inter_Vehicle_Messages) is

   begin
      Swarm_Monitor.Comms (Current_Task).all.Receive (Message);
   end Receive;

   function Messages_Waiting return Boolean is
     (Swarm_Monitor.Comms (Current_Task).all.Has_Incoming_Messages);

   ------------
   -- Energy --
   ------------

   function Current_Charge return Vehicle_Charges is
     (Swarm_Monitor.Charge (Current_Task).Level);

   function Current_Discharge_Per_Sec return Real is
     (Charging_Setup.Constant_Discharge_Rate_Per_Sec + Charging_Setup.Propulsion_Discharge_Rate_Per_Sec * abs (Acceleration));

   function Energy_Globes_Around return Energy_Globes is

      Globes_Found          : Natural                         := 0;
      Globes_Detected       : array (Globes'Range) of Boolean := (others => False);
      This_Element_Position : constant Positions              := Position;

   begin
      for Globe_Ix in Globes'Range loop
         if Globes (Globe_Ix).Active and then abs (This_Element_Position - Globes (Globe_Ix).Position.all.Read) <= Energy_Globe_Detection then
            Globes_Detected (Globe_Ix) := True;
            Globes_Found := Globes_Found + 1;
         end if;
      end loop;

      declare
         Found_Globes : Energy_Globes (1 .. Globes_Found);
         Found_Globes_Ix : Natural := Globes'First;
      begin
         for Globe_Ix in Globes'Range loop
            if Globes_Detected (Globe_Ix) then
               Found_Globes (Found_Globes_Ix) := (Position => Globes (Globe_Ix).Position.all.Read,
                                                  Velocity => Globes (Globe_Ix).Velocity.all.Read);
               Found_Globes_Ix := Found_Globes_Ix + 1;
            end if;
         end loop;
         return Found_Globes;
      end;
   end Energy_Globes_Around;

   --

   procedure Wait_For_Next_Physics_Update is

   begin
      Simulator_Tick.Wait_For_Next_Tick;
   end Wait_For_Next_Physics_Update;

   -----------------
   -- Termination --
   -----------------

   protected body Flight_Termination is

      entry Stop when True is

      begin
         requeue Swarm_Monitor.Process_abort.all.Wait with abort;
      end Stop;

   end Flight_Termination;

   --

end Vehicle_Interface;
