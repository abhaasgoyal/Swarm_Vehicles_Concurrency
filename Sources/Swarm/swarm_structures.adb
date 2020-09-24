--
-- Jan & Uwe R. Zimmer, Australia, 2013
--

package body Swarm_Structures is

   --

   protected body Vehicle_Comms is

      procedure Send (Message : Inter_Vehicle_Messages) is

      begin
         Put (Sent_Messages, Message);
      end Send;

      --

      procedure Push_Message (Message : Inter_Vehicle_Messages) is

      begin
         Put (Received_Messages, Message);
      end Push_Message;

      --

      procedure Fetch_Message (Message : out Inter_Vehicle_Messages) is

      begin
         Get (Sent_Messages, Message);
      end Fetch_Message;

      --

      function Has_Incoming_Messages return Boolean is (Element_Available (Received_Messages));

      function Has_Outgoing_Messages return Boolean is (Element_Available (Sent_Messages));

      --

      entry Receive (Message : out Inter_Vehicle_Messages) when Element_Available (Received_Messages) is

      begin
         Get (Received_Messages, Message);
      end Receive;

   end Vehicle_Comms;

   --
   --
   --

   protected body Vehicle_Controls is

      procedure Set_Steering (V : Vector_3D) is

      begin
         Steering_Direction := V;
      end Set_Steering;

      --

      procedure Set_Throttle (T : Throttle_T) is

      begin
         Throttle := T;
      end Set_Throttle;

      --

      function Read_Steering return Vector_3D is (Steering_Direction);

      function Read_Throttle return Throttle_T is (Throttle);

      --

   end Vehicle_Controls;

   ---------
   -- "<" --
   ---------

   function "<" (L, R : Distance_Entries) return Boolean is (L.Distance < R.Distance);

   --

   protected body Simulator_Tick is

      entry Wait_For_Next_Tick when Trigger is

      begin
         Trigger := Wait_For_Next_Tick'Count > 0;
      end Wait_For_Next_Tick;

      procedure Tick is

      begin
         Trigger := True;
      end Tick;

   end Simulator_Tick;

   --

end Swarm_Structures;
