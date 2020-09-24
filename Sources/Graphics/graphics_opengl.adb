--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Ada.Numerics;                      use Ada.Numerics;
with GL;
--  with GL.Materials;
with GLOBE_3D;
with GLOBE_3D.Math;                     use GLOBE_3D.Math;
with GLOBE_3D.Stars_sky;                pragma Elaborate_All (GLOBE_3D.Stars_sky);
with GLU;
with GLUT;
with GLUT_2D;
with Graphics_Configuration;            use Graphics_Configuration;
with Graphics_Setup;                    use Graphics_Setup;
with Vectors_2D_N;                      use Vectors_2D_N;

package body Graphics_OpenGL is

   use Real_Elementary_Functions;

   package Stars is new GLOBE_3D.Stars_sky (No_of_Stars => Number_Of_Stars,
                                            far_side    => Distance_of_Stars);

   ---------------------------
   -- To GL Rotation Matrix --
   ---------------------------

   function To_GL_Rotation (Quat_Rotation : Quaternion_Rotation) return GLOBE_3D.Matrix_33 is

      Rotation_Matrix : constant Matrix_3D := To_Matrix_3D_OpenGL (Roll  (Quat_Rotation),
                                                                   Pitch (Quat_Rotation),
                                                                   Yaw   (Quat_Rotation));
      GL_Matrix : GLOBE_3D.Matrix_33;

   begin
      for Column in 1 .. 3 loop
         for Row in 1 .. 3 loop
            GL_Matrix (Column, Row) := GL.Double (Rotation_Matrix (Column, Row));
         end loop;
      end loop;
      return GL_Matrix;
   end To_GL_Rotation;

   -----------------------
   -- To GL Vector Type --
   -----------------------

   function To_GL_Vector (In_Vector : Vector_3D) return GLOBE_3D.Vector_3D is
     (0 => GL.Double (In_Vector (x)),
      1 => GL.Double (In_Vector (y)),
      2 => GL.Double (In_Vector (z)));

   --
   --
   --

   function To_GL_Material_Float_vector (Colour : RGBA_Colour) return GL.Material_Float_vector is
     (0 => GL.C_Float (Colour (Red)),
      1 => GL.C_Float (Colour (Green)),
      2 => GL.C_Float (Colour (Blue)),
      3 => GL.C_Float (Colour (Alpha)));

   --

   procedure Set_Material (Material : Materials) is

   begin
      GL.Disable (GL.COLOR_MATERIAL);
      GL.Material (GL.FRONT_AND_BACK, GL.AMBIENT,   To_GL_Material_Float_vector (Material.Ambient));
      GL.Material (GL.FRONT_AND_BACK, GL.DIFFUSE,   To_GL_Material_Float_vector (Material.Diffuse));
      GL.Material (GL.FRONT_AND_BACK, GL.SPECULAR,  To_GL_Material_Float_vector (Material.Specular));
      GL.Material (GL.FRONT_AND_BACK, GL.EMISSION,  To_GL_Material_Float_vector (Material.Emission));
      GL.Material (GL.FRONT_AND_BACK, GL.SHININESS, GL.C_Float (Material.Shininess));
   end Set_Material;

   procedure Set_Colour   (Colour   : RGB_Colour) is

   begin
      null;
   end Set_Colour;

   procedure Set_Colour   (Colour   : RGBA_Colour) is

   begin
      GL.Disable (GL.LIGHTING);
      GL.Enable  (GL.COLOR_MATERIAL);
      GL.ColorMaterial (GL.FRONT_AND_BACK, GL.AMBIENT_AND_DIFFUSE);
      GL.Color (red   => GL.Double (Colour (Red)),
                green => GL.Double (Colour (Green)),
                blue  => GL.Double (Colour (Blue)),
                alpha => GL.Double (Colour (Alpha)));
   end Set_Colour;

   ----------------
   -- Set_Camera --
   ----------------

   procedure Position_Camera (Cam_Position : GLOBE_3D.Vector_3D;
                              Cam_Rotation : GLOBE_3D.Matrix_33;
                              Cam_Offset   : GLOBE_3D.Vector_3D) is

   begin
      GL.Clear  (GL.DEPTH_BUFFER_BIT);
      GL.Clear  (GL.COLOR_BUFFER_BIT);

      GL.Disable    (GL.LIGHTING);
      GL.Enable     (GL.DEPTH_TEST);
      GL.MatrixMode (GL.MODELVIEW);

      GL.LoadIdentity;
      GL.Translate       (-Cam_Offset);
      Multiply_GL_Matrix (Cam_Rotation);
      GL.Translate       (-Cam_Position);

      Stars.Display               (Cam_Rotation);

      GL.Enable   (GL.LIGHTING);
      GL.Enable   (GL.CULL_FACE);
      GL.CullFace (GL.BACK);
   end Position_Camera;

   --

--     procedure Position_Camera (Cam_Position : Vector_3D;
--                                Cam_Rotation : Quaternion_Rotation;
--                                Cam_Offset   : Vector_3D := Zero_Vector) is
--
--     begin
--        Position_Camera (To_GL_Vector   (Cam_Position),
--                         To_GL_Rotation (Cam_Rotation),
--                         To_GL_Vector   (Cam_Offset));
--     end Position_Camera;

   --

   procedure Position_Camera (C : Camera := Cam) is

   begin
      Position_Camera (To_GL_Vector   (C.Position + C.Scene_Offset),
                       To_GL_Rotation (C.Rotation),
                       To_GL_Vector   (C.Object_Offset));
   end Position_Camera;

   --

   ----------
   -- Draw --
   ----------
   procedure Draw (Draw_Object : GLOBE_3D.p_Object_3D) is

   begin
      GL.PushMatrix;
      GLOBE_3D.Display (Draw_Object.all, Eye.Clipper);
      GL.PopMatrix;
   end Draw;
   ------------------------------------
   -- Alternative Draw Input Options --
   ------------------------------------
   procedure Draw (Draw_Object        : GLOBE_3D.p_Object_3D;
                   In_Object_Position : GLOBE_3D.Vector_3D;
                   In_Object_Rotation : GLOBE_3D.Matrix_33) is
   begin
      Draw_Object.all.Centre   := In_Object_Position;
      Draw_Object.all.rotation := In_Object_Rotation;
      Draw (Draw_Object);
   end Draw;

   procedure Draw (Draw_Object : GLOBE_3D.p_Object_3D;
                   In_Object_Position : Vector_3D;
                   In_Object_Rotation : Quaternion_Rotation) is
   begin
      Draw (Draw_Object,
            To_GL_Vector   (In_Object_Position),
            To_GL_Rotation (In_Object_Rotation));
   end Draw;

   --
   --
   --

   procedure Draw_Lines (Points : Points_3D) is

   begin
      GL.GL_Begin (GL.LINES);
      GL.Vertex (To_GL_Vector (Points (Points'First)));
      for i in Points'First + 1 .. Points'Last loop
         GL.Vertex (To_GL_Vector (Points (i)));
      end loop;
      GL.GL_End;
   end Draw_Lines;

   procedure Draw_Line  (Line : Line_3D; Line_Radius : Real) is

      Cyl_Slices  : constant GL.Int    := 10;
      Cyl_Stacks  : constant GL.Int    := 1;
      Rad_to_Deg  : constant Real      := 360.0 / (2.0 * Pi);
      Cylinder    : constant Vector_3D := (0.0, 0.0, 1.0);
      Line_Vector : constant Vector_3D := Line (Line'Last) - Line (Line'First);
      Radius      : constant Vector_3D := Cylinder * Line_Vector;
      Tilt_Angle  : constant Real      := Rad_to_Deg * Angle_Between (Cylinder, Line_Vector);

      Quadratic : constant GLU.GLUquadricObjPtr := GLU.NewQuadric;

   begin
      GL.PushMatrix;
      GL.Translate (To_GL_Vector (Line (Line'First)));
      GL.Rotate    (GL.Double (Tilt_Angle), GL.Double (Radius (x)), GL.Double (Radius (y)), GL.Double (Radius (z)));
      GLU.QuadricOrientation (Quadratic, GLU.GLU_OUTSIDE);
      GLU.Cylinder (Quadratic,
                    GL.Double (Line_Radius),
                    GL.Double (Line_Radius),
                    GL.Double (abs (Line_Vector)),
                    Cyl_Slices,
                    Cyl_Stacks);
      GLU.QuadricOrientation (Quadratic, GLU.GLU_INSIDE);
      GLU.Disk (Quadratic, 0.0, GL.Double (Line_Radius), Cyl_Slices, Cyl_Stacks);
      GL.Translate (To_GL_Vector (Line_Vector));
      GLU.QuadricOrientation (Quadratic, GLU.GLU_OUTSIDE);
      GLU.Disk (Quadratic, 0.0, GL.Double (Line_Radius), Cyl_Slices, Cyl_Stacks);
      GL.PopMatrix;
      GLU.DeleteQuadric (Quadratic);
   end Draw_Line;

   --

   function Scale_RGB (In_Colour : RGBA_Colour; Scale : Colour_Component_Range) return RGBA_Colour is
     (Red   => In_Colour (Red)   * Scale,
      Green => In_Colour (Green) * Scale,
      Blue  => In_Colour (Blue)  * Scale,
      Alpha => In_Colour (Alpha));

   --

   procedure Draw_Laser (Line_Start, Line_End     : Vector_3D;
                         Beam_Radius, Aura_Radius : Real;
                         Beam_Colour              : RGBA_Colour) is

      Rendering_Steps : constant Positive               := 5;
      Max_Alpha       : constant Colour_Component_Range := 1.0;
      Min_Alpha       : constant Colour_Component_Range := 0.1;

      Laser_Material : constant Materials :=
        (Ambient   => (Red => 0.00, Green => 0.00, Blue => 0.00, Alpha => 1.00),
         Diffuse   => (Red => 0.59, Green => 0.67, Blue => 0.73, Alpha => 1.00),
         Specular  => (Red => 0.90, Green => 0.90, Blue => 0.90, Alpha => 1.00),
         Emission  => Beam_Colour,
         Shininess => 100.0);

      Beam_Material : Materials := Laser_Material;

      Radius     : Real                   := Beam_Radius;
      Beam_Alpha : Colour_Component_Range := 1.0;

   begin
      for Steps in 0 .. Rendering_Steps loop
         Beam_Alpha := Max_Alpha   - (Real (Steps) / Real (Rendering_Steps)) ** (1.0 / 2.0) * (Max_Alpha   - Min_Alpha);
         Radius     := Beam_Radius + (Real (Steps) / Real (Rendering_Steps))                * (Aura_Radius - Beam_Radius);

         Beam_Material.Diffuse  := (Scale_RGB (Laser_Material.Diffuse,  Beam_Alpha));
         Beam_Material.Specular := (Scale_RGB (Laser_Material.Specular, Beam_Alpha));
         Beam_Material.Emission := (Scale_RGB (Laser_Material.Emission, Beam_Alpha));

         Beam_Material.Ambient  (Alpha) := Beam_Alpha;
         Beam_Material.Diffuse  (Alpha) := Beam_Alpha;
         Beam_Material.Specular (Alpha) := Beam_Alpha;
         Beam_Material.Emission (Alpha) := Beam_Alpha;

         Set_Material (Beam_Material);
         Draw_Line ((Line_Start, Line_End), Radius);
      end loop;
   end Draw_Laser;

   --

   package body Cursor_Management is

      function Cursor return Point_2D is (Cursor_Pos);

      --

      procedure Home is

      begin
         Cursor_Pos := Home_Pos;
      end Home;

      --

      procedure Line_Feed is

      begin
         Cursor_Pos := (x => Home_Pos (x), y => Cursor_Pos (y) + Leading);
      end Line_Feed;

      --

      procedure Paragraph_Feed is

      begin
         Cursor_Pos := (x => Home_Pos (x), y => Cursor_Pos (y) + Paragraph_Spacing);
      end Paragraph_Feed;

      --

      procedure Indend (Set_x : Natural) is

      begin
         Cursor_Pos (x) := Set_x;
      end Indend;

   end Cursor_Management;

   procedure Text_2D (S : String; C : Point_2D := Cursor_Management.Cursor) is

   begin
      GLUT_2D.Text_output (GL.Int (C (x)),
                           GL.Int (C (y)),
                           GL.Sizei (GLUT.Get (GLUT.WINDOW_WIDTH)),
                           GL.Sizei (GLUT.Get (GLUT.WINDOW_HEIGHT)),
                           S,
                           Screen_Font);
   end Text_2D;

   --

   procedure Text_3D (S : String; P : Vector_3D) is

   begin
      GLUT_2D.Text_output (To_GL_Vector (P),
                           S,
                           Screen_Font);
   end Text_3D;

   ------------------
   -- Show Drawing --
   ------------------

   procedure Show_Drawing is
   begin
      GLUT.SwapBuffers;
   end Show_Drawing;

   -------------------
   -- Resize Window --
   -------------------

   procedure Resize_Window  (Size : Size_2D) is
   begin
      GLUT.ReshapeWindow (Width  => Size (x), Height => Size (y));
      Window_Resize (Size (x), Size (y));
   end Resize_Window;

   -----------------
   -- Move Window --
   -----------------

   procedure Move_Window (Position : Point_2D) is
   begin
      GLUT.PositionWindow (Position (x), Position (y));
   end Move_Window;

   -----------------
   -- Full Screen --
   -----------------

   package body Full_Screen_Mode is
      procedure Change_Full_Screen is

      begin
         case Full_Screen_State is
         when False =>
            Memoried_Viewer_Size := ((x => GLUT.Get (GLUT.WINDOW_WIDTH),
                                      y => GLUT.Get (GLUT.WINDOW_HEIGHT)));
            Memoried_Viewer_Position := ((x => GLUT.Get (GLUT.WINDOW_X),
                                          y => GLUT.Get (GLUT.WINDOW_Y)));
            GLUT.FullScreen;
            Window_Resize (Size_x => GLUT.Get (GLUT.WINDOW_WIDTH),
                           Size_y => GLUT.Get (GLUT.WINDOW_HEIGHT));
            GLUT.SetCursor (GLUT.CURSOR_NONE);

         when True =>
            Resize_Window (Memoried_Viewer_Size);
            Move_Window   (Memoried_Viewer_Position);
            GLUT.SetCursor (GLUT.CURSOR_INHERIT);
         end case;
         Full_Screen_State := not Full_Screen_State;
      end Change_Full_Screen;
   end Full_Screen_Mode;

end Graphics_OpenGL;
