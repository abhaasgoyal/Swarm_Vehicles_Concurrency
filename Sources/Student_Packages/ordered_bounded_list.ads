generic
   type Element is (<>);
   Max_Length : Positive;
package Ordered_Bounded_List is

   subtype Data_Index is Positive range 1 .. Max_Length;
   type List is array (Data_Index range <>) of Element;
   Data : List (Data_Index) := (others => (Element'First));

end Ordered_Bounded_List;
