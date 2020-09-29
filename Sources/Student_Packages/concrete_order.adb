with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Text_IO;         use Ada.Text_IO;
package body Concrete_Order is
   No_Of_Elements : Natural range 0 .. Max_Length := 0;

   -- Typesafe find and replace
   Last : Natural renames Data (No_Of_Elements);

   procedure Add_To_List (E : Natural) is
   begin
      if List_Full then
         return;
      end if;
      for I in 1 .. No_Of_Elements + 1 loop
         if Data (I) = 0 then
            Data (I) := E;
         end if;
      end loop;
      No_Of_Elements := No_Of_Elements + 1;
   end Add_To_List;

   -- Additional functions
   function Found_In_List (E : Natural) return Boolean is
     (for some D of Read_List => D = E);

   function Max_Union (Input_Data : List) return List is
      I_Idx     : Data_Index        := 1;
      D_Idx     : Data_Index        := 1;
      Temp_Data : List (Data_Index) := (others => (0));
   begin
      Merge :
      for T of Temp_Data loop
         if Input_Data (I_Idx) = 0 and then Data (D_Idx) = 0 then
            exit Merge;
         elsif Input_Data (I_Idx) = 0 then
            T     := Data (D_Idx);
            D_Idx := D_Idx + 1;
         elsif Data (D_Idx) = 0 then
            T     := Input_Data (I_Idx);
            I_Idx := I_Idx + 1;
         else
            if Data (D_Idx) < Input_Data (I_Idx) then
               T     := Data (D_Idx);
               D_Idx := D_Idx + 1;
            elsif Data (D_Idx) = Input_Data (I_Idx) then
               T     := Data (D_Idx);
               D_Idx := D_Idx + 1;
               I_Idx := I_Idx + 1;
            else
               T     := Input_Data (I_Idx);
               I_Idx := I_Idx + 1;
            end if;
         end if;

      end loop Merge;
--      for T of Temp_Data loop
--       Put (T);
--      end loop;
      return Temp_Data;
   end Max_Union;
   function List_Full return Boolean is (No_Of_Elements = Max_Length);

   function Last_Element return Natural is (Last);

   -- Ada recognized 1 .. 0 in No_Of_Elements
   function Read_List return List is (Data);
   procedure Write_List (Input_Data : List) is
   begin
      Data           := Input_Data;
      No_Of_Elements := 0;
      Natural_Counter :
      for D of Data loop
         if D = 0 then
            exit Natural_Counter;
         else
            No_Of_Elements := No_Of_Elements + 1;
         end if;
      end loop Natural_Counter;
   end Write_List;
end Concrete_Order;
