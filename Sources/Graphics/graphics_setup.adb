--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Ada.Numerics;                      use Ada.Numerics;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

with Graphics_Configuration;            use Graphics_Configuration;
with Graphics_Data;                     use Graphics_Data;

with GL;

with GLOBE_3D;
--  with GLOBE_3D.Textures;

with GLU;
with GLUT;                              use GLUT;
with GLUT.Devices;

with Vectors_2D_N;                      use Vectors_2D_N;

package body Graphics_Setup is

   Deg_2_Rad : constant := Pi / 180.0;

   ------------------
   -- Clear For 3D --
   ------------------

   procedure Reset_for_3D is

      use GL;

      Aspect_Ratio       : constant GL.Double := GL.Double (Viewer_Size (x)) / GL.Double (Viewer_Size (y));
      Half_Field_of_View : Float := 0.5 * Float (Eye.FOVy) * Deg_2_Rad; -- In Radians

   begin
      if Aspect_Ratio > 1.0 then -- If Wider than High
         Half_Field_of_View := Arctan (Float (Aspect_Ratio) * Tan (Float (Eye.FOVy)));
      end if;
      Eye.Clipper.max_dot_product := GLOBE_3D.Real (Sin (Half_Field_of_View));
      Eye.Clipper.main_clipping := (0, 0, Viewer_Size (x) - 1, Viewer_Size (y) - 1);

      GL.Viewport (0, 0, GL.Sizei (Viewer_Size (x)), GL.Sizei (Viewer_Size (y)));
      GL.MatrixMode (GL.PROJECTION);
      GL.LoadIdentity;

      GLU.Perspective (fovy   => Eye.FOVy, -- Field of View in the Y
                       aspect => Aspect_Ratio,
                       zNear  => Camera_Close_Clipping_Plane,
                       zFar   => Camera_Far_Clipping_Plane);

      GL.MatrixMode (GL.MODELVIEW);
      GL.ShadeModel (GL.SMOOTH);           -- Smooth vs. Flat
      GL.ClearColor (0.0, 0.0, 0.07, 0.0); -- Clear Value for Colour Buffer
      GL.ClearAccum (0.0, 0.0, 0.0, 0.0);  -- Clear Value for Accumulation Buffer
   end Reset_for_3D;

   --------------------
   -- Window Resized --
   --------------------

   procedure Window_Resize (Size_x, Size_y : Integer) is

   begin
      Viewer_Size := ((x => Size_x, y => Size_y));
      Reset_for_3D;
   end Window_Resize;

   ----------------------
   -- Initialize Video --
   -----------------------

--     Actual_LINE_WIDTH : aliased GL.Float;

   procedure Initialize_Graphics (Operations : access procedure) is

      GLUT_Options : constant Unsigned := GLUT.DOUBLE or GLUT.RGB or GLUT.DEPTH;
      Error : Integer; pragma Unreferenced (Error);

   begin
--        GLOBE_3D.Set_global_data_name ("Textures.zip");
--        GLOBE_3D.Textures.Register_textures_from_resources;

      Eye.FOVy := Camera_Field_of_View;

      -- GLUT Stuff --
      -- Get a Window with the correct properties --
      GLUT.Init;
      GLUT.InitDisplayMode (GLUT_Options);
      GLUT.InitWindowSize (Viewer_Size (x), Viewer_Size (y));
      GLUT.InitWindowPosition (0, 50);
      Error := GLUT.CreateWindow (Viewer_Title);

      -- Feedback Procedures --
      GLUT.ReshapeFunc (Window_Resize'Address);
      GLUT.DisplayFunc (Operations.all'Address);
      GLUT.IdleFunc (Operations.all'Address);

      GLUT.Devices.Initialize;

      -- GL Stuff --
      -- Clear Modes --
      GL.Disable (GL.BLEND);
      GL.Disable (GL.LIGHTING);
      GL.Disable (GL.AUTO_NORMAL);
      GL.Disable (GL.NORMALIZE);
      GL.Disable (GL.DEPTH_TEST);

      Reset_for_3D;

      -- Enable Lighting --
      GL.Enable (GL.LIGHTING);
      for Source in Initial_Lights'Range loop
         GLOBE_3D.Define (Source, Initial_Lights (Source));
         GLOBE_3D.Switch_light (Source, True);
      end loop;

      -- Reset Eye
      Eye.Clipper.Eye_Position := Camera_Initial_Position;
      Eye.World_Rotation       := GLOBE_3D.Id_33;
      Eye.FOVy                 := Camera_Field_of_View;

--        GL.GetFloatv (GL.LINE_WIDTH_RANGE, Actual_LINE_WIDTH'Access);
--        Put ("Actual_LINE_WIDTH: "); Put (Float (Actual_LINE_WIDTH), 3, 2, 0);
   end Initialize_Graphics;

   --

end Graphics_Setup;
