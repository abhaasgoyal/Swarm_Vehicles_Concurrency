--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Vectors_xD; pragma Elaborate_All (Vectors_xD);

package Vectors_3D_LF is

   type Coordinates is (x, y, z);

   package Vectors_3Di is new Vectors_xD (Long_Float, Coordinates);

   subtype Vector_3D_LF is Vectors_3Di.Vector_xD;

   Zero_Vector_3D_LF : constant Vector_3D_LF := Vectors_3Di.Zero_Vector_xD;

   function Image (V : Vector_3D_LF) return String renames Vectors_3Di.Image;

   function Norm (V : Vector_3D_LF) return Vector_3D_LF renames Vectors_3Di.Norm;

   function "*" (Scalar : Long_Float; V : Vector_3D_LF) return Vector_3D_LF renames Vectors_3Di."*";
   function "*" (V : Vector_3D_LF; Scalar : Long_Float) return Vector_3D_LF renames Vectors_3Di."*";

   function "*" (V_Left, V_Right : Vector_3D_LF) return Long_Float renames Vectors_3Di."*";
   function "*" (V_Left, V_Right : Vector_3D_LF) return Vector_3D_LF;

   function Angle_Between (V_Left, V_Right : Vector_3D_LF) return Long_Float renames Vectors_3Di.Angle_Between;

   function "+" (V_Left, V_Right : Vector_3D_LF) return Vector_3D_LF renames Vectors_3Di."+";
   function "-" (V_Left, V_Right : Vector_3D_LF) return Vector_3D_LF renames Vectors_3Di."-";
   function "-" (V : Vector_3D_LF)               return Vector_3D_LF renames Vectors_3Di."-";

   function "abs" (V : Vector_3D_LF) return Long_Float renames Vectors_3Di."abs";

   pragma Warnings (Off, "declaration of ""="" hides predefined operator");
   function "=" (V_Left, V_Right : Vector_3D_LF) return Boolean renames Vectors_3Di."=";
   pragma Warnings (On, "declaration of ""="" hides predefined operator");

end Vectors_3D_LF;
