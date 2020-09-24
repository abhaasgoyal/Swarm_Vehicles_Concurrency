--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with GL.IO; use GL.IO;

package body Screenshots is

   Screen_Shot_Count : Positive := 1;

   ---------------
   -- Take_Shot --
   ---------------

   procedure Take_Shot is

   begin
      Screenshot (Integer'Image (Screen_Shot_Count) & ".bmp");
      Screen_Shot_Count := Screen_Shot_Count + 1;
   end Take_Shot;

end Screenshots;
