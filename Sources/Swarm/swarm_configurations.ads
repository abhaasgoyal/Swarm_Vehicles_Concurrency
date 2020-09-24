--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Ada.Real_Time;         use Ada.Real_Time;

with Real_Type;             use Real_Type;
with Swarm_Structures_Base; use Swarm_Structures_Base;

package Swarm_Configurations is

   type Configurations is (Single_Globe_In_Orbit, Dual_Globes_In_Orbit, Dual_Globes_In_Orbit_Fast, Random_Globes_In_Orbits, Globe_Grid_In_Centre, Globe_Grid_Drifting);

   type Charging_Setups_R is record
      Constant_Discharge_Rate_Per_Sec,           -- Constant rate: independent of motion
      Propulsion_Discharge_Rate_Per_Sec : Real;  -- Manoeuvring dependent rate: linearly dependent on accelaration
      Max_Globe_Interval                : Time_Span;
      Globes_Required                   : Positive;
   end record;

   Charging_Setups : array (Configurations) of Charging_Setups_R :=
     (Single_Globe_In_Orbit      => (Constant_Discharge_Rate_Per_Sec   => 0.01,
                                     Propulsion_Discharge_Rate_Per_Sec => 0.04,
                                     Max_Globe_Interval                => Milliseconds (0),
                                     Globes_Required                   => 1),
      Dual_Globes_In_Orbit       => (Constant_Discharge_Rate_Per_Sec   => 0.01,
                                     Propulsion_Discharge_Rate_Per_Sec => 0.04,
                                     Max_Globe_Interval                => Milliseconds (0),
                                     Globes_Required                   => 1),
      Dual_Globes_In_Orbit_Fast  => (Constant_Discharge_Rate_Per_Sec   => 0.01,
                                     Propulsion_Discharge_Rate_Per_Sec => 0.04,
                                     Max_Globe_Interval                => Milliseconds (0),
                                     Globes_Required                   => 1),
      Random_Globes_In_Orbits    => (Constant_Discharge_Rate_Per_Sec   => 0.01,
                                     Propulsion_Discharge_Rate_Per_Sec => 0.04,
                                     Max_Globe_Interval                => Milliseconds (0),
                                     Globes_Required                   => 1),
      Globe_Grid_In_Centre       => (Constant_Discharge_Rate_Per_Sec   => 0.01,
                                     Propulsion_Discharge_Rate_Per_Sec => 0.04,
                                     Max_Globe_Interval                => Milliseconds (500),
                                     Globes_Required                   => 3),
      Globe_Grid_Drifting        => (Constant_Discharge_Rate_Per_Sec   => 0.01,
                                     Propulsion_Discharge_Rate_Per_Sec => 0.04,
                                     Max_Globe_Interval                => Seconds (1),
                                     Globes_Required                   => 3));

   Energy_Globe_Detections : constant array (Configurations) of Real := (Single_Globe_In_Orbit     => 0.07,
                                                                         Dual_Globes_In_Orbit      => 0.07,
                                                                         Dual_Globes_In_Orbit_Fast => 0.07,
                                                                         Random_Globes_In_Orbits   => 0.07,
                                                                         Globe_Grid_In_Centre      => 0.02,
                                                                         Globe_Grid_Drifting       => 0.06);

   function Default_Globes           (Configuration : Configurations) return Energy_Globes;
   function Default_Protected_Globes (Configuration : Configurations) return Energy_Globes_Protected;

end Swarm_Configurations;
