--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

package body Swarm_Configuration is

   use Real_Elementary_Functions;

   ------------------------------
   -- Inter_Swarm_Acceleration --
   ------------------------------

   function Inter_Swarm_Attraction   (x : Distances) return Acc_Scalar is

      Attract_Close : constant Acc_Scalar := -((Arctan ((x - Attract_Close_Centre) * Attract_Close_Steepness) / Pi) + 0.5);
      Attract_Far   : constant Acc_Scalar := +((Arctan ((x - Attract_Far_Centre)   * Attract_Far_Steepness)   / Pi) - 0.5);

   begin
      return -Attract_Strength * Attract_Close * Attract_Far;
   end Inter_Swarm_Attraction;

   --

   function Inter_Swarm_Repulsion    (x : Distances) return Acc_Scalar is

      Repulse : constant Acc_Scalar := -((Arctan ((x - Repulse_Centre)       * Repulse_Steepness)       / Pi) - 0.5);

   begin
      return Repulse_Strength * Repulse;
   end Inter_Swarm_Repulsion;

   --

   function Inter_Swarm_Acceleration (x : Distances) return Acc_Scalar is

      (Inter_Swarm_Repulsion (x) + Inter_Swarm_Attraction (x));

   --
   --
   --

   function Approach_Acceleration    (x : Distances;
                                      Velocity_Towards_Goal : Real) return Acc_Scalar is

      (Approach_Strength * (Max_Approach_Velocity * Arctan (Approach_Steepness * x) - Velocity_Towards_Goal));

   --
   --
   --

   function Approach_Acceleration    (Velocity_Towards_Goal : Real) return Acc_Scalar is

      (Approach_Strength * (Max_Approach_Velocity - Velocity_Towards_Goal));

   --
   --
   --

   function Velocity_Matching (Velocity, Velocity_Difference : Velocities) return Accelerations is

      Proposed_Acceleration : constant Accelerations := (-Velocity_Matching_Strength) * Velocity_Difference;
      Small_Interval        : constant Real := 0.01;

   begin
      if abs (Velocity + Small_Interval * Proposed_Acceleration) > abs (Velocity) then
         return Proposed_Acceleration;
      else
         return Zero_Vector_3D;
      end if;
   end Velocity_Matching;

   --

end Swarm_Configuration;
