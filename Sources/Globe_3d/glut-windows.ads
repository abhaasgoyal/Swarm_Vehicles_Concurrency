------------------------------------------------------------------------------
--  File :            GLUT-Windows.ads
--  Description :     A Windowed viewer for GLOBE_3D, based on GLUT
--  Copyright (c) Gautier de Montmollin/Rod Kay 2006 .. 2008
------------------------------------------------------------------------------

-- tbd : - add new 'traits' for glutGet state data.
--      - generalise lighting, textures, game controls
--      - find way to fix visibilty when window is iconised (may be platform dependant).

-- with GL.Geometry;
-- with GL.skinned_Geometry;

with Game_Control;
with GLUT.Devices;

with Ada.Strings.Unbounded;

with GLOBE_3D;

package GLUT.Windows is

   procedure Initialize;   -- called before any other operation

   type Window is new GLOBE_3D.Window with private;
   type Window_view is access all Window'Class; pragma No_Strict_Aliasing (Window_view);

   procedure Define  (Self : in out Window);
   procedure Destroy (Self : in out Window);

   procedure Name_is (Self : in out Window; Now : String);
   function  Name    (Self :        Window) return String;

   overriding procedure Enable (Self : in out Window);

   overriding procedure Freshen (Self      : in out Window;
                      time_Step :        GLOBE_3D.Real;
                      Extras    :        GLOBE_3D.Visual_array := GLOBE_3D.null_Visuals);

   function is_Closed (Self : Window) return Boolean;

   -- objects
   --

   procedure Add (Self : in out Window; the_Object : GLOBE_3D.p_Visual);
   procedure Rid (Self : in out Window; the_Object : GLOBE_3D.p_Visual);

   function  object_Count (Self : Window) return Natural;

   no_such_Object  : exception;   -- raised when trying to 'rid' an object which has not been added to the Window.

   -- smoothing
   --

   type Smoothing_method is (None, Software, Hardware);

   function  Smoothing    (Self :        Window)                             return Smoothing_method;
   procedure Smoothing_is (Self : in out Window; Now : Smoothing_method);

   -- Status display
   --

   function  Show_Status (Self :        Window) return Boolean;
   procedure Show_Status (Self : in out Window;
                          Show :        Boolean := True);

   procedure Display_status (Self : in out Window;
                             sec  :        GLOBE_3D.Real);

   function Frames_per_second (Self : Window) return Float;

   -- Devices
   --

   function Keyboard (Self  : access Window'Class) return Devices.p_Keyboard;
   function Mouse    (Self  : access Window'Class) return Devices.p_Mouse;

private

   type natural_Array is array (Positive range 1 .. 123) of Natural;

   type Window is new GLOBE_3D.Window with
      record
         Name          : Ada.Strings.Unbounded.Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String ("globe3d glut window");
         glut_Window   : Integer;

         Objects       : GLOBE_3D.Visual_array (1 .. 5_000);
         object_Count  : Natural := 0;

         Smoothing     : Smoothing_method := Hardware;
         is_Visible    : Boolean          := True;
         is_Closed     : Boolean          := False;
         Show_Status   : Boolean          := True;

         main_size_x,
         main_size_y   : GL.Sizei;

         foggy            : Boolean                  := False;
         frontal_light    : GLOBE_3D.Light_definition;
         forget_mouse     : Natural                  := 0;
         full_screen      : Boolean                  := False;
         Alpha            : GL.Double                := 1.0;

         -- Timer management

         last_time  : Integer;
         sample     : natural_Array := (others => 0);
         Average    : GLOBE_3D.Real := 30.0;                                -- avg milliseconds
         new_scene  : Boolean      := True;

         game_command  : Game_Control.Command_set := Game_Control.no_command;

         -- Devices

         Keyboard  : aliased Devices.Keyboard;
         Mouse     : aliased Devices.Mouse;

         -- Video management

         is_capturing_Video  : Boolean := False;

      end record;

  -- pragma Linker_options ("-mwindows"); -- Suppress console window
end GLUT.Windows;
