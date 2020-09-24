--
-- Uwe R. Zimmer, Australia, 2013
--

with Ada.Unchecked_Deallocation;

generic

   type Element is private;
   Default_Value : Element;

package Generic_Protected is

   protected type Monitor is

      function Read return Element;

      procedure Write (E : Element);

      entry Wait_for_Update (E : out Element);

   private
      Value   : Element := Default_Value;
      Touched : Boolean := False;

   end Monitor;

   type Monitor_Ptr is access Monitor;

   function Allocate (Value : Element := Default_Value) return Monitor_Ptr;

   procedure Free is
     new Ada.Unchecked_Deallocation (Object => Monitor, Name => Monitor_Ptr);

end Generic_Protected;
