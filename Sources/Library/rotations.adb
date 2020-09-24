--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Ada.Numerics; use Ada.Numerics;

package body Rotations is

   use Real_Elementary_Functions;

   function To_Radiants (A : Degrees) return Radiants is ((A / 180.0) * Pi);

   --

   function To_Degrees (A : Radiants) return Degrees is ((A / Pi) * 180.0);

   --

   function Zero_Rotation return Quaternion_Rotation is (To_Rotation (0.0, 0.0, 0.0));

   --

   function Inverse (Quad : Quaternion_Rotation) return Quaternion_Rotation is (Conj (Quad));

   --

   function To_Quaternion (Input_Vector : Vector_3D) return Quaternion_Rotation is
     (w => 0.0,
      x => Input_Vector (x),
      y => Input_Vector (y),
      z => Input_Vector (z));

   --

   function To_Rotation (Axis : Vector_3D; Rotation_Angle : Radiants) return Quaternion_Rotation is

      Sin_Rotation_Half : constant Real := Sin (Rotation_Angle / 2.0);
      Cos_Rotation_Half : constant Real := Cos (Rotation_Angle / 2.0);

   begin
      return (w => Cos_Rotation_Half,
              x => Sin_Rotation_Half * Axis (x),
              y => Sin_Rotation_Half * Axis (y),
              z => Sin_Rotation_Half * Axis (z)
             );
   end To_Rotation;

   --

   function To_Rotation (Roll_Angle, Pitch_Angle, Yaw_Angle : Radiants) return Quaternion_Rotation is

      Sin_R : constant Real := Sin (Roll_Angle  / 2.0); Cos_R : constant Real := Cos (Roll_Angle  / 2.0);
      Sin_P : constant Real := Sin (Pitch_Angle / 2.0); Cos_P : constant Real := Cos (Pitch_Angle / 2.0);
      Sin_Y : constant Real := Sin (Yaw_Angle   / 2.0); Cos_Y : constant Real := Cos (Yaw_Angle   / 2.0);

   begin
      return (w => Cos_R * Cos_P * Cos_Y - Sin_R * Sin_P * Sin_Y,
              x => Cos_R * Sin_P * Sin_Y + Sin_R * Cos_P * Cos_Y,
              y => Cos_R * Cos_P * Sin_Y + Sin_R * Sin_P * Cos_Y,
              z => Cos_R * Sin_P * Cos_Y - Sin_R * Cos_P * Sin_Y
             );
   end To_Rotation;

   --

   function To_Rotation (Matrix : Matrix_3D) return Quaternion_Rotation is

      m : Matrix_3D renames Matrix;

      q : Quaternion_Rotation :=
        (w => Sqrt (Real'Max (0.0, 1.0 + m (1, 1) + m (2, 2) + m (3, 3))) / 2.0,
         x => Sqrt (Real'Max (0.0, 1.0 + m (1, 1) - m (2, 2) - m (3, 3))) / 2.0,
         y => Sqrt (Real'Max (0.0, 1.0 - m (1, 1) + m (2, 2) - m (3, 3))) / 2.0,
         z => Sqrt (Real'Max (0.0, 1.0 - m (1, 1) - m (2, 2) + m (3, 3))) / 2.0);

      q_max : constant Real := Real'Max (q.w, Real'Max (q.x, Real'Max (q.y, q.z)));

      function Copy_Sign (Value, Sign : Real) return Real is

      begin
         if Sign >= 0.0 then
            return +abs (Value);
         else
            return -abs (Value);
         end if;
      end Copy_Sign;

   begin
      if q.w = q_max then
         q.x := Copy_Sign (q.x, (m (3, 2) - m (2, 3)));
         q.y := Copy_Sign (q.y, (m (1, 3) - m (3, 1)));
         q.z := Copy_Sign (q.z, (m (2, 1) - m (1, 2)));
      elsif q.x = q_max then
         q.w := Copy_Sign (q.w, (m (3, 2) - m (2, 3)));
         q.y := Copy_Sign (q.y, (m (2, 1) + m (1, 2)));
         q.z := Copy_Sign (q.z, (m (1, 3) + m (3, 1)));
      elsif q.y = q_max then
         q.w := Copy_Sign (q.w, (m (1, 3) - m (3, 1)));
         q.x := Copy_Sign (q.x, (m (2, 1) + m (1, 2)));
         q.z := Copy_Sign (q.z, (m (3, 2) + m (2, 3)));
      elsif q.z = q_max then
         q.w := Copy_Sign (q.w, (m (2, 1) - m (1, 2)));
         q.x := Copy_Sign (q.x, (m (3, 1) + m (1, 3)));
         q.y := Copy_Sign (q.y, (m (3, 2) + m (2, 3)));
      end if;

      return Unit (q);
   end To_Rotation;

   --

   function To_Rotation (Matrix : Matrix_4D) return Quaternion_Rotation is

      m : Matrix_4D renames Matrix;

      q : Quaternion_Rotation :=
        (w => Sqrt (Real'Max (0.0, 1.0 + m (1, 1) + m (2, 2) + m (3, 3))) / 2.0,
         x => Sqrt (Real'Max (0.0, 1.0 + m (1, 1) - m (2, 2) - m (3, 3))) / 2.0,
         y => Sqrt (Real'Max (0.0, 1.0 - m (1, 1) + m (2, 2) - m (3, 3))) / 2.0,
         z => Sqrt (Real'Max (0.0, 1.0 - m (1, 1) - m (2, 2) + m (3, 3))) / 2.0);

      q_max : constant Real := Real'Max (q.w, Real'Max (q.x, Real'Max (q.y, q.z)));

      function Copy_Sign (Value, Sign : Real) return Real is

      begin
         if Sign >= 0.0 then
            return +abs (Value);
         else
            return -abs (Value);
         end if;
      end Copy_Sign;

   begin
      if q.w = q_max then
         q.x := Copy_Sign (q.x, (m (3, 2) - m (2, 3)));
         q.y := Copy_Sign (q.y, (m (1, 3) - m (3, 1)));
         q.z := Copy_Sign (q.z, (m (2, 1) - m (1, 2)));
      elsif q.x = q_max then
         q.w := Copy_Sign (q.x, (m (3, 2) - m (2, 3)));
         q.y := Copy_Sign (q.y, (m (2, 1) + m (1, 2)));
         q.z := Copy_Sign (q.z, (m (1, 3) + m (3, 1)));
      elsif q.y = q_max then
         q.w := Copy_Sign (q.x, (m (1, 3) - m (3, 1)));
         q.x := Copy_Sign (q.y, (m (2, 1) + m (1, 2)));
         q.z := Copy_Sign (q.z, (m (3, 2) + m (2, 3)));
      elsif q.z = q_max then
         q.w := Copy_Sign (q.x, (m (2, 1) - m (1, 2)));
         q.x := Copy_Sign (q.y, (m (3, 1) + m (1, 3)));
         q.y := Copy_Sign (q.z, (m (3, 2) + m (2, 3)));
      end if;

      return Unit (q);
   end To_Rotation;

   --

   function To_Vector (Quat : Quaternion_Rotation) return Vector_3D is
     (x => Quat.x,
      y => Quat.y,
      z => Quat.z);

   --

   function Rotate (Current_Rotation, Additional_Rotation : Quaternion_Rotation) return Quaternion_Rotation is

   begin
      return Additional_Rotation * Current_Rotation;
   end Rotate;

   function Unit_Vector (Axis : Vector) return Vector is

      Axis_Length : constant Real      := Sqrt (Axis (x)**2 + Axis (y)**2 + Axis (z)**2);
      Unit_Axis   : constant Vector_3D := (Axis (x) / Axis_Length,
                                           Axis (y) / Axis_Length,
                                           Axis (z) / Axis_Length);

   begin
      return Unit_Axis;
   end Unit_Vector;

   function Rotate (Current_Rotation : Quaternion_Rotation; Rotation_Axis : Vector; Rotation_Angle : Radiants) return Quaternion_Rotation is

      Rotation_Q : constant Quaternion_Rotation := To_Rotation (Unit_Vector (Rotation_Axis), Rotation_Angle);

   begin
      return Rotate (Current_Rotation, Rotation_Q);
   end Rotate;

   --

   function Rotate    (Current_Vector, Rotation_Axis : Vector_3D;
                       Rotation_Angle     : Radiants) return Vector_3D is

      Rotation_Q : constant Quaternion_Rotation := To_Rotation (Unit_Vector (Rotation_Axis), Rotation_Angle);

   begin
      return To_Vector (Conj (Rotation_Q) * To_Quaternion (Current_Vector) * Rotation_Q);
--        return To_Vector (Rotation_Q * To_Quaternion (Current_Vector) * Conj (Rotation_Q));
   end Rotate;

   --

   function Rotate (Current_Vector : Vector; Apply_Rotation : Quaternion_Rotation) return Vector is

   begin
      return To_Vector (Conj (Apply_Rotation) * To_Quaternion (Current_Vector) * Apply_Rotation);
--        return To_Vector (Apply_Rotation * To_Quaternion (Current_Vector) * Conj (Apply_Rotation));
   end Rotate;

   --

   function To_Matrix_3D (Quad : Quaternion_Rotation) return Matrix_3D is

      x  :          Real renames Quad.x;
      y  :          Real renames Quad.y;
      z  :          Real renames Quad.z;
      w  :          Real renames Quad.w;
      x2 : constant Real := x * x;
      y2 : constant Real := y * y;
      z2 : constant Real := z * z;
      xw : constant Real := x * w;
      yw : constant Real := y * w;
      zw : constant Real := z * w;
      xy : constant Real := x * y;
      xz : constant Real := x * z;
      yz : constant Real := y * z;

      Matrix : constant Matrix_3D :=
        ((1.0 - 2.0 * (y2 + z2),       2.0 * (xy - zw),       2.0 * (xz + yw)),
               (2.0 * (xy + zw), 1.0 - 2.0 * (x2 + z2),       2.0 * (yz - xw)),
               (2.0 * (xz - yw),       2.0 * (yz + xw), 1.0 - 2.0 * (x2 + y2)));

   begin
      return Matrix;
   end To_Matrix_3D;

   --

   function To_Matrix_3D_OpenGL (Quad : Quaternion_Rotation) return Matrix_3D is

      x  : constant Real := Quad.z;
      y  : constant Real := Quad.y;
      z  : constant Real := Quad.x;
      w  : constant Real := Quad.w;
      x2 : constant Real := x * x;
      y2 : constant Real := y * y;
      z2 : constant Real := z * z;
      xw : constant Real := x * w;
      yw : constant Real := y * w;
      zw : constant Real := z * w;
      xy : constant Real := x * y;
      xz : constant Real := x * z;
      yz : constant Real := y * z;

      Matrix : constant Matrix_3D :=
        ((1.0 - 2.0 * (y2 + z2),       2.0 * (xy - zw),       2.0 * (xz + yw)),
               (2.0 * (xy + zw), 1.0 - 2.0 * (x2 + z2),       2.0 * (yz - xw)),
               (2.0 * (xz - yw),       2.0 * (yz + xw), 1.0 - 2.0 * (x2 + y2)));

   begin
      return Matrix;
   end To_Matrix_3D_OpenGL;

   --

   function To_Matrix_4D (Quad : Quaternion_Rotation) return Matrix_4D is

      x  :          Real renames Quad.x;
      y  :          Real renames Quad.y;
      z  :          Real renames Quad.z;
      w  :          Real renames Quad.w;
      x2 : constant Real := x * x;
      y2 : constant Real := y * y;
      z2 : constant Real := z * z;
      xw : constant Real := x * w;
      yw : constant Real := y * w;
      zw : constant Real := z * w;
      xy : constant Real := x * y;
      xz : constant Real := x * z;
      yz : constant Real := y * z;

      Matrix : constant Matrix_4D :=
        ((1.0 - 2.0 * (y2 + z2),       2.0 * (xy - zw),       2.0 * (xz + yw), 0.0),
               (2.0 * (xy + zw), 1.0 - 2.0 * (x2 + z2),       2.0 * (yz - xw), 0.0),
               (2.0 * (xz - yw),       2.0 * (yz + xw), 1.0 - 2.0 * (x2 + y2), 0.0),
                           (0.0,                   0.0,                   0.0, 1.0));

   begin
      return Matrix;
   end To_Matrix_4D;

   --

   function Roll (Quad : Quaternion_Rotation) return Radiants is

      Pole : constant Real := Real'Rounding (1_000_000.0 * (Quad.x * Quad.y + Quad.z * Quad.w)) / 1_000_000.0;

   begin
      return (if Pole = 0.5 or else Pole = -0.5 then
                 0.0
              else
                 Arctan (2.0 * Quad.w * Quad.x - 2.0 * Quad.y * Quad.z, 1.0 - 2.0 * (Quad.x ** 2) - 2.0 * (Quad.z ** 2)));
   end Roll;

   --

   function Pitch (Quad : Quaternion_Rotation) return Radiants is
     (Arcsin (Real'Max (-1.0, Real'Min (1.0, 2.0 * Quad.x * Quad.y + 2.0 * Quad.w * Quad.z))));

   --

   function Yaw (Quad : Quaternion_Rotation) return Radiants is

      Pole : constant Real := Real'Rounding (1_000_000.0 * (Quad.x * Quad.y + Quad.z * Quad.w)) / 1_000_000.0;

   begin
      return (if Pole = 0.5 then
                 +2.0 * Arctan (Quad.x, Quad.w)
              elsif Pole = -0.5 then
                 -2.0 * Arctan (Quad.x, Quad.w)
              else
                 Arctan (2.0 * Quad.w * Quad.y - 2.0 * Quad.x * Quad.z, 1.0 - 2.0 * (Quad.y ** 2) - 2.0 * (Quad.z **2)));
   end Yaw;

   --

   function Roll  (Matrix : Matrix_3D) return Radiants is
     (if Matrix (2, 1) = 1.0 or else Matrix (2, 1) = -1.0 then
         0.0
      else
         Arctan (-Matrix (2, 3), Matrix (2, 2)));

   --

   function Pitch (Matrix : Matrix_3D) return Radiants is (Arcsin (Matrix (2, 1)));

   --

   function Yaw   (Matrix : Matrix_3D) return Radiants is
     (if Matrix (2, 1) = 1.0 or else Matrix (2, 1) = -1.0 then
         Arctan (Matrix (1, 2), Matrix (3, 3))
      else
         Arctan (-Matrix (3, 1), Matrix (1, 1)));

   --

   function To_Matrix_3D_OpenGL (Roll_Angle, Pitch_Angle, Yaw_Angle : Radiants;
                                 Order        : Rotation_Order := RPY;
                                 Column_First : Boolean        := True) return Matrix_3D is

      use Matrices_3D;

      cx : constant Real := Cos (Pitch_Angle);
      sx : constant Real := Sin (Pitch_Angle);

      cy : constant Real := Cos (Yaw_Angle);
      sy : constant Real := Sin (Yaw_Angle);

      cz : constant Real := Cos (Roll_Angle);
      sz : constant Real := Sin (Roll_Angle);

      Mx : constant Matrix_3D := ((1.0, 0.0, 0.0),
                                  (0.0,  cx, -sx),
                                  (0.0,  sx,  cx));

      My : constant Matrix_3D := ((cy,  0.0,  sy),
                                  (0.0, 1.0, 0.0),
                                  (-sy, 0.0,  cy));

      Mz : constant Matrix_3D := ((cz,  -sz, 0.0),
                                  (sz,   cz, 0.0),
                                  (0.0, 0.0, 1.0));

      Mrot : Matrix_3D;

      function Column_First_Mirror (Matrix : Matrix_3D) return Matrix_3D is

         Mirrored_Matrix : Matrix_3D;

      begin
         for i in Matrix'Range (1) loop
            for j in Matrix'Range (2) loop
               Mirrored_Matrix (j, i) := Matrix (i, j);
            end loop;
         end loop;
         return Mirrored_Matrix;
      end Column_First_Mirror;

   begin
      case Order is
         when RPY => Mrot := Mz * Mx * My;
         when RYP => Mrot := Mz * My * Mx;
         when PRY => Mrot := Mx * Mz * My;
         when PYR => Mrot := Mx * My * Mz;
         when YRP => Mrot := My * Mz * Mx;
         when YPR => Mrot := My * Mx * Mz;
      end case;

      if Column_First then
         return Column_First_Mirror (Mrot);
      else
         return Mrot;
      end if;
   end To_Matrix_3D_OpenGL;

   --

   function To_Matrix_3D (Roll_Angle, Pitch_Angle, Yaw_Angle : Radiants) return Matrix_3D is

      cx : constant Real := Cos (Roll_Angle);
      sx : constant Real := Sin (Roll_Angle);

      cy : constant Real := Cos (Pitch_Angle);
      sy : constant Real := Sin (Pitch_Angle);

      cz : constant Real := Cos (Yaw_Angle);
      sz : constant Real := Sin (Yaw_Angle);

      Mx : constant Matrix_3D := ((1.0, 0.0, 0.0),
                                  (0.0,  cx, -sx),
                                  (0.0,  sx,  cx));

      My : constant Matrix_3D := ((cy,  0.0,  sy),
                                  (0.0, 1.0, 0.0),
                                  (-sy, 0.0,  cy));

      Mz : constant Matrix_3D := ((cz,   sz, 0.0),
                                  (-sz,  cz, 0.0),
                                  (0.0, 0.0, 1.0));

      use Matrices_3D;

   begin
      return Mx * Mz * My;
   end To_Matrix_3D;

   --

end Rotations;
