with Ordered_Bounded_List;
with Swarm_Size; use Swarm_Size;

generic
   with package Ordered_Instance is new Ordered_Bounded_List (<>);
   use Ordered_Instance;
package Concrete_Order is
   type List is array (Data_Index range <>) of Natural;
   Data : List (Data_Index) := (others => (0));

   function Add_To_List (E : Natural) return Boolean;
   function List_Full return Boolean;
   function Last_Element return Natural;
   function Read_List return List;
   procedure Write_List (Input_Data : List);
   function Found_In_List (E : Natural) return Boolean;
   function Max_Union (Input_Data : List) return List;
end Concrete_Order;
