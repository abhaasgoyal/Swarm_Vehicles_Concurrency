--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Real_Type; use Real_Type;

generic
   Dimension : Positive;

package Matrices is

   type Matrix is array (1 .. Dimension, 1 .. Dimension) of Real;

   -- function Image (Matrix : Matrix_3D) return String;

   function "*" (A, B : Matrix) return Matrix;

   function Transpose (M : Matrix) return Matrix;

end Matrices;
