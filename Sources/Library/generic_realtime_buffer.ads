--
-- Uwe R. Zimmer, Australia, July 2011
--

generic

   type Element is private;
   type Buffer_Index is mod <>;

package Generic_Realtime_Buffer is

   pragma Elaborate_Body;

   type Realtime_Buffer is private;

   procedure Put (B : in out Realtime_Buffer; Item :     Element);
   procedure Get (B : in out Realtime_Buffer; Item : out Element);

   function Element_Available (B : Realtime_Buffer) return Boolean;

   Calling_Get_On_Empty_Buffer : exception;

private

   type No_Of_Elements is new Natural range 0 .. Natural (Buffer_Index'Last) + 1;

   type Buffer_Array is array (Buffer_Index) of Element;

   type Realtime_Buffer is record
      Write_To,
      Read_From          : Buffer_Index   := Buffer_Index'First;
      Elements_In_Buffer : No_Of_Elements := 0;
      Buffer             : Buffer_Array;
   end record;

end Generic_Realtime_Buffer;
