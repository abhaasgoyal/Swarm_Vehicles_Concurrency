--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with GLOBE_3D;

with Real_Type;            use Real_Type;
with Rotations;             use Rotations;
with Vectors_2D_N;          use Vectors_2D_N;
with Vectors_3D;            use Vectors_3D;

package Graphics_Structures is

   type RGB  is (Red, Green, Blue);
   type RGBA is (Red, Green, Blue, Alpha);

   subtype Colour_Component_Range is Real range 0.0 .. 1.0;

   type RGB_Colour  is array (RGB)  of Colour_Component_Range;
   type RGBA_Colour is array (RGBA) of Colour_Component_Range;

   subtype Shininess_Range  is Real range 0.0 .. 128.0;

   type Materials is record
      Ambient,
      Diffuse,
      Specular,
      Emission  : RGBA_Colour;
      Shininess : Shininess_Range;
   end record;

   subtype Point_3D is Vector_3D;

   type Points_3D is array (Positive range <>)     of Point_3D;
   type Line_3D   is array (Positive range 1 .. 2) of Point_3D;

   type Camera is tagged
      record
         Position,
         Scene_Offset,
         Object_Offset : Vector_3D;
         Rotation      : Quaternion_Rotation;
      end record;

   subtype Point_2D is Vector_2D_N;
   subtype Size_2D  is Vector_2D_N;

   type Points_2D is array (Positive range <>)     of Point_2D;
   type Line_2D   is array (Positive range 1 .. 2) of Point_2D;

   type Camera_Mode_T is (Scene, Chase);

   type Lights_T is array (Positive range <>) of GLOBE_3D.Light_definition;

--  private
--
--     type RGB_Colour_F  is array (RGB)  of GL.Float;
--     type RGB_Colour_D  is array (RGB)  of GL.Double;
--     type RGBA_Colour_F is array (RGBA) of GL.Float;
--     type RGBA_Colour_D is array (RGBA) of GL.Double;
--
--     subtype Shininess_Range_F is GL.Float range 0.0 .. 128.0;
--
--     type Materials_F is record
--        Ambient,
--        Diffuse,
--        Specular,
--        Emission  : RGBA_Colour_F;
--        Shininess : Shininess_Range_F;
--     end record;

end Graphics_Structures;
