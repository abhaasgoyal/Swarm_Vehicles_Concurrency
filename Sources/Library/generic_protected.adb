--
-- Uwe R. Zimmer, Australia, 2013
--

package body Generic_Protected is

   protected body Monitor is

      function Read return Element is (Value);

      procedure Write (E : Element) is

      begin
         Value   := E;
         Touched := True;
      end Write;

      entry Wait_for_Update (E : out Element) when Touched is

      begin
         E       := Value;
         Touched := Wait_for_Update'Count > 0;
      end Wait_for_Update;

   end Monitor;

   function Allocate (Value : Element := Default_Value) return Monitor_Ptr is

      New_Monitor : constant Monitor_Ptr := new Monitor;

   begin
      New_Monitor.all.Write (Value);
      return New_Monitor;
   end Allocate;

end Generic_Protected;
