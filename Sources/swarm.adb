--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Callback_Procedures; use Callback_Procedures;
with Graphics_Setup;      use Graphics_Setup;
with Exceptions;          use Exceptions;
with GLUT;

procedure Swarm is

begin
   Initialize_Graphics (Main_Operations'Access);
   GLUT.MainLoop;
exception
   when E : others => Show_Exception (E);
end Swarm;
