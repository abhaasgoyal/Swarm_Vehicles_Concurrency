--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

with Vectors_3D; use Vectors_3D;

package body Swarm_Configurations is

   function Default_Globes (Configuration : Configurations) return Energy_Globes is

   begin
      case Configuration is
         when Single_Globe_In_Orbit =>
            return (1 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D));
         when Dual_Globes_In_Orbit =>
            return (1 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D),
                    2 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D));
         when Dual_Globes_In_Orbit_Fast =>
            return (1 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D),
                    2 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D));
         when Random_Globes_In_Orbits =>
            return (1 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D),
                    2 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D),
                    3 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D),
                    4 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D),
                    5 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D),
                    6 => (Position => Zero_Vector_3D, Velocity => Zero_Vector_3D));
         when Globe_Grid_In_Centre  =>
            declare
               Grid_Space : constant Real := 0.1;
            begin
               return (1 => (Position =>  (-Grid_Space, -Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       2 => (Position =>  (-Grid_Space, -Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       3 => (Position =>  (-Grid_Space, +Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       4 => (Position =>  (-Grid_Space, +Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       5 => (Position =>  (-Grid_Space,         0.0, -Grid_Space), Velocity => Zero_Vector_3D),
                       6 => (Position =>  (-Grid_Space,         0.0, +Grid_Space), Velocity => Zero_Vector_3D),
                       7 => (Position =>  (-Grid_Space,         0.0,         0.0), Velocity => Zero_Vector_3D),
                       8 => (Position =>  (-Grid_Space, -Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       9 => (Position =>  (-Grid_Space, +Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       10 => (Position => (0.0,         -Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       11 => (Position => (0.0,         -Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       12 => (Position => (0.0,         +Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       13 => (Position => (0.0,         +Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       14 => (Position => (0.0,                 0.0, -Grid_Space), Velocity => Zero_Vector_3D),
                       15 => (Position => (0.0,                 0.0, +Grid_Space), Velocity => Zero_Vector_3D),
                       16 => (Position => (0.0,                 0.0,         0.0), Velocity => Zero_Vector_3D),
                       17 => (Position => (0.0,         -Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       18 => (Position => (0.0,         +Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       19 => (Position => (+Grid_Space, -Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       20 => (Position => (+Grid_Space, -Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       21 => (Position => (+Grid_Space, +Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       22 => (Position => (+Grid_Space, +Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       23 => (Position => (+Grid_Space,         0.0, -Grid_Space), Velocity => Zero_Vector_3D),
                       24 => (Position => (+Grid_Space,         0.0, +Grid_Space), Velocity => Zero_Vector_3D),
                       25 => (Position => (+Grid_Space,         0.0,         0.0), Velocity => Zero_Vector_3D),
                       26 => (Position => (+Grid_Space, -Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       27 => (Position => (+Grid_Space, +Grid_Space,         0.0), Velocity => Zero_Vector_3D));
            end;
         when Globe_Grid_Drifting  =>
            declare
               Grid_Space : constant Real := 0.2;
            begin
               return (1 => (Position =>  (-Grid_Space, -Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       2 => (Position =>  (-Grid_Space, -Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       3 => (Position =>  (-Grid_Space, +Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       4 => (Position =>  (-Grid_Space, +Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       5 => (Position =>  (-Grid_Space,         0.0, -Grid_Space), Velocity => Zero_Vector_3D),
                       6 => (Position =>  (-Grid_Space,         0.0, +Grid_Space), Velocity => Zero_Vector_3D),
                       7 => (Position =>  (-Grid_Space,         0.0,         0.0), Velocity => Zero_Vector_3D),
                       8 => (Position =>  (-Grid_Space, -Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       9 => (Position =>  (-Grid_Space, +Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       10 => (Position => (0.0,         -Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       11 => (Position => (0.0,         -Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       12 => (Position => (0.0,         +Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       13 => (Position => (0.0,         +Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       14 => (Position => (0.0,                 0.0, -Grid_Space), Velocity => Zero_Vector_3D),
                       15 => (Position => (0.0,                 0.0, +Grid_Space), Velocity => Zero_Vector_3D),
                       16 => (Position => (0.0,                 0.0,         0.0), Velocity => Zero_Vector_3D),
                       17 => (Position => (0.0,         -Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       18 => (Position => (0.0,         +Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       19 => (Position => (+Grid_Space, -Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       20 => (Position => (+Grid_Space, -Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       21 => (Position => (+Grid_Space, +Grid_Space, -Grid_Space), Velocity => Zero_Vector_3D),
                       22 => (Position => (+Grid_Space, +Grid_Space, +Grid_Space), Velocity => Zero_Vector_3D),
                       23 => (Position => (+Grid_Space,         0.0, -Grid_Space), Velocity => Zero_Vector_3D),
                       24 => (Position => (+Grid_Space,         0.0, +Grid_Space), Velocity => Zero_Vector_3D),
                       25 => (Position => (+Grid_Space,         0.0,         0.0), Velocity => Zero_Vector_3D),
                       26 => (Position => (+Grid_Space, -Grid_Space,         0.0), Velocity => Zero_Vector_3D),
                       27 => (Position => (+Grid_Space, +Grid_Space,         0.0), Velocity => Zero_Vector_3D));
            end;
      end case;
   end Default_Globes;

   function Default_Protected_Globes (Configuration : Configurations) return Energy_Globes_Protected is

      Globes           : constant Energy_Globes := Default_Globes (Configuration);
      Globes_Protected : Energy_Globes_Protected (Globes'Range);

   begin
      for Each in Globes'Range loop
         Globes_Protected (Each) := (Active   => True,
                                     Position => Protected_Point_3D.Allocate  (Globes (Each).Position),
                                     Velocity => Protected_Vector_3D.Allocate (Globes (Each).Velocity));
      end loop;
      return Globes_Protected;
   end Default_Protected_Globes;

end Swarm_Configurations;
