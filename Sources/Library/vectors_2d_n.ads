--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Vectors_xD_I; pragma Elaborate_All (Vectors_xD_I);

package Vectors_2D_N is

   type xy_Coordinates is (x, y);

   package Vectors_2Di is new Vectors_xD_I (Natural, xy_Coordinates);

   subtype Vector_2D_N is Vectors_2Di.Vector_xD_I;

   Zero_Vector_2D_N : constant Vector_2D_N := Vectors_2Di.Zero_Vector_xD;

   function Image (V : Vector_2D_N) return String renames Vectors_2Di.Image;

   function Norm (V : Vector_2D_N) return Vector_2D_N renames Vectors_2Di.Norm;

   function "*" (Scalar : Float; V : Vector_2D_N) return Vector_2D_N renames Vectors_2Di."*";
   function "*" (V : Vector_2D_N; Scalar : Float) return Vector_2D_N renames Vectors_2Di."*";
   function "/" (V : Vector_2D_N; Scalar : Float) return Vector_2D_N renames Vectors_2Di."/";

   function "*" (V_Left, V_Right : Vector_2D_N) return Float renames Vectors_2Di."*";

   function Angle_Between (V_Left, V_Right : Vector_2D_N) return Float renames Vectors_2Di.Angle_Between;

   function "+" (V_Left, V_Right : Vector_2D_N) return Vector_2D_N renames Vectors_2Di."+";
   function "-" (V_Left, V_Right : Vector_2D_N) return Vector_2D_N renames Vectors_2Di."-";
   function "-" (V : Vector_2D_N)               return Vector_2D_N renames Vectors_2Di."-";

   function "abs" (V : Vector_2D_N) return Float renames Vectors_2Di."abs";

   pragma Warnings (Off, "declaration of ""="" hides predefined operator");
   function "=" (V_Left, V_Right : Vector_2D_N) return Boolean renames Vectors_2Di."=";
   pragma Warnings (On, "declaration of ""="" hides predefined operator");

end Vectors_2D_N;
