--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with GL;                    use GL;
with GLOBE_3D;
with GLUT_2D;
with Graphics_FrameRates;   use Graphics_FrameRates;
with Graphics_Structures;   use Graphics_Structures;
with Rotations;             use Rotations;           pragma Elaborate_All (Rotations);
with Vectors_2D_N;          use Vectors_2D_N;
with Vectors_3D;            use Vectors_3D;

package Graphics_Configuration is

   Intented_Framerate : constant Hz := 30.0;

   Initial_Cams : constant array (Camera_Mode_T) of Camera :=
     (Scene => (Position      => Zero_Vector_3D,
                Scene_Offset  => (0.0, 0.00, 0.8),
                Object_Offset => Zero_Vector_3D,
                Rotation      => Zero_Rotation),
      Chase => (Position      => Zero_Vector_3D,
                Scene_Offset  => Zero_Vector_3D,
                Object_Offset => (0.0, 0.05, 0.1),
                Rotation      => Zero_Rotation));

   -- Stars --
   Number_Of_Stars   : constant Natural       := 20_000;
   Distance_of_Stars : constant GLOBE_3D.Real := 3.0;

   Initial_Viewer_Size : constant Size_2D := (x => 1280, y => 720);

      -- Camera Properties --
   Camera_Field_of_View        : constant GLOBE_3D.Real     := 70.0;
   Camera_Close_Clipping_Plane : constant GLOBE_3D.Real     := 0.01;
   Camera_Far_Clipping_Plane   : constant GLOBE_3D.Real     := 1000.0;
   Camera_Initial_Position     : constant GLOBE_3D.Point_3D := (0.0, 0.0, 0.0);

   Viewer_Title : constant String := "Swarm Viewer";

   Lighting_Strength : GL.C_Float := 0.9;

   Initial_Lights : constant Lights_T := (1 => (position => (-1.0, 1.0, 1.0, Lighting_Strength),
                                                ambient  => (0.1, 0.1, 0.1, Lighting_Strength),
                                                diffuse  => (0.9, 0.9, 0.9, Lighting_Strength),
                                                specular => (0.05, 0.05, 0.01, Lighting_Strength)),

                                          2 => (position => (1.0, 1.0, 1.0, Lighting_Strength),
                                                ambient  => (0.0, 0.0, 0.0, Lighting_Strength),
                                                diffuse  => (0.1, 0.1, 0.1, Lighting_Strength),
                                                specular => (1.0, 0.8, 0.8, Lighting_Strength))
                                         );

   Screen_Font : constant GLUT_2D.Font_type := GLUT_2D.Helvetica_10;

end Graphics_Configuration;
