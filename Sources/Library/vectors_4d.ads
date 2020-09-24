--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Real_Type; use Real_Type;
with Vectors_xD;                 pragma Elaborate_All (Vectors_xD);

package Vectors_4D is

   type xy_Coordinates is (x, y, z, t);

   package Vectors_4Di is new Vectors_xD (Real, xy_Coordinates);

   subtype Vector_4D is Vectors_4Di.Vector_xD;

   Zero_Vector_4D : constant Vector_4D := Vectors_4Di.Zero_Vector_xD;

   function Image (V : Vector_4D) return String renames Vectors_4Di.Image;

   function Norm (V : Vector_4D) return Vector_4D renames Vectors_4Di.Norm;

   function "*" (Scalar : Real; V : Vector_4D) return Vector_4D renames Vectors_4Di."*";
   function "*" (V : Vector_4D; Scalar : Real) return Vector_4D renames Vectors_4Di."*";
   function "/" (V : Vector_4D; Scalar : Real) return Vector_4D renames Vectors_4Di."/";

   function "*" (V_Left, V_Right : Vector_4D) return Real renames Vectors_4Di."*";

   function Angle_Between (V_Left, V_Right : Vector_4D) return Real renames Vectors_4Di.Angle_Between;

   function "+" (V_Left, V_Right : Vector_4D) return Vector_4D renames Vectors_4Di."+";
   function "-" (V_Left, V_Right : Vector_4D) return Vector_4D renames Vectors_4Di."-";
   function "-" (V : Vector_4D)               return Vector_4D renames Vectors_4Di."-";

   function "abs" (V : Vector_4D) return Real renames Vectors_4Di."abs";

   pragma Warnings (Off, "declaration of ""="" hides predefined operator");
   function "=" (V_Left, V_Right : Vector_4D) return Boolean renames Vectors_4Di."=";
   pragma Warnings (On, "declaration of ""="" hides predefined operator");

end Vectors_4D;
