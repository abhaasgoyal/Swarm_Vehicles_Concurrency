package body Generic_Realtime_Buffer is

   ---------
   -- Put --
   ---------

   procedure Put (B : in out Realtime_Buffer; Item : Element) is

   begin
      if B.Elements_In_Buffer = No_Of_Elements'Last then
         B.Read_From := B.Read_From + 1;
      else
         B.Elements_In_Buffer := B.Elements_In_Buffer + 1;
      end if;
      B.Buffer (B.Write_To) := Item;
      B.Write_To := B.Write_To + 1;
   end Put;

   ---------
   -- Get --
   ---------

   procedure Get (B : in out Realtime_Buffer; Item : out Element) is

   begin
      if B.Elements_In_Buffer > 0 then
         Item                 := B.Buffer (B.Read_From);
         B.Read_From          := B.Read_From + 1;
         B.Elements_In_Buffer := B.Elements_In_Buffer - 1;
      else
         raise Calling_Get_On_Empty_Buffer;
      end if;
   end Get;

   -----------------------
   -- Element_Available --
   -----------------------

   function Element_Available (B : Realtime_Buffer) return Boolean is

   begin
      return B.Elements_In_Buffer > 0;
   end Element_Available;

end Generic_Realtime_Buffer;
