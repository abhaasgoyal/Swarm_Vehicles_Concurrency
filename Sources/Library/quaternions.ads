--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Real_Type; use Real_Type;

package Quaternions is

   type Quaternion_Real is record
      w, x, y, z : Real;
   end record;

   function "abs" (Quad : Quaternion_Real) return Real;
   function Unit  (Quad : Quaternion_Real) return Quaternion_Real;
   function Conj  (Quad : Quaternion_Real) return Quaternion_Real;
   function "-"   (Quad : Quaternion_Real) return Quaternion_Real;

   function "+"   (Left, Right : Quaternion_Real) return Quaternion_Real;
   function "-"   (Left, Right : Quaternion_Real) return Quaternion_Real;
   function "*"   (Left, Right : Quaternion_Real) return Quaternion_Real;
   function "/"   (Left, Right : Quaternion_Real) return Quaternion_Real;

   function "*"   (Left : Quaternion_Real; Right : Real)            return Quaternion_Real;
   function "/"   (Left : Quaternion_Real; Right : Real)            return Quaternion_Real;
   function "*"   (Left : Real;            Right : Quaternion_Real) return Quaternion_Real;
   function "/"   (Left : Real;            Right : Quaternion_Real) return Quaternion_Real;

   function Image (Quad : Quaternion_Real) return String;

end Quaternions;
