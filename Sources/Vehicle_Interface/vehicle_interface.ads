--
-- Uwe R. Zimmer, Australia, July 2015
--

with Real_Type;             use Real_Type;
with Swarm_Structures_Base; use Swarm_Structures_Base;
with Vectors_3D;            use Vectors_3D;
with Vehicle_Message_Type;  use Vehicle_Message_Type;

package Vehicle_Interface is

   -----------
   -- State --
   -----------

   function Position     return Positions;
   function Velocity     return Velocities;
   function Acceleration return Accelerations;

   --------------
   -- Steering --
   --------------

   procedure Set_Destination (V : Vector_3D);

   --------------
   -- Throttle --
   --------------

   procedure Set_Throttle    (T : Throttle_T);
   -- Throttle automatically switched to Idle_Throttle when the destination has been reached.
   function Throttle_Is_On_Idle return Boolean;

   ---------------
   -- Messaging --
   ---------------

   procedure Send    (Message :     Inter_Vehicle_Messages);
   procedure Receive (Message : out Inter_Vehicle_Messages); -- blocking if no messages
   function Messages_Waiting return Boolean;

   function Current_Charge    return Vehicle_Charges;
   function Current_Discharge_Per_Sec return Real;

   function Energy_Globes_Around return Energy_Globes;

   procedure Wait_For_Next_Physics_Update;
   -- blocking until the underlying physics engine updated swarm and globe positions.

   -----------------
   -- Termination --
   -----------------

   protected Flight_Termination is

      entry Stop; -- this entry will open iff the task is requested to terminate.

   end Flight_Termination;

end Vehicle_Interface;
