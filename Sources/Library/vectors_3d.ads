--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Real_Type; use Real_Type;
with Vectors_xD;                 pragma Elaborate_All (Vectors_xD);

package Vectors_3D is

   type Coordinates is (x, y, z);

   package Vectors_3Di is new Vectors_xD (Real, Coordinates);

   subtype Vector_3D is Vectors_3Di.Vector_xD;

   Zero_Vector_3D : constant Vector_3D := Vectors_3Di.Zero_Vector_xD;

   function Image (V : Vector_3D) return String renames Vectors_3Di.Image;

   function Norm (V : Vector_3D) return Vector_3D renames Vectors_3Di.Norm;

   function "*" (Scalar : Real; V : Vector_3D) return Vector_3D renames Vectors_3Di."*";
   function "*" (V : Vector_3D; Scalar : Real) return Vector_3D renames Vectors_3Di."*";
   function "/" (V : Vector_3D; Scalar : Real) return Vector_3D renames Vectors_3Di."/";

   function "*" (V_Left, V_Right : Vector_3D) return Real renames Vectors_3Di."*";
   function "*" (V_Left, V_Right : Vector_3D) return Vector_3D;

   function Angle_Between (V_Left, V_Right : Vector_3D) return Real renames Vectors_3Di.Angle_Between;

   function "+" (V_Left, V_Right : Vector_3D) return Vector_3D renames Vectors_3Di."+";
   function "-" (V_Left, V_Right : Vector_3D) return Vector_3D renames Vectors_3Di."-";
   function "-" (V : Vector_3D)               return Vector_3D renames Vectors_3Di."-";

   function "abs" (V : Vector_3D) return Real renames Vectors_3Di."abs";

   pragma Warnings (Off, "declaration of ""="" hides predefined operator");
   function "=" (V_Left, V_Right : Vector_3D) return Boolean renames Vectors_3Di."=";
   pragma Warnings (On, "declaration of ""="" hides predefined operator");

end Vectors_3D;
