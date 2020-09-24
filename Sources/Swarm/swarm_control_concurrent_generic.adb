--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Exceptions;            use Exceptions;
with Swarm_Control;         use Swarm_Control;
with Swarm_Data;            use Swarm_Data;
with Swarm_Structures;      -- use Swarm_Structures;
with Swarm_Structures_Base; use Swarm_Structures_Base;

package body Swarm_Control_Concurrent_Generic is

   --

   protected Synchroniser is
      entry All_Jobs_Done;
   private
      Synchroniser_Open : Boolean := False;
   end Synchroniser;

   --

   protected body Synchroniser is
      entry All_Jobs_Done when
        All_Jobs_Done'Count = No_Of_CPU_Cores + 1 or else Synchroniser_Open is
      begin
         Synchroniser_Open := All_Jobs_Done'Count > 0;
      end All_Jobs_Done;
   end Synchroniser;

   --
   --
   --

   task type Worker is
      entry Set_Job (Job : Job_Type; Start_Index, End_Index : Swarm_Element_Index);
   end Worker;

   --

   Workers : array (1 .. No_Of_CPU_Cores) of Worker;

   --

   task body Worker is

      Current_Job   : Job_Type;
      Start, Finish : Swarm_Element_Index;

   begin
      loop
         select
            accept Set_Job (Job : Job_Type; Start_Index, End_Index : Swarm_Element_Index) do
               Current_Job := Job;
               Start       := Start_Index;
               Finish      := End_Index;
            end Set_Job;
            for Element_Index in Start .. Finish loop
               case Current_Job is
                  when Set_Accelerations => Set_Acceleration (Element_Index);
                  when Forward_Messages  => Forward_Messages (Element_Index);
                  when Move_Elements     => Move_Element     (Element_Index);
                  when Update_Rotations  => Update_Rotation  (Element_Index);
                  when No_Job            => null;
               end case;
            end loop;
            Synchroniser.All_Jobs_Done;
         or
            terminate;
         end select;
      end loop;

   exception
      when E : others => Show_Exception (E);

   end Worker;

   --------------------------------------
   -- Distribute_Jobs --
   --------------------------------------

   procedure Distribute_Jobs (Job : Job_Type) is

      use Swarm_Structures.Swarm_Vectors;

      First_Element_Ix  : constant Swarm_Element_Index := First_Index (Swarm_State);
      Last_Element_Ix   : constant Swarm_Element_Index := Last_Index  (Swarm_State);
      No_Of_Elements    : constant Swarm_Element_Index := Swarm_Element_Index (Length (Swarm_State));
      Elements_Per_Task : constant Swarm_Element_Index := Natural'Max (1, No_Of_Elements / No_Of_CPU_Cores);

   begin
      for Task_Index in Workers'First .. Workers'Last - 1 loop
         declare
            From_Ix : constant Integer := Swarm_Element_Index ((Integer (Task_Index) - Workers'First)     * Elements_Per_Task + First_Element_Ix);
            To_Ix   : constant Integer := Swarm_Element_Index ((Integer (Task_Index) - Workers'First + 1) * Elements_Per_Task + First_Element_Ix - 1);
         begin
            if From_Ix >= First_Element_Ix and then To_Ix <= Last_Element_Ix then
               Workers (Task_Index).Set_Job (Job, From_Ix, To_Ix);
            else
               Workers (Task_Index).Set_Job (No_Job, From_Ix, To_Ix);
            end if;
         end;
      end loop;

      declare
         From_Ix : constant Integer := Swarm_Element_Index ((Integer (Workers'Last) - Workers'First)      * Elements_Per_Task + First_Element_Ix);
         To_Ix   : constant Integer := Last_Element_Ix;
      begin
         if From_Ix >= First_Element_Ix and then To_Ix <= Last_Element_Ix then
            Workers (Workers'Last).Set_Job (Job, From_Ix, To_Ix);
         else
            Workers (Workers'Last).Set_Job (No_Job, From_Ix, To_Ix);
         end if;
      end;

      Synchroniser.All_Jobs_Done;
   end Distribute_Jobs;

   --

end Swarm_Control_Concurrent_Generic;
