--
-- Uwe R. Zimmer, Australia, 2013
--

with Ada.Unchecked_Deallocation;

package Barrier_Type is

   protected type Barrier is

      entry     Wait;
      procedure Open;
      procedure Close;

   private
      Opened : Boolean := False;

   end Barrier;

   type Barrier_Ptr is access Barrier;

   procedure Free is
     new Ada.Unchecked_Deallocation (Object => Barrier, Name => Barrier_Ptr);

end Barrier_Type;
