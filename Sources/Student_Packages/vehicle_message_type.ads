with Ada.Real_Time; use Ada.Real_Time;
with Vectors_3D;    use Vectors_3D;
-- with Swarm_Size; use Swarm_Size;

package Vehicle_Message_Type is

   type Inter_Vehicle_Messages is record
      Globe_Pos    : Vector_3D;
      Message_Time : Time;
   end record;

end Vehicle_Message_Type;
