--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

package Graphics_Setup is

   procedure Initialize_Graphics (Operations : access procedure);
   procedure Window_Resize (Size_x, Size_y : Integer);

end Graphics_Setup;
