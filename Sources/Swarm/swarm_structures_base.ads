--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Real_Type;          use Real_Type;
with Generic_Protected;                            pragma Elaborate_All (Generic_Protected);
with Graphics_Structures; use Graphics_Structures;
with Vectors_3D;          use Vectors_3D;

package Swarm_Structures_Base is

   subtype Distances  is Real;
   subtype Acc_Scalar is Real;

   subtype Positions     is Point_3D;
   subtype Velocities    is Vector_3D;
   subtype Accelerations is Vector_3D;

   subtype Swarm_Element_Index is Positive;
   subtype Throttle_T          is Real range 0.0 .. 1.0;

   Idle_Throttle : constant Throttle_T := 0.0;
   Full_Throttle : constant Throttle_T := 1.0;

   type Vehicle_Charges is new Real range 0.0 .. 1.0;

   Empty_Charge : constant Vehicle_Charges := 0.0;
   Half_Charge  : constant Vehicle_Charges := 0.5;
   Full_Charge  : constant Vehicle_Charges := 1.0;

   type Energy_Globe is record
      Position : Positions;
      Velocity : Velocities; -- in delta-position per second
   end record;

   type Energy_Globes is array (Positive range <>) of Energy_Globe;

   package Protected_Point_3D  is new Generic_Protected (Point_3D,  Zero_Vector_3D);
   package Protected_Vector_3D is new Generic_Protected (Vector_3D, Zero_Vector_3D);

   type Energy_Globe_Protected is record
      Active   : Boolean := True with Atomic;
      Position : Protected_Point_3D.Monitor_Ptr;
      Velocity : Protected_Vector_3D.Monitor_Ptr;
   end record;

   type Energy_Globes_Protected is array (Positive range <>) of Energy_Globe_Protected;

end Swarm_Structures_Base;
