with Vectors_2D;    use Vectors_2D;
with Vectors_2D_I;  use Vectors_2D_I;
with Vectors_2D_N;  use Vectors_2D_N;
with Vectors_2D_P;  use Vectors_2D_P;
with Vectors_3D;    use Vectors_3D;
with Vectors_3D_LF; use Vectors_3D_LF;

package Vectors_Conversions is

   function To_Vector_3D    (V : Vector_3D_LF) return Vector_3D;
   function To_Vector_3D_LF (V : Vector_3D)    return Vector_3D_LF;

   function To_Vector_2D (V : Vector_2D_I) return Vector_2D;
   function To_Vector_2D (V : Vector_2D_N) return Vector_2D;
   function To_Vector_2D (V : Vector_2D_P) return Vector_2D;

end Vectors_Conversions;
