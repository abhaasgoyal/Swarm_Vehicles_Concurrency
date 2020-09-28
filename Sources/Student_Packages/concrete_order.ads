with Ordered_Bounded_List;

generic
   with package Ordered_Instance is new Ordered_Bounded_List (<>);
   use Ordered_Instance;
package Concrete_Order is

   function Add_To_List (E : Element) return Boolean;
   function List_Full return Boolean;
   function Last_Element return Element;
   function Read_List return List;
   function Found_In_List (E : Element) return Boolean;
   function Max_Union (Input_Data : List) return List;
end Concrete_Order;
