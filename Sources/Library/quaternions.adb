--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Ada.Numerics.Generic_Elementary_Functions;

package body Quaternions is

   package Elementary_Functions is new Ada.Numerics.Generic_Elementary_Functions (Real);
   use Elementary_Functions;

   --

   function "abs" (Quad : Quaternion_Real) return Real is
     (Sqrt (Quad.w**2 + Quad.x**2 + Quad.y**2 + Quad.z**2));

   function Unit (Quad : Quaternion_Real) return Quaternion_Real is
     (Quad / abs (Quad));

   function Conj (Quad : Quaternion_Real) return Quaternion_Real is
     (w => Quad.w, x => -Quad.x, y => -Quad.y, z => -Quad.z);

   function "-" (Quad : Quaternion_Real) return Quaternion_Real is
     (w => -Quad.w, x => -Quad.x, y => -Quad.y, z => -Quad.z);

   function "+" (Left, Right : Quaternion_Real) return Quaternion_Real is
     (w => Left.w + Right.w, x => Left.x + Right.x,
      y => Left.y + Right.y, z => Left.z + Right.z);

   function "-" (Left, Right : Quaternion_Real) return Quaternion_Real is
     (w => Left.w - Right.w, x => Left.x - Right.x,
      y => Left.y - Right.y, z => Left.z - Right.z);

   function "*" (Left : Quaternion_Real; Right : Real) return Quaternion_Real is
     (w => Left.w * Right, x => Left.x * Right,
      y => Left.y * Right, z => Left.z * Right);

   function "*" (Left : Real; Right : Quaternion_Real) return Quaternion_Real is (Right * Left);

   function "/" (Left : Quaternion_Real; Right : Real) return Quaternion_Real is
     (w => Left.w / Right, x => Left.x / Right,
      y => Left.y / Right, z => Left.z / Right);

   function "/" (Left : Real; Right : Quaternion_Real) return Quaternion_Real is (Right / Left);

   function "*" (Left, Right : Quaternion_Real) return Quaternion_Real is
     (w => Left.w * Right.w - Left.x * Right.x - Left.y * Right.y - Left.z * Right.z,
      x => Left.w * Right.x + Left.x * Right.w + Left.y * Right.z - Left.z * Right.y,
      y => Left.w * Right.y - Left.x * Right.z + Left.y * Right.w + Left.z * Right.x,
      z => Left.w * Right.z + Left.x * Right.y - Left.y * Right.x + Left.z * Right.w);

   function "/" (Left, Right : Quaternion_Real) return Quaternion_Real is
     (w => Left.w * Right.w + Left.x * Right.x + Left.y * Right.y + Left.z * Right.z,
      x => Left.w * Right.x - Left.x * Right.w - Left.y * Right.z + Left.z * Right.y,
      y => Left.w * Right.y + Left.x * Right.z - Left.y * Right.w - Left.z * Right.x,
      z => Left.w * Right.z - Left.x * Right.y + Left.y * Right.x - Left.z * Right.w);

   function Image (Quad : Quaternion_Real) return String is
       (Real'Image (Quad.w) & " +"  &
        Real'Image (Quad.x) & "i +" &
        Real'Image (Quad.y) & "j +" &
        Real'Image (Quad.z) & "k");

   --

end Quaternions;
