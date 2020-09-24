--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

generic

   type Real is digits <>;
   type Coordinates is (<>);

package Vectors_xD is

   pragma Elaborate_Body;

   type Vector_xD is array (Coordinates) of Real;

   Zero_Vector_xD : constant Vector_xD := (others => 0.0);

   function Image (V : Vector_xD) return String;

   function Norm (V : Vector_xD) return Vector_xD;

   function "*" (Scalar : Real; V : Vector_xD) return Vector_xD;
   function "*" (V : Vector_xD; Scalar : Real) return Vector_xD;
   function "/" (V : Vector_xD; Scalar : Real) return Vector_xD;

   function "*" (V_Left, V_Right : Vector_xD) return Real;

   function Angle_Between (V_Left, V_Right : Vector_xD) return Real;

   function "+" (V_Left, V_Right : Vector_xD) return Vector_xD;
   function "-" (V_Left, V_Right : Vector_xD) return Vector_xD;
   function "-" (V : Vector_xD)               return Vector_xD;

   function "abs" (V : Vector_xD) return Real;

end Vectors_xD;
