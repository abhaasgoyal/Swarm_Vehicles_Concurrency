--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Strings.Bounded;                       -- use Ada.Strings.Bounded;

package body Vectors_xD_I is

   package Real_Elementary_Functions is
     new Ada.Numerics.Generic_Elementary_Functions (Float);
   use Real_Elementary_Functions;

   package Strings_255 is new Ada.Strings.Bounded.Generic_Bounded_Length (Max => 255);
   use Strings_255;

   --

   function Image (V : Vector_xD_I) return String is

      Image_String : Strings_255.Bounded_String := Strings_255.Null_Bounded_String;

   begin
      Image_String := Image_String & '(';
      for Axes in Vector_xD_I'Range loop
         Image_String := Image_String & Integer_Type'Image (V (Axes));
         if Axes /= Vector_xD_I'Last then
            Image_String := Image_String & ", ";
         end if;
         Image_String := Image_String & ')';
      end loop;
      return To_String (Image_String);
   end Image;

   --

   function Norm (V : Vector_xD_I) return Vector_xD_I is

      Abs_V : constant Float := abs (V);

   begin
      if Abs_V = 0.0 then
         return Zero_Vector_xD;
      else
         return (V * (1.0 / Abs_V));
      end if;
   end Norm;

   --

   function "*" (Scalar : Float; V : Vector_xD_I) return Vector_xD_I is

      Scaled_V : Vector_xD_I;

   begin
      for Axis in Vector_xD_I'Range loop
         Scaled_V (Axis) := Integer_Type (Scalar * Float (V (Axis)));
      end loop;
      return Scaled_V;
   end "*";

   --

   function "*" (V : Vector_xD_I; Scalar : Float) return Vector_xD_I is (Scalar * V);

   --

   function "/" (V : Vector_xD_I; Scalar : Float) return Vector_xD_I is ((1.0 / Scalar) * V);

   --

   function "*" (V_Left, V_Right : Vector_xD_I) return Float is

      Dot : Float := 0.0;

   begin
      for Axis in Vector_xD_I'Range loop
         Dot := Dot + Float (V_Left (Axis)) * Float (V_Right (Axis));
      end loop;
      return Dot;
   end "*";

   --

   function Angle_Between (V_Left, V_Right : Vector_xD_I) return Float is

      Abs_Left  : constant Float := abs (V_Left);
      Abs_Right : constant Float := abs (V_Right);

   begin
      if Abs_Left = 0.0 and then Abs_Right = 0.0 then
         return 0.0;
      else
         return Arccos ((V_Left * V_Right) / (Abs_Left * Abs_Right));
      end if;
   end Angle_Between;

   --

   function "+" (V_Left, V_Right : Vector_xD_I) return Vector_xD_I is

      V_Result : Vector_xD_I;

   begin
      for Axis in Vector_xD_I'Range loop
         V_Result (Axis) := V_Left (Axis) + V_Right (Axis);
      end loop;
      return V_Result;
   end "+";

   --

   function "-" (V_Left, V_Right : Vector_xD_I) return Vector_xD_I is

      V_Result : Vector_xD_I;

   begin
      for Axis in Vector_xD_I'Range loop
         V_Result (Axis) := V_Left (Axis) - V_Right (Axis);
      end loop;
      return V_Result;
   end "-";

   --

   function "-" (V : Vector_xD_I) return Vector_xD_I is

      V_Result : Vector_xD_I;

   begin
      for Axis in Vector_xD_I'Range loop
         V_Result (Axis) := -V (Axis);
      end loop;
      return V_Result;
   end "-";

   --

   function "abs" (V : Vector_xD_I) return Float is

      Sum_Sqr : Float := 0.0;

   begin
      for Axis in Vector_xD_I'Range loop
         Sum_Sqr := Sum_Sqr + Float (V (Axis))**2;
      end loop;
      return Sqrt (Sum_Sqr);
   end "abs";

   --

end Vectors_xD_I;
