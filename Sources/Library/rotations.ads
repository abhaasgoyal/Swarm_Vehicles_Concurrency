--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Real_Type;  use Real_Type;
with Quaternions; use Quaternions;
with Vectors_3D;  use Vectors_3D;
with Matrices;

pragma Elaborate_All (Matrices);

package Rotations is

   pragma Elaborate_Body;

   package Matrices_3D         is new Matrices    (Dimension => 3);
   package Matrices_4D         is new Matrices    (Dimension => 4);

   subtype Vector              is Vector_3D;
   subtype Quaternion_Rotation is Quaternion_Real;
   subtype Matrix_3D           is Matrices_3D.Matrix;
   subtype Matrix_4D           is Matrices_4D.Matrix;

   subtype Radiants            is Real;
   subtype Degrees             is Real;

   function To_Radiants (A : Degrees)  return Radiants;
   function To_Degrees  (A : Radiants) return Degrees;

   type Rotation_Order is (RPY, RYP, PRY, PYR, YRP, YPR);

   Roll_Axis  : constant Vector := (x => 1.0, y => 0.0, z => 0.0);
   Pitch_Axis : constant Vector := (x => 0.0, y => 0.0, z => 1.0);
   Yaw_Axis   : constant Vector := (x => 0.0, y => 1.0, z => 0.0);

   function To_Rotation (Axis : Vector;      Rotation_Angle : Radiants) return Quaternion_Rotation;
   function To_Rotation (Roll_Angle, Pitch_Angle, Yaw_Angle : Radiants) return Quaternion_Rotation;
   function To_Rotation (Matrix : Matrix_3D)                         return Quaternion_Rotation;
   function To_Rotation (Matrix : Matrix_4D)                         return Quaternion_Rotation;

   function Zero_Rotation return Quaternion_Rotation;

   function Inverse (Quad : Quaternion_Rotation) return Quaternion_Rotation;

   function Rotate (Current_Rotation, Additional_Rotation : Quaternion_Rotation)                            return Quaternion_Rotation;
   function Rotate (Current_Rotation : Quaternion_Rotation; Rotation_Axis : Vector; Rotation_Angle : Radiants) return Quaternion_Rotation;

   function Rotate (Current_Vector, Rotation_Axis : Vector; Rotation_Angle : Radiants) return Vector;
   function Rotate (Current_Vector : Vector; Apply_Rotation : Quaternion_Rotation)  return Vector;

   function Roll  (Quad : Quaternion_Rotation) return Radiants;
   function Pitch (Quad : Quaternion_Rotation) return Radiants;
   function Yaw   (Quad : Quaternion_Rotation) return Radiants;

   function Roll  (Matrix : Matrix_3D) return Radiants;
   function Pitch (Matrix : Matrix_3D) return Radiants;
   function Yaw   (Matrix : Matrix_3D) return Radiants;

   function To_Matrix_3D        (Quad : Quaternion_Rotation) return Matrix_3D;
   function To_Matrix_3D_OpenGL (Quad : Quaternion_Rotation) return Matrix_3D;
   function To_Matrix_4D        (Quad : Quaternion_Rotation) return Matrix_4D;

   function To_Matrix_3D        (Roll_Angle, Pitch_Angle, Yaw_Angle : Radiants) return Matrix_3D;
   function To_Matrix_3D_OpenGL (Roll_Angle, Pitch_Angle, Yaw_Angle : Radiants;
                                 Order        : Rotation_Order := RPY;
                                 Column_First : Boolean        := True) return Matrix_3D;

end Rotations;
