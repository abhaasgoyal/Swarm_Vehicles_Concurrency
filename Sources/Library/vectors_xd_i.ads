--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

generic

   type Integer_Type is range <>;
   type Coordinates is (<>);

package Vectors_xD_I is

   pragma Elaborate_Body;

   type Vector_xD_I is array (Coordinates) of Integer_Type;

   Zero_Vector_xD : constant Vector_xD_I := (others => Integer_Type'First);

   function Image (V : Vector_xD_I) return String;

   function Norm (V : Vector_xD_I) return Vector_xD_I;

   function "*" (Scalar : Float; V : Vector_xD_I) return Vector_xD_I;
   function "*" (V : Vector_xD_I; Scalar : Float) return Vector_xD_I;
   function "/" (V : Vector_xD_I; Scalar : Float) return Vector_xD_I;

   function "*" (V_Left, V_Right : Vector_xD_I) return Float;

   function Angle_Between (V_Left, V_Right : Vector_xD_I) return Float;

   function "+" (V_Left, V_Right : Vector_xD_I) return Vector_xD_I;
   function "-" (V_Left, V_Right : Vector_xD_I) return Vector_xD_I;
   function "-" (V : Vector_xD_I)               return Vector_xD_I;

   function "abs" (V : Vector_xD_I) return Float;

end Vectors_xD_I;
