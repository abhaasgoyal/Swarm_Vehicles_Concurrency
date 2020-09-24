--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

generic

   No_Of_CPU_Cores : Positive;

package Swarm_Control_Concurrent_Generic is

   type Job_Type is (Set_Accelerations, Forward_Messages, Move_Elements, Update_Rotations, No_Job);

   procedure Distribute_Jobs (Job : Job_Type);

end Swarm_Control_Concurrent_Generic;
