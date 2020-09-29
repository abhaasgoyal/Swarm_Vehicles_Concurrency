with Ada.Real_Time; use Ada.Real_Time;
with Vectors_3D;    use Vectors_3D;
with Swarm_Size;    use Swarm_Size;
with Real_Type;     use Real_Type;
with Ordered_Bounded_List;
with Concrete_Order;
package Vehicle_Message_Type is
   package Abstract_List is new Ordered_Bounded_List
     (Max_Length => Target_No_of_Elements);

   package Temp_List is new Concrete_Order (Abstract_List);
   use Temp_List;
   use Abstract_List;
   type Inter_Vehicle_Messages is record
      Globe_Pos      : Vector_3D;
      Message_Time   : Time;
      List_Full_Time : Time := Time_First;
      Vehicle_List   : List (Data_Index);
      Vehicle_No     : Positive;
   end record;

end Vehicle_Message_Type;
