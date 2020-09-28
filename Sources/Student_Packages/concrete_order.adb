with Ada.Text_IO; use Ada.Text_IO;
package body Concrete_Order is
   No_Of_Elements : Natural range 0 .. Max_Length := 0;

   -- Typesafe find and replace
   Last : Element renames Data (Data_Index'Last);

   function Add_To_List (E : Element) return Boolean is
   begin
      if List_Full then
         return False;
      end if;
      for I in 1 .. No_Of_Elements + 1 loop
         if Data (I) = Element'First then
            Data (I) := E;
         end if;
      end loop;
      No_Of_Elements := No_Of_Elements + 1;

      return True;
   end Add_To_List;

   -- Additional functions
   function Found_In_List (E : Element) return Boolean is
     (for some D of Read_List => D = E);

   function Max_Union (Input_Data : List) return List is
      Input_Idx : Data_Index := Data_Index'First;
      Data_Idx  : Data_Index := Data_Index'First;
      Temp_Data : List (Data_Index);
   begin

      for T of Temp_Idx loop
         if Data (Data_Idx) < Input_Data (Input_Idx) then
            T        := Data (Data_Idx);
            Data_Idx := Data_Index'Succ (Data_Idx);
         else
            T         := Input_Data (Input_Idx);
            Input_Idx := Data_Index'Succ (Input_Idx);
         end if;
         exit when
           (Data_Idx > Data_Index'Last or else Input_Idx > Data_Index'Last);
      end loop;
      return Temp_Data;
   end Max_Union;
   function List_Full return Boolean is (No_Of_Elements = Max_Length);

   function Last_Element return Element is (Last);

   -- Ada recognized 1 .. 0 in No_Of_Elements
   function Read_List return List is (Data (1 .. No_Of_Elements));
end Concrete_Order;
