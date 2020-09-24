-----------------------------------------------------------------------------
 --  This file contains the body, please refer to specification (.ads file)
 -----------------------------------------------------------------------------

 -- with Interfaces;
 -- with Ada.Characters.Handling;           use Ada.Characters.Handling;

package body Game_Control is

   use GL;

   procedure Append_Commands (size_x,
                              size_y     :        Integer;                  -- screen dimensions for mouse
                              warp_mouse :        Boolean;                  -- recenter mouse cursor
                              c          : in out Command_set;              -- commands are added to c
                              gx, gy     :    out GL.Double;                -- mouse movement since last call
                              Keyboard   : access GLUT.Devices.Keyboard := GLUT.Devices.default_Keyboard'Access;
                              Mouse      : access GLUT.Devices.Mouse    := GLUT.Devices.default_Mouse'Access) is

      use GLUT.Devices;

      sensib : constant := 8.0;
      dx, dy : Integer;

   begin
      --------------
      -- Keyboard --
      --------------

      -- Clavier : !! lettres : clavier CH

      c (slide_mode) :=     Keyboard.all.modif_set (GLUT.Active_Alt);

      if c (slide_mode) then
         c (slide_up) :=       Keyboard.all.special_set (GLUT.KEY_PAGE_UP);
         c (slide_down) :=     Keyboard.all.special_set (GLUT.KEY_PAGE_DOWN);
      else
         c (turn_up) :=        Keyboard.all.special_set (GLUT.KEY_PAGE_UP);
         c (turn_down) :=      Keyboard.all.special_set (GLUT.KEY_PAGE_DOWN);
         c (slide_left) :=     Keyboard.all.normal_set ('A');
         c (slide_right) :=    Keyboard.all.normal_set ('D');
         c (slide_up) :=       Keyboard.all.normal_set ('R');
         c (slide_down) :=     Keyboard.all.normal_set ('F');
      end if;
      c (swing_plus) :=     Keyboard.all.normal_set ('E');
      c (swing_minus) :=    Keyboard.all.normal_set ('Q');
      c (special_plus) :=   Keyboard.all.normal_set ('+');
      c (special_minus) :=  Keyboard.all.normal_set ('-');
      c (jump) :=           Strike_once (' ', Keyboard);
      for i in n0 .. n9 loop
         c (i) := Strike_once (Character'Val (Command'Pos (i) - Command'Pos (n0) + Character'Pos ('0')),
                               Keyboard);
      end loop;

      c (photo) :=          Strike_once (GLUT.KEY_F12, Keyboard);
      c (video) :=          Strike_once (GLUT.KEY_F11, Keyboard);
      c (toggle_10) :=      Strike_once (GLUT.KEY_F10, Keyboard);

      c (interrupt_game) := Keyboard.all.normal_set (ASCII.ESC);
      c (go_forward) :=     Keyboard.all.special_set (GLUT.KEY_UP)
                    or else Keyboard.all.normal_set ('W');
      c (go_backwards) :=   Keyboard.all.special_set (GLUT.KEY_DOWN)
                    or else Keyboard.all.normal_set ('S');
      c (run_mode) :=       Keyboard.all.modif_set (GLUT.Active_Shift);
      c (ctrl_mode) :=      Keyboard.all.modif_set (GLUT.Active_Control);

      -----------
      -- Mouse --
      -----------

      if Mouse.all.button_state (GLUT.LEFT_BUTTON)  then
         c (go_forward) := True;
      end if;
      if Mouse.all.button_state (GLUT.RIGHT_BUTTON) then
         c (slide_mode) := True;
      end if;

      dx := Mouse.all.mx - Mouse.all.oldx;
      dy := Mouse.all.my - Mouse.all.oldy;
      gx := 0.0;
      gy := 0.0;
      if abs dx <= 100 and then abs dy <= 100 then
         -- ^ avoid window in/out movements
         if dx /= 0 then
            gx := sensib * GL.Double (dx) / GL.Double (size_x);
            case c (slide_mode) is
               when True  => c (slide_lateral_graduated) := True;
               when False => c (turn_lateral_graduated) := True;
            end case;
         end if;
         if dy /= 0 then
            gy := -sensib * GL.Double (dy) / GL.Double (size_y);
            case c (slide_mode) is
               when True  => c (slide_vertical_graduated) := True;
               when False => c (turn_vertical_graduated) := True;
            end case;
         end if;
      end if;

      if warp_mouse and then
        (abs (Mouse.all.mx - size_x / 2) > size_x / 4 or else abs (Mouse.all.my - size_y / 2) > size_y / 4)
      then
         Mouse.all.oldx := size_x / 2;
         Mouse.all.oldy := size_y / 2;
         GLUT.WarpPointer (Mouse.all.oldx, Mouse.all.oldy);
      else
         Mouse.all.oldx := Mouse.all.mx;
         Mouse.all.oldy := Mouse.all.my;
      end if;

      if c (slide_mode) then
         c (slide_left) :=     Keyboard.all.special_set (GLUT.KEY_LEFT);
         c (slide_right) :=    Keyboard.all.special_set (GLUT.KEY_RIGHT);
      else
         c (turn_left) :=      Keyboard.all.special_set (GLUT.KEY_LEFT);
         c (turn_right) :=     Keyboard.all.special_set (GLUT.KEY_RIGHT);
      end if;

   end Append_Commands;

end Game_Control;
