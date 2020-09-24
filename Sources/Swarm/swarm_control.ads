--
-- Jan & Uwe R. Zimmer, Australia, 2013
--

with Ada.Task_Identification;  use Ada.Task_Identification;
with Barrier_Type;             use Barrier_Type;
with Real_Type;                use Real_Type;
with Swarm_Configuration;      use Swarm_Configuration;
with Swarm_Structures;         use Swarm_Structures;
with Swarm_Structures_Base;    use Swarm_Structures_Base;
with Vectors_3D;               use Vectors_3D;

package Swarm_Control is

   pragma Elaborate_Body;

   protected Swarm_Monitor is

      function Id_Task                return Swarm_Element_Index;
      function Id_Task (Id : Task_Id) return Swarm_Element_Index;

      function Position      (Id : Task_Id) return Protected_Point_3D.Monitor_Ptr;
      function Velocity      (Id : Task_Id) return Protected_Vector_3D.Monitor_Ptr;
      function Acceleration  (Id : Task_Id) return Protected_Vector_3D.Monitor_Ptr;
      function Controls      (Id : Task_Id) return Vehicle_Controls_P;
      function Comms         (Id : Task_Id) return Vehicle_Comms_P;
      function Charge        (Id : Task_Id) return Charge_Info;
      function Process_abort                return Barrier_Ptr;

      procedure Append_Random_Swarm (No_Of_Swarm_Elements : Positive  := Initial_No_of_Elements;
                                     Centre               : Positions := Initial_Swarm_Position;
                                     Volume_Edge_Length   : Real      := Initual_Edge_Length);

      procedure Remove_Vehicle (Element_Ix : Swarm_Element_Index);

      function Centre_Of_Gravity     return Vector_3D;
      function Mean_Velocity         return Vector_3D;
      function Mean_Velocity         return Real;
      function Maximal_Radius        return Real;
      function Mean_Radius           return Real;
      function Mean_Closest_Distance return Real;

   private
      Last_Vehicle_Id : Natural := 0;

   end Swarm_Monitor;

   Vehicle_could_not_be_created,
   Task_did_not_repond_to_Identfiy_Call,
   No_Such_Task : exception;

   procedure Remove_Vehicles (No_Of_Swarm_Elements : Positive  := 1);

   procedure Set_Acceleration (Element_Index : Swarm_Element_Index);
   procedure Set_All_Accelerations;

   procedure Forward_Messages (Element_Index : Swarm_Element_Index);
   procedure Forward_All_Messages;

   procedure Move_Element (Element_Index : Swarm_Element_Index);
   procedure Move_All_Elements;

   procedure Update_Rotation (Element_Index : Swarm_Element_Index);
   procedure Update_All_Rotations;

   procedure Remove_Empties;

end Swarm_Control;
