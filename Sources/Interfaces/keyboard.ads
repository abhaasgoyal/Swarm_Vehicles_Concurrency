--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with GLUT.Devices;

package Keyboard is

   type Complete_Command_Set is
     ( -- Special Commands --
      Move_Accelerator,
      Full_Screen,
      Reset_Camera,
      Screen_Shot,
      Toggle_Axis,
      Toggle_Lines,
      Text_Overlay,
      Space,
      -- Rotate --
      Rotate_Up,
      Rotate_Down,
      Rotate_Left,
      Rotate_Right,
      Rotate_CW,
      Rotate_AntiCW,
      -- Strafe --
      Strafe_Up,
      Strafe_Down,
      Strafe_Left,
      Strafe_Right,
      Strafe_Forward,
      Strafe_Backward,
      -- Swarm --
      Add_Vehicle,
      Remove_Vehicle);

   type Commands_Array is array (Complete_Command_Set) of Boolean;

   Command_Set_Reset : constant Commands_Array := (others => False);

   procedure Get_Keys (Commands          : in out Commands_Array;
                       Selected_Keyboard : access GLUT.Devices.Keyboard := GLUT.Devices.default_Keyboard'Access);

end Keyboard;
