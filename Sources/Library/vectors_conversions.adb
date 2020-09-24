with Real_Type; use Real_Type;

package body Vectors_Conversions is

   ------------------
   -- To_Vector_3D --
   ------------------

   function To_Vector_3D (V : Vector_3D_LF) return Vector_3D is
     (x => Real (V (x)),
      y => Real (V (y)),
      z => Real (V (z)));

   ---------------------
   -- To_Vector_3D_LF --
   ---------------------

   function To_Vector_3D_LF (V : Vector_3D) return Vector_3D_LF is
     (x => Long_Float (V (x)),
      y => Long_Float (V (y)),
      z => Long_Float (V (z)));

   ------------------
   -- To_Vector_2D --
   ------------------

   function To_Vector_2D (V : Vector_2D_I) return Vector_2D is
     (x => Real (V (x)),
      y => Real (V (y)));

   ------------------
   -- To_Vector_2D --
   ------------------

   function To_Vector_2D (V : Vector_2D_N) return Vector_2D is
     (x => Real (V (x)),
      y => Real (V (y)));

   ------------------
   -- To_Vector_2D --
   ------------------

   function To_Vector_2D (V : Vector_2D_P) return Vector_2D is
     (x => Real (V (x)),
      y => Real (V (y)));

end Vectors_Conversions;
