-----------------------------------------------------------------------------
 --  This file contains the body, please refer to specification (.ads file)
 -----------------------------------------------------------------------------

with Interfaces;
with GLUT.Windows;              use GLUT.Windows;
with Ada.Characters.Handling;   use Ada.Characters.Handling;
with System;
with Ada.Unchecked_Conversion;

package body GLUT.Devices is

   -- current_Window  : - for accessing the current GLUT window
   --                  - used by GLUT callbacks to determine the Window to which a callback event relates.
   --

   function current_Window return Windows.Window_view is

      function to_Window is new Ada.Unchecked_Conversion (System.Address, Windows.Window_view);

   begin
      return to_Window (GLUT.GetWindowData);
   end current_Window;

   -- Keyboard
   --

   function current_Keyboard return p_Keyboard is

      the_current_Window  : constant Windows.Window_view := current_Window;

   begin
      case the_current_Window = null is
         when True  => return default_Keyboard'Access;
         when False => return GLUT.Windows.Keyboard (the_current_Window);
      end case;
   end current_Keyboard;

   procedure Affect_modif_key (modif_code : Integer) is

      use Interfaces;
      m : constant Unsigned_32 := Unsigned_32 (modif_code);

   begin
      current_Keyboard.all.modif_set (GLUT.Active_Shift)   := (m and GLUT.Active_Shift)   /= 0;
      current_Keyboard.all.modif_set (GLUT.Active_Control) := (m and GLUT.Active_Control) /= 0;
      current_Keyboard.all.modif_set (GLUT.Active_Alt)     := (m and GLUT.Active_Alt)     /= 0;
   end Affect_modif_key;

   procedure Update_modifier_keys is

   begin
      Affect_modif_key (GLUT.GetModifiers);
      --  During a callback, GetModifiers may be called
      --  to determine the state of modifier keys
      --  when the keystroke generating the callback occurred.
   end Update_modifier_keys;

   -- GLUT Callback procedures --

   procedure Key_Pressed (k : GLUT.Key_type; x, y : Integer) is

   begin
      pragma Unreferenced (x, y);
      current_Keyboard.all.normal_set (To_Upper (Character'Val (k))) := True;   -- key k is pressed
      Update_modifier_keys;
   end Key_Pressed;

   procedure Key_Unpressed (k : GLUT.Key_type; x, y : Integer) is

   begin
      pragma Unreferenced (x, y);
      current_Keyboard.all.normal_set (To_Upper (Character'Val (k))) := False;  -- key k is unpressed
      Update_modifier_keys;
   end Key_Unpressed;

   procedure Special_Key_Pressed (k : Integer; x, y : Integer) is

   begin
      pragma Unreferenced (x, y);
      current_Keyboard.all.special_set (k) := True;  -- key k is pressed
      Update_modifier_keys;
   end Special_Key_Pressed;

   procedure Special_Key_Unpressed (k : Integer; x, y : Integer) is

   begin
      pragma Unreferenced (x, y);
      current_Keyboard.all.special_set (k) := False; -- key k is unpressed
      Update_modifier_keys;
   end Special_Key_Unpressed;

   -- Mouse
   --

   function current_Mouse return p_Mouse is

      the_current_Window  : constant Windows.Window_view := current_Window;

   begin
      case the_current_Window = null is
         when True  => return default_Mouse'Access;
         when False => return GLUT.Windows.Mouse (the_current_Window);
      end case;
   end current_Mouse;

   procedure Mouse_Event (button, state, x, y : Integer) is
      -- When a user presses and releases mouse buttons in the window,
      -- each press and each release generates a mouse callback.
   begin
      current_Mouse.all.mx := x;
      current_Mouse.all.my := y;
      if button in current_Mouse.all.button_state'Range then -- skip extra buttons (wheel, etc.)
         current_Mouse.all.button_state (button) := state = GLUT.DOWN; -- Joli, non ?
      end if;
      Update_modifier_keys;
   end Mouse_Event;

   procedure Motion (x, y : Integer) is
      --  The motion callback for a window is called when the mouse moves within the
      --  window while one or more mouse buttons are pressed.
   begin
      current_Mouse.all.mx := x;
      current_Mouse.all.my := y;
   end Motion;

   procedure Passive_Motion (x, y : Integer) is
      --  The passive motion callback for a window is called when
      --  the mouse moves within the window while no mouse buttons are pressed.
   begin
      current_Mouse.all.mx := x;
      current_Mouse.all.my := y;
   end Passive_Motion;

   -- Initialize
   --

   procedure Initialize is

--        use GLUT;

   begin
      IgnoreKeyRepeat (1);
      KeyboardFunc (Key_Pressed'Address);
      KeyboardUpFunc (Key_Unpressed'Address);
      SpecialFunc (Special_Key_Pressed'Address);
      SpecialUpFunc (Special_Key_Unpressed'Address);
      MouseFunc (Mouse_Event'Address);
      MotionFunc (Motion'Address);
      PassiveMotionFunc (Passive_Motion'Address);
   end Initialize;

   -- User input management
   --

   function Strike_once (c  :        Character;
                         kb : access Keyboard := default_Keyboard'Access) return Boolean is

   begin
      kb.all.normal_set_mem (c) := kb.all.normal_set (c);
      return kb.all.normal_set (c) and then not kb.all.normal_set_mem (c);
   end Strike_once;

   function Strike_once (special :        Integer;
                         kb      : access Keyboard := default_Keyboard'Access) return Boolean is

   begin
      kb.all.special_set_mem (special) := kb.all.special_set (special);
      return special in Special_key_set'Range
        and then kb.all.special_set (special) and then not kb.all.special_set_mem (special);
   end Strike_once;

end GLUT.Devices;
