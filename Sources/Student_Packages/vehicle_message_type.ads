with Ada.Real_Time; use Ada.Real_Time;
with Vectors_3D;    use Vectors_3D;
with Swarm_Size;    use Swarm_Size;
with Ordered_Bounded_List;
with Real_Type;     use Real_Type;
package Vehicle_Message_Type is
   package Abstract_List is new Ordered_Bounded_List
     (Element => Natural, Max_Length => Target_No_of_Elements);
   use Abstract_List;
   --   package Local_List is new Concrete_Order (Abstract_Ordered_List);
   type Inter_Vehicle_Messages is record
      Globe_Pos      : Vector_3D;
      Message_Time   : Time;
      List_Full_Time : Time := Time_First;
      Vehicle_List   : List (Data_Index);
      Vehicle_No     : Positive;
   end record;

end Vehicle_Message_Type;
