--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Real_Type;            use Real_Type;
with GLOBE_3D;
with Graphics_Data;         use Graphics_Data;
with Graphics_Structures;   use Graphics_Structures;
with Rotations;             use Rotations;
with Vectors_3D;            use Vectors_3D;

package Graphics_OpenGL is

   pragma Elaborate_Body;

   procedure Position_Camera (C : Camera := Cam);

   procedure Draw (Draw_Object        : GLOBE_3D.p_Object_3D;
                   In_Object_Position : Vector_3D;
                   In_Object_Rotation : Quaternion_Rotation);

   procedure Draw_Lines (Points : Points_3D);
   procedure Draw_Line  (Line : Line_3D; Line_Radius : Real);

   procedure Draw_Laser (Line_Start, Line_End     : Vector_3D;
                         Beam_Radius, Aura_Radius : Real;
                         Beam_Colour              : RGBA_Colour);

   package Cursor_Management is
      function Cursor return Point_2D;
      procedure Home;
      procedure Line_Feed;
      procedure Paragraph_Feed;
      procedure Indend (Set_x : Natural);
   private
      Leading           : constant Natural  := 12;
      Paragraph_Spacing : constant Natural  := Leading + 10;
      Home_Pos          : constant Point_2D := (2, 10);
      Cursor_Pos        :          Point_2D := Home_Pos;
   end Cursor_Management;

   procedure Text_2D (S : String; C : Point_2D := Cursor_Management.Cursor);
   procedure Text_3D (S : String; P : Vector_3D);

   procedure Show_Drawing;

   package Full_Screen_Mode is
      procedure Change_Full_Screen;
   private
      Memoried_Viewer_Size     : Size_2D;
      Memoried_Viewer_Position : Point_2D;
   end Full_Screen_Mode;

   procedure Set_Colour   (Colour   : RGB_Colour);
   procedure Set_Colour   (Colour   : RGBA_Colour);
   procedure Set_Material (Material : Materials);

end Graphics_OpenGL;
