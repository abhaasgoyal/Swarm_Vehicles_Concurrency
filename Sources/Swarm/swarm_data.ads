--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Swarm_Configuration;   use Swarm_Configuration;
with Swarm_Configurations;  use Swarm_Configurations; pragma Elaborate_All (Swarm_Configurations);
with Swarm_Structures;      use Swarm_Structures;
with Swarm_Structures_Base; use Swarm_Structures_Base;

package Swarm_Data is

   -- The Swarm_State is an unprotected, dynamic vector for maximal concurrency.
   -- Different tasks can update different parts of this vector concurrently.
   -- Critical operations (like deletions or insertions)
   -- are handled via the Swarm_Monitor in Swarm_Control.
   --
   Swarm_State : Swarm_Vectors.Vector    := Swarm_Vectors.Empty_Vector;

   Globes      : Energy_Globes_Protected := Default_Protected_Globes (Configuration);

end Swarm_Data;
