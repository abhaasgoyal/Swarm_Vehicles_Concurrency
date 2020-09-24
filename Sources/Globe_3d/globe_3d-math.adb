package body GLOBE_3D.Math is

   use Ada.Numerics;
   use REF;

   -------------
   -- Vectors --
   -------------

   function "*" (l : Real; v : Vector_3D) return Vector_3D is (l * v (0), l * v (1), l * v (2));

   function "*" (v : Vector_3D; l : Real) return Vector_3D is (l * v (0), l * v (1), l * v (2));

   function "+" (a, b : Vector_3D) return Vector_3D is (a (0) + b (0), a (1) + b (1), a (2) + b (2));

   function "-" (a : Vector_3D) return Vector_3D is (-a (0), -a (1), -a (2));

   function "-" (a, b : Vector_3D) return Vector_3D is (a (0) - b (0), a (1) - b (1), a (2) - b (2));

   function "*" (a, b : Vector_3D) return Real is (a (0) * b (0) + a (1) * b (1) + a (2) * b (2));

   function "*" (a, b : Vector_3D) return Vector_3D is (a (1) * b (2) - a (2) * b (1),
                                                        a (2) * b (0) - a (0) * b (2),
                                                        a (0) * b (1) - a (1) * b (0));

   function Norm (a : Vector_3D) return Real is (Sqrt (a (0) * a (0) + a (1) * a (1) + a (2) * a (2)));

   function Norm2 (a : Vector_3D) return Real is (a (0) * a (0) + a (1) * a (1) + a (2) * a (2));

   function Normalized (a : Vector_3D) return Vector_3D is (a * (1.0 / Norm (a)));

   -- Angles
   --

   function Angle (Point_1, Point_2, Point_3  : Vector_3D) return Real is

      Vector_1   : constant Vector_3D := Normalized (Point_1 - Point_2);
      Vector_2   : constant Vector_3D := Normalized (Point_3 - Point_2);
      Cos_Theta  : constant Real      := Vector_1 * Vector_2;

   begin
      case Cos_Theta >= 1.0 is
         when True  => return Pi;
         when False => return Arccos (Cos_Theta);
      end case;
   end Angle;

   function to_Degrees (Radians  : Real) return Real is (Radians * 180.0 / Pi);

   function to_Radians (Degrees  : Real) return Real is (Degrees * Pi / 180.0);

   --------------
   -- Matrices --
   --------------

   function "*" (A, B : Matrix_33) return Matrix_33 is

      AB : Matrix_33;

   begin
      for i in Matrix_33'Range (1) loop
         for j in Matrix_33'Range (2) loop
            declare
               r : Real := 0.0;
            begin
               for k in Matrix_33'Range (1) loop
                  r := r + (A (i, k) * B (k, j));
               end loop;
               AB (i, j) := r;
            end;
         end loop;
      end loop;
      return AB;
   end "*";

   function "*" (A : Matrix_33; x : Vector_3D) return Vector_3D is

      Ax : Vector_3D;

   begin
      for i in Matrix_33'Range (1) loop
         declare
            r : Real := 0.0;
         begin
            for j in Matrix_33'Range (2) loop
               r := r + A (i, j) * x (j - Matrix_33'First (2) + Vector_3D'First);
            end loop;
            Ax (i - Matrix_33'First (1) + Vector_3D'First) := r;
         end;
      end loop;
      return Ax;
   end "*";

   function "*" (A : Matrix_44; x : Vector_3D) return Vector_3D is

      type Vector_4D_Double is array (0 .. 3) of GL.Double;

      x_4D  : constant Vector_4D_Double := (x (0), x (1), x (2), 1.0);
      Ax    :          Vector_4D_Double;

   begin
      for i in Matrix_44'Range (1) loop
         declare
            r : Real := 0.0;
         begin
            for j in Matrix_44'Range (2) loop
               r := r + A (i, j) * x_4D (j - Matrix_44'First (1) + Vector_4D_Double'First);
            end loop;
            Ax (i - Matrix_44'First (1) + Vector_4D_Double'First) := r;
         end;
      end loop;
      return (Ax (0), Ax (1), Ax (2));
   end "*";

   function "*" (A : Matrix_44; x : Vector_3D) return Vector_4D is

      x_4D  : constant Vector_4D := (x (0), x (1), x (2), 1.0);
      Ax    :          Vector_4D;

   begin
      for i in Matrix_44'Range (1) loop
         declare
            r : Real := 0.0;
         begin
            for j in Matrix_44'Range (2) loop
               r := r + A (i, j) * x_4D (j - Matrix_44'First (1) + Vector_4D'First);
            end loop;
            Ax (i - Matrix_44'First (1) + Vector_4D'First) := r;
         end;
      end loop;
      return Ax;
   end "*";

   function Transpose (A : Matrix_33) return Matrix_33 is ((A (1, 1), A (2, 1), A (3, 1)),
                                                           (A (1, 2), A (2, 2), A (3, 2)),
                                                           (A (1, 3), A (2, 3), A (3, 3)));

   function Transpose (A : Matrix_44) return Matrix_44 is ((A (1, 1), A (2, 1), A (3, 1), A (4, 1)),
                                                           (A (1, 2), A (2, 2), A (3, 2), A (4, 2)),
                                                           (A (1, 3), A (2, 3), A (3, 3), A (4, 3)),
                                                           (A (1, 4), A (2, 4), A (3, 4), A (4, 4)));

   function Det (A : Matrix_33) return Real is   (A (1, 1) * A (2, 2) * A (3, 3)
                                                + A (2, 1) * A (3, 2) * A (1, 3)
                                                + A (3, 1) * A (1, 2) * A (2, 3)
                                                - A (3, 1) * A (2, 2) * A (1, 3)
                                                - A (2, 1) * A (1, 2) * A (3, 3)
                                                - A (1, 1) * A (3, 2) * A (2, 3));

   function XYZ_rotation (ax, ay, az : Real) return Matrix_33 is

      Mx, My, Mz : Matrix_33; c, s : Real;

   begin
      -- Around X
      c := Cos (ax);
      s := Sin (ax);
      Mx := ((1.0, 0.0, 0.0),
             (0.0,   c,  -s),
             (0.0,   s,   c));
      -- Around Y
      c := Cos (ay);
      s := Sin (ay);
      My := ((c,   0.0,  -s),
             (0.0, 1.0, 0.0),
             (s,   0.0,   c));
      -- Around Z
      c := Cos (az);
      s := Sin (az);
      Mz := ((c,    -s, 0.0),
             (s,     c, 0.0),
             (0.0, 0.0, 1.0));

      return Mz * My * Mx;

   end XYZ_rotation;

   function XYZ_rotation (v : Vector_3D) return Matrix_33 is (XYZ_rotation (v (0), v (1), v (2)));

   function Look_at (direction : Vector_3D) return Matrix_33 is

      v1, v2, v3 : Vector_3D;

   begin
      -- GL's look direction is the 3rd dimension (z)
      v3 := Normalized (direction);
      v2 := Normalized ((v3 (2), 0.0, -v3 (0)));
      v1 := v2 * v3;
      return (((v1 (0), v2 (0), v3 (0)),
               (v1 (1), v2 (1), v3 (1)),
               (v1 (2), v2 (2), v3 (2))));
   end Look_at;

   function sub_Matrix (Self                : Matrix;
                        start_Row, end_Row,
                        start_Col, end_Col  : Positive) return Matrix is

      the_sub_Matrix  : Matrix (1 .. end_Row - start_Row + 1,
                                1 .. end_Col - start_Col + 1);

   begin
      for Row in the_sub_Matrix'Range (1) loop
         for Col in the_sub_Matrix'Range (2) loop
            the_sub_Matrix (Row, Col) := Self (Row - the_sub_Matrix'First (1) + start_Row,
                                               Col - the_sub_Matrix'First (2) + start_Col);
         end loop;
      end loop;

      return the_sub_Matrix;
   end sub_Matrix;

   function Look_at (eye, center, up  : Vector_3D) return Matrix_33
   is
      forward  : constant Vector_3D := Normalized ((center (0) - eye (0),  center (1) - eye (1),  center (2) - eye (2)));
      side     : constant Vector_3D := Normalized (forward * up);
      new_up   : constant Vector_3D := side * forward;
   begin
      return ((side     (0),    side    (1),    side    (2)),
              (new_up   (0),    new_up  (1),    new_up  (2)),
              (-forward (0),   -forward (1),   -forward (2)));
   end Look_at;

   -- Following procedure is from Project Spandex, by Paul Nettle
   procedure Re_Orthonormalize (M : in out Matrix_33) is
      dot1, dot2, vlen : Real;
   begin
      dot1 := M (1, 1) * M (2, 1) + M (1, 2) * M (2, 2) + M (1, 3) * M (2, 3);
      dot2 := M (1, 1) * M (3, 1) + M (1, 2) * M (3, 2) + M (1, 3) * M (3, 3);

      M (1, 1) := M (1, 1) - dot1 * M (2, 1) - dot2 * M (3, 1);
      M (1, 2) := M (1, 2) - dot1 * M (2, 2) - dot2 * M (3, 2);
      M (1, 3) := M (1, 3) - dot1 * M (2, 3) - dot2 * M (3, 3);

      vlen := 1.0 / Sqrt   (M (1, 1) * M (1, 1)
                          + M (1, 2) * M (1, 2)
                          + M (1, 3) * M (1, 3));

      M (1, 1) := M (1, 1) * vlen;
      M (1, 2) := M (1, 2) * vlen;
      M (1, 3) := M (1, 3) * vlen;

      dot1 := M (2, 1) * M (1, 1) + M (2, 2) * M (1, 2) + M (2, 3) * M (1, 3);
      dot2 := M (2, 1) * M (3, 1) + M (2, 2) * M (3, 2) + M (2, 3) * M (3, 3);

      M (2, 1) := M (2, 1) - dot1 * M (1, 1) - dot2 * M (3, 1);
      M (2, 2) := M (2, 2) - dot1 * M (1, 2) - dot2 * M (3, 2);
      M (2, 3) := M (2, 3) - dot1 * M (1, 3) - dot2 * M (3, 3);

      vlen := 1.0 / Sqrt   (M (2, 1) * M (2, 1)
                          + M (2, 2) * M (2, 2)
                          + M (2, 3) * M (2, 3));

      M (2, 1) := M (2, 1) * vlen;
      M (2, 2) := M (2, 2) * vlen;
      M (2, 3) := M (2, 3) * vlen;

      M (3, 1) := M (1, 2) * M (2, 3) - M (1, 3) * M (2, 2);
      M (3, 2) := M (1, 3) * M (2, 1) - M (1, 1) * M (2, 3);
      M (3, 3) := M (1, 1) * M (2, 2) - M (1, 2) * M (2, 1);
   end Re_Orthonormalize;

   type Matrix_44_Zero_Based_Columnwise is array (0 .. 3, 0 .. 3) of aliased Real; -- for GL.MultMatrix
   pragma Convention (Fortran, Matrix_44_Zero_Based_Columnwise);  -- GL stores matrices columnwise

   M     : Matrix_44_Zero_Based_Columnwise; -- M is a global variable for a clean 'Access and for setting once 4th dim
   M_ptr : constant GL.doublePtr := M (0, 0)'Unchecked_Access;

   procedure Multiply_GL_Matrix (A : Matrix_33) is

   begin
      for i in 1 .. 3 loop
         for j in 1 .. 3 loop
            M (i - 1, j - 1) := A (i, j);
            --  Funny deformations .. .
            --  if j=2 then
            --    M (i - 1, j - 1) := 0.5 * A (i, j);
            --  end if;
         end loop;
      end loop;
      GL.MultMatrixd (M_ptr);
   end Multiply_GL_Matrix;

   procedure Set_GL_Matrix (A : Matrix_33) is
   begin
      GL.LoadIdentity;
      Multiply_GL_Matrix (A);
   end Set_GL_Matrix;

   -- Ada 95 Quality and Style Guide, 7.2.7:
   -- Tests for
   --
   -- (1) absolute "equality" to 0 in storage,
   -- (2) absolute "equality" to 0 in computation,
   -- (3) relative "equality" to 0 in storage, and
   -- (4) relative "equality" to 0 in computation:
   --
   --  abs X <= Float_Type'Model_Small                      -- (1)
   --  abs X <= Float_Type'Base'Model_Small                 -- (2)
   --  abs X <= abs X * Float_Type'Model_Epsilon            -- (3)
   --  abs X <= abs X * Float_Type'Base'Model_Epsilon       -- (4)

   function Almost_zero (x : Real) return Boolean is (abs x <= Real'Base'Model_Small);

   function Almost_zero (x : GL.C_Float) return Boolean is (abs x <= GL.C_Float'Base'Model_Small);

begin
   for i in 0 .. 2 loop
      M (i, 3) := 0.0;
      M (3, i) := 0.0;
   end loop;
   M (3, 3) := 1.0;
end GLOBE_3D.Math;
