--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Real_Type; use Real_Type;
with Vectors_xD;                 pragma Elaborate_All (Vectors_xD);

package Vectors_2D is

   type xy_Coordinates is (x, y);

   package Vectors_2Di is new Vectors_xD (Real, xy_Coordinates);

   subtype Vector_2D is Vectors_2Di.Vector_xD;

   Zero_Vector_2D : constant Vector_2D := Vectors_2Di.Zero_Vector_xD;

   function Image (V : Vector_2D) return String renames Vectors_2Di.Image;

   function Norm (V : Vector_2D) return Vector_2D renames Vectors_2Di.Norm;

   function "*" (Scalar : Real; V : Vector_2D) return Vector_2D renames Vectors_2Di."*";
   function "*" (V : Vector_2D; Scalar : Real) return Vector_2D renames Vectors_2Di."*";
   function "/" (V : Vector_2D; Scalar : Real) return Vector_2D renames Vectors_2Di."/";

   function "*" (V_Left, V_Right : Vector_2D) return Real renames Vectors_2Di."*";

   function Angle_Between (V_Left, V_Right : Vector_2D) return Real renames Vectors_2Di.Angle_Between;

   function "+" (V_Left, V_Right : Vector_2D) return Vector_2D renames Vectors_2Di."+";
   function "-" (V_Left, V_Right : Vector_2D) return Vector_2D renames Vectors_2Di."-";
   function "-" (V : Vector_2D)               return Vector_2D renames Vectors_2Di."-";

   function "abs" (V : Vector_2D) return Real renames Vectors_2Di."abs";

   pragma Warnings (Off, "declaration of ""="" hides predefined operator");
   function "=" (V_Left, V_Right : Vector_2D) return Boolean renames Vectors_2Di."=";
   pragma Warnings (On, "declaration of ""="" hides predefined operator");

end Vectors_2D;
