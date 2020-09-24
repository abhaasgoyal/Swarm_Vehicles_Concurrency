--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with GLOBE_3D;
with Graphics_Configuration; use Graphics_Configuration;
with Graphics_Structures;    use Graphics_Structures;
with Models;                 use Models;
with Rotations;              use Rotations;              pragma Elaborate_All (Rotations);
with Vectors_3D;             use Vectors_3D;

package Graphics_Data is

   Default_Model : Model_Name := Spaceship;

   Camera_Mode : Camera_Mode_T := Scene;

   Cam : Camera := (Position      => Zero_Vector_3D,
                    Scene_Offset  => Zero_Vector_3D,
                    Object_Offset => Zero_Vector_3D,
                    Rotation      => Zero_Rotation);

   Eye         : GLOBE_3D.Camera;

   Viewer_Size : Size_2D := Initial_Viewer_Size;

   Full_Screen_State     : Boolean := False;
   Show_Text_Overlay     : Boolean := True;
   Show_Connecting_Lines : Boolean := False;
   Show_Axis             : Boolean := False;

   Current_Model : Model_Name := Default_Model;

   Sphere_Angles : Vector_3D := Zero_Vector_3D;

end Graphics_Data;
