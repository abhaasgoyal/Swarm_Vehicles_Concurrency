with Ordered_Bounded_List;

generic
   with package Ordered_Instance is new Ordered_Bounded_List (<>);
   use Ordered_Instance;
package Concrete_Order is
   type List is array (Data_Index range <>) of Natural;
   Data : List (Data_Index) := (others => (0));

   procedure Add_To_List (E : Natural);
   function List_Full return Boolean;
   function Read_List return List;
   procedure Write_List (Input_Data : List);
   function Found_In_List (E : Natural) return Boolean;
   procedure Max_Union (Input_Data : List);
end Concrete_Order;
