--
-- Jan & Uwe R. Zimmer, Australia, 2013
--

with Ada.Containers.Vectors;     use Ada.Containers;
with Ada.Real_Time;              use Ada.Real_Time;
with Ada.Task_Identification;    use Ada.Task_Identification;
with Ada.Unchecked_Deallocation; use Ada;
with Barrier_Type;               use Barrier_Type;
with Generic_Protected;                                        pragma Elaborate_All (Generic_Protected);
with Generic_Realtime_Buffer;                                  pragma Elaborate_All (Generic_Realtime_Buffer);
with Vectors_3D;                 use Vectors_3D;
with Rotations;                  use Rotations;                pragma Elaborate_All (Rotations);
with Swarm_Configuration;        use Swarm_Configuration;
with Swarm_Structures_Base;      use Swarm_Structures_Base;
with Vehicle_Message_Type;       use Vehicle_Message_Type;
with Vehicle_Task_Type;          use Vehicle_Task_Type;

package Swarm_Structures is

   pragma Elaborate_Body;

   No_Of_Buffered_Incoming_Messages : constant Positive := 10;
   No_Of_Buffered_Outgoing_Messages : constant Positive := 2;

   type Distance_Entries is
      record
         Index         : Swarm_Element_Index;
         Distance      : Distances;
         Position_Diff : Positions;
         Velocity_Diff : Velocities;
      end record;

   pragma Warnings ("H"); -- "<" hides a default operator in package Standard
   function "<" (L, R : Distance_Entries) return Boolean;
   pragma Warnings ("h");

   package Distance_Vectors is new Vectors (Swarm_Element_Index, Distance_Entries);

   package Sort_Distances is new Distance_Vectors.Generic_Sorting;

   type Buffer_Size_Outgoing is mod No_Of_Buffered_Outgoing_Messages;
   type Buffer_Size_Incoming is mod No_Of_Buffered_Incoming_Messages;

   package Buffers_Outgoing is new Generic_Realtime_Buffer (Inter_Vehicle_Messages, Buffer_Size_Outgoing);
   package Buffers_Incoming is new Generic_Realtime_Buffer (Inter_Vehicle_Messages, Buffer_Size_Incoming);

   use Buffers_Outgoing;
   use Buffers_Incoming;

   protected type Vehicle_Comms is
      procedure Send          (Message :     Inter_Vehicle_Messages);
      entry     Receive       (Message : out Inter_Vehicle_Messages);
      procedure Push_Message  (Message :     Inter_Vehicle_Messages);
      procedure Fetch_Message (Message : out Inter_Vehicle_Messages);
      function  Has_Incoming_Messages return Boolean;
      function  Has_Outgoing_Messages return Boolean;
   private
      Sent_Messages     : Buffers_Outgoing.Realtime_Buffer;
      Received_Messages : Buffers_Incoming.Realtime_Buffer;
   end Vehicle_Comms;

   protected type Vehicle_Controls is
      procedure Set_Steering (V : Vector_3D);
      procedure Set_Throttle (T : Throttle_T);
      function Read_Steering return Vector_3D;
      function Read_Throttle return Throttle_T;
   private
      Steering_Direction : Vector_3D  := Zero_Vector_3D;
      Throttle           : Throttle_T := Idle_Throttle;
   end Vehicle_Controls;

   type Globes_Touched_A is array (Energy_Globes_Defaults'Range) of Boolean;

   No_Globes_Touched : constant Globes_Touched_A := (others => False);

   package Protected_Time is new Generic_Protected (Time, Time_First);

   type Charge_Info is record
      Level          : Vehicle_Charges;            pragma Atomic (Level);
      Charge_Time    : Protected_Time.Monitor_Ptr;
      Charge_No      : Natural;                    pragma Atomic (Charge_No);
      Globes_Touched : Globes_Touched_A := No_Globes_Touched;
   end record;

   type Neighbours_P       is access all Distance_Vectors.Vector;
   type Vehicle_Comms_P    is access all Vehicle_Comms;
   type Vehicle_Controls_P is access all Vehicle_Controls;
   type Vehicle_Task_P     is access all Vehicle_Task;

   package Protected_Rotation is new Generic_Protected (Quaternion_Rotation, Zero_Rotation);

   type Swarm_Element_State is
      record
         Position      : Protected_Point_3D.Monitor_Ptr;
         Rotation      : Protected_Rotation.Monitor_Ptr;
         Velocity      : Protected_Vector_3D.Monitor_Ptr;
         Acceleration  : Protected_Vector_3D.Monitor_Ptr;
         Charge        : Charge_Info;
         Neighbours    : Neighbours_P;
         Controls      : Vehicle_Controls_P;
         Comms         : Vehicle_Comms_P;
         Process       : Vehicle_Task_P;
         Process_abort : Barrier_Ptr;
         Process_Id    : Task_Id;
         Vehicle_Id    : Positive;
         Last_Update   : Time;
      end record;

   package Swarm_Vectors is new Vectors (Swarm_Element_Index, Swarm_Element_State);

   procedure Free_Neighbours is new Unchecked_Deallocation (Object => Distance_Vectors.Vector, Name => Neighbours_P);
   procedure Free_Controls   is new Unchecked_Deallocation (Object => Vehicle_Controls,        Name => Vehicle_Controls_P);
   procedure Free_Comms      is new Unchecked_Deallocation (Object => Vehicle_Comms,           Name => Vehicle_Comms_P);
   procedure Free_Process    is new Unchecked_Deallocation (Object => Vehicle_Task,            Name => Vehicle_Task_P);

   protected Simulator_Tick is
      entry Wait_For_Next_Tick;
      procedure Tick;
   private
      Trigger : Boolean := False;
   end Simulator_Tick;

end Swarm_Structures;
