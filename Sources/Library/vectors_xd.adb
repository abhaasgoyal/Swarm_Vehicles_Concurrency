--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Ada.Numerics;                              -- use Ada.Numerics;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Strings.Bounded;                       -- use Ada.Strings.Bounded;

package body Vectors_xD is

   package Real_Elementary_Functions is
     new Ada.Numerics.Generic_Elementary_Functions (Real);
   use Real_Elementary_Functions;

   package Strings_255 is new Ada.Strings.Bounded.Generic_Bounded_Length (Max => 255);
   use Strings_255;

   --

   function Image (V : Vector_xD) return String is

      Image_String : Strings_255.Bounded_String := Strings_255.Null_Bounded_String;

   begin
      Image_String := Image_String & '(';
      for Axes in Vector_xD'Range loop
         Image_String := Image_String & Real'Image (V (Axes));
         if Axes /= Vector_xD'Last then
            Image_String := Image_String & ", ";
         end if;
      end loop;
      Image_String := Image_String & ')';
      return To_String (Image_String);
   end Image;

   --

   function Norm (V : Vector_xD) return Vector_xD is

      Abs_V : constant Real := abs (V);

   begin
      if Abs_V = 0.0 then
         return Zero_Vector_xD;
      else
         return (V * (1.0 / Abs_V));
      end if;
   end Norm;

   --

   function "*" (Scalar : Real; V : Vector_xD) return Vector_xD is

      Scaled_V : Vector_xD;

   begin
      for Axis in Vector_xD'Range loop
         Scaled_V (Axis) := Scalar * V (Axis);
      end loop;
      return Scaled_V;
   end "*";

   --

   function "*" (V : Vector_xD; Scalar : Real) return Vector_xD is (Scalar * V);

   --

   function "/" (V : Vector_xD; Scalar : Real) return Vector_xD is ((1.0 / Scalar) * V);

   --

   function "*" (V_Left, V_Right : Vector_xD) return Real is

      Dot : Real := 0.0;

   begin
      for Axis in Vector_xD'Range loop
         Dot := Dot + (V_Left (Axis) * V_Right (Axis));
      end loop;
      return Dot;
   end "*";

   --

   function Angle_Between (V_Left, V_Right : Vector_xD) return Real is

      Abs_Left  : constant Real := abs (V_Left);
      Abs_Right : constant Real := abs (V_Right);

   begin
      if Abs_Left = 0.0 or else Abs_Right = 0.0 then
         return 0.0;
      else
         return Arccos (Real'Max (-1.0, Real'Min (1.0, (V_Left * V_Right) / (Abs_Left * Abs_Right))));
      end if;
   end Angle_Between;

   --

   function "+" (V_Left, V_Right : Vector_xD) return Vector_xD is

      V_Result : Vector_xD;

   begin
      for Axis in Vector_xD'Range loop
         V_Result (Axis) := V_Left (Axis) + V_Right (Axis);
      end loop;
      return V_Result;
   end "+";

   --

   function "-" (V_Left, V_Right : Vector_xD) return Vector_xD is

      V_Result : Vector_xD;

   begin
      for Axis in Vector_xD'Range loop
         V_Result (Axis) := V_Left (Axis) - V_Right (Axis);
      end loop;
      return V_Result;
   end "-";

   --

   function "-" (V : Vector_xD) return Vector_xD is

      V_Result : Vector_xD;

   begin
      for Axis in Vector_xD'Range loop
         V_Result (Axis) := -V (Axis);
      end loop;
      return V_Result;
   end "-";

   --

   function "abs" (V : Vector_xD) return Real is

      Sum_Sqr : Real := 0.0;

   begin
      for Axis in Vector_xD'Range loop
         Sum_Sqr := Sum_Sqr + V (Axis)**2;
      end loop;
      return Sqrt (Sum_Sqr);
   end "abs";

   --

end Vectors_xD;
