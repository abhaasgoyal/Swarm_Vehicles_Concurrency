--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Ada.Numerics;           use Ada.Numerics;
with Ada.Real_Time;          use Ada.Real_Time;
with Graphics_Configuration; use Graphics_Configuration;
with Real_Type;              use Real_Type;
with Swarm_Configurations;   use Swarm_Configurations;
with Swarm_Structures_Base;  use Swarm_Structures_Base;
with System.Multiprocessors; use System.Multiprocessors;
with Vectors_3D;             use Vectors_3D;

pragma Elaborate_All (Swarm_Configurations);

package Swarm_Configuration is

   -----------------------------------------------------------------------------
   Configuration : Configurations := Single_Globe_In_Orbit;
   -- valid Configurations are (Single_Globe_In_Orbit, Dual_Globes_In_Orbit, Dual_Globes_In_Orbit_Fast,
   --                           Random_Globes_In_Orbits, Globe_Grid_In_Centre, Globe_Grid_Drifting)
   -----------------------------------------------------------------------------

   Initial_No_of_Elements : constant Positive  := 64;
   Initial_Swarm_Position : constant Vector_3D := Zero_Vector_3D;
   Initual_Edge_Length    : constant Real      := 1.0;

   Repulse_Strength           : constant Real :=   1.00;
   Repulse_Centre             : constant Real :=   0.12;
   Repulse_Steepness          : constant Real :=  30.00;
   Unconditional_Repulse_Dist : constant Real :=   0.30;

   Attract_Strength           : constant Real :=   0.20;
   Attract_Close_Centre       : constant Real :=   0.80;
   Attract_Close_Steepness    : constant Real :=  50.00;
   Attract_Far_Centre         : constant Real :=   2.00;
   Attract_Far_Steepness      : constant Real :=   4.00;

   Approach_Strength          : constant Real :=   1.00;
   Approach_Steepness         : constant Real :=   1.00;
   Max_Approach_Velocity      : constant Real :=   3.00;
   Target_Fetch_Range         : constant Real :=   0.03;

   Detection_Range            : constant Real :=   3.00;
   Comms_Range                : constant Real :=   0.20;

   Velocity_Matching_Range    : constant Real :=   0.30;
   Velocity_Matching_Strength : constant Real :=   0.05;

   Friction                   : constant Real :=   0.02;

   No_of_Cores_for_Swarm      : constant Positive := Positive (Number_Of_CPUs);

   Max_Assumed_Acceleration   : constant Real  :=  1.50;
   Max_Update_Interval        : constant Real  :=  0.10; -- sec.

   Charging_Setup         : constant Charging_Setups_R := Charging_Setups (Configuration);
   Energy_Globe_Detection : constant Real              := Energy_Globe_Detections (Configuration);
   Energy_Globes_Defaults : constant Energy_Globes     := Default_Globes (Configuration);
   Energy_Globes_Velocity : constant Vector_3D         := (x => 0.15, y => 0.0, z => 0.0);

   -- Orbiting parameters for globes
   Sphere_Increment : constant Vector_3D := (x => 2.0 * Pi / Intented_Framerate / 1000.0,
                                             y => 2.0 * Pi / Intented_Framerate / 1100.0,
                                             z => 2.0 * Pi / Intented_Framerate / 120.0);

   Sphere_Increment_Fast : constant Vector_3D := (x => 2.0 * Pi / Intented_Framerate / 100.0,
                                                  y => 2.0 * Pi / Intented_Framerate / 110.0,
                                                  z => 2.0 * Pi / Intented_Framerate / 12.0);

   Tolerated_Vehicle_Activation_Delay : constant Duration := To_Duration (Milliseconds (100));
   Tolerated_Identify_Call_Delay      : constant Duration := To_Duration (Milliseconds (100));

   function Inter_Swarm_Attraction   (x : Distances) return Acc_Scalar;
   function Inter_Swarm_Repulsion    (x : Distances) return Acc_Scalar;
   function Inter_Swarm_Acceleration (x : Distances) return Acc_Scalar;

   function Approach_Acceleration    (Velocity_Towards_Goal : Real) return Acc_Scalar;
   function Approach_Acceleration    (x : Distances;
                                      Velocity_Towards_Goal : Real) return Acc_Scalar;

   function Velocity_Matching (Velocity, Velocity_Difference : Velocities) return Accelerations;

end Swarm_Configuration;
