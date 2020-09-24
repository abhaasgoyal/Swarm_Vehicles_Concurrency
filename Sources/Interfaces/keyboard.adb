--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

package body Keyboard is

   -----------------------
   -- Keyboard Commands --
   -----------------------
   procedure Get_Keys (Commands : in out Commands_Array;
                       Selected_Keyboard : access GLUT.Devices.Keyboard := GLUT.Devices.default_Keyboard'Access) is

   begin
      if Selected_Keyboard.all.modif_set (GLUT.Active_Alt) then -- Alt Button Commands
         Commands (Full_Screen)      := Selected_Keyboard.all.normal_set ('F');
         Commands (Reset_Camera)     := Selected_Keyboard.all.normal_set ('C');
         Commands (Text_Overlay)     := Selected_Keyboard.all.normal_set ('T');
         Commands (Toggle_Axis)      := Selected_Keyboard.all.normal_set (',');
         Commands (Toggle_Lines)     := Selected_Keyboard.all.normal_set ('.');
         Commands (Screen_Shot)      := Selected_Keyboard.all.normal_set ('S');
      else
         Commands (Move_Accelerator) := Selected_Keyboard.all.modif_set (GLUT.Active_Shift);
         Commands (Space)            := Selected_Keyboard.all.normal_set (' ');
         -- Rotate Commands --
         Commands (Rotate_Up)        := Selected_Keyboard.all.normal_set ('I');
         Commands (Rotate_Down)      := Selected_Keyboard.all.normal_set ('K');
         Commands (Rotate_Left)      := Selected_Keyboard.all.normal_set ('J');
         Commands (Rotate_Right)     := Selected_Keyboard.all.normal_set ('L');
         Commands (Rotate_CW)        := Selected_Keyboard.all.normal_set ('O');
         Commands (Rotate_AntiCW)    := Selected_Keyboard.all.normal_set ('U');
         -- Strafe Commands --
         Commands (Strafe_Up)        := Selected_Keyboard.all.normal_set ('Q');
         Commands (Strafe_Down)      := Selected_Keyboard.all.normal_set ('E');
         Commands (Strafe_Left)      := Selected_Keyboard.all.normal_set ('A');
         Commands (Strafe_Right)     := Selected_Keyboard.all.normal_set ('D');
         Commands (Strafe_Forward)   := Selected_Keyboard.all.normal_set ('W');
         Commands (Strafe_Backward)  := Selected_Keyboard.all.normal_set ('S');
         -- Swarm
         Commands (Add_Vehicle)      := Selected_Keyboard.all.normal_set ('+');
         Commands (Remove_Vehicle)   := Selected_Keyboard.all.normal_set ('-');
      end if;
   end Get_Keys;

end Keyboard;
