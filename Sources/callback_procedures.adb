--
-- Jan & Uwe R. Zimmer, Australia, July 2019
--

with Ada.Numerics.Float_Random;         use Ada.Numerics.Float_Random;
with Ada.Real_Time;                     use Ada.Real_Time;
with Exceptions;                        use Exceptions;                        pragma Elaborate_All (Exceptions);
with Real_Type;                         use Real_Type;
with Generic_Sliding_Statistics;                                               pragma Elaborate_All (Generic_Sliding_Statistics);
with Graphics_Configuration;            use Graphics_Configuration;
with Graphics_Data;                     use Graphics_Data;
with Graphics_FrameRates;               use Graphics_FrameRates;
with Graphics_OpenGL;                   use Graphics_OpenGL;
with Graphics_Structures;               use Graphics_Structures;
with Keyboard;                          use Keyboard;
with Models;                            use Models;
with Rotations;                         use Rotations;
with Screenshots;                       use Screenshots;
with Swarm_Configuration;               use Swarm_Configuration;
with Swarm_Configurations;              use Swarm_Configurations;
with Swarm_Control;                     use Swarm_Control;                     pragma Elaborate_All (Swarm_Control);
with Swarm_Control_Concurrent_Generic;                                         pragma Elaborate_All (Swarm_Control_Concurrent_Generic);
with Swarm_Data;                        use Swarm_Data;
with Swarm_Structures;                  use Swarm_Structures;
with Swarm_Structures_Base;             use Swarm_Structures_Base;
with Vectors_3D;                        use Vectors_3D;

package body Callback_Procedures is

   Zero_to_One_Generator : Generator;

   use Real_Elementary_Functions;

   Smoothing_Time : constant Positive := 10; -- seconds

   package Centre_Of_Gravity_Stats is new Generic_Sliding_Statistics (Element      => Vector_3D,
                                                                      Buffer_Size  => Smoothing_Time * Positive (Intented_Framerate));
   package Mean_Radius_Stats       is new Generic_Sliding_Statistics (Element      => Real,
                                                                      Buffer_Size  => Smoothing_Time * Positive (Intented_Framerate));

   package Centre_Of_Gravity_Averages is new Centre_Of_Gravity_Stats.Averages; use Centre_Of_Gravity_Averages;
   package Mean_Radius_Averages       is new Mean_Radius_Stats.Averages;       use Mean_Radius_Averages;

   use Swarm_Vectors;

   package Swarm_Control_Concurrent is new Swarm_Control_Concurrent_Generic (No_of_Cores_for_Swarm);
   use Swarm_Control_Concurrent;

   package Execute_Commands is
      procedure Act_On_Input (Position  : in out Vector_3D;
                              Rotation  : in out Quaternion_Rotation;
                              Time      :        Real;
                              Commands  :        Commands_Array);
   private
      Keys_Released : Boolean  := True;
   end Execute_Commands;

   package body Execute_Commands is

      procedure Act_On_Input (Position  : in out Vector_3D;
                              Rotation  : in out Quaternion_Rotation;
                              Time      :        Real;
                              Commands  :        Commands_Array) is

         Accelerator    : constant Real  :=  4.0;
         Rotation_Speed :          Real  :=  0.3 * Time;
         Moving_Speed   :          Real  :=  0.3 * Time;
         Step           :      Vector_3D := (0.0, 0.0, 0.0);

      begin
         for Command in Commands'Range loop
            if Commands (Command) then
               case Command is

                  when Move_Accelerator =>
                     Rotation_Speed := Rotation_Speed * Accelerator;
                     Moving_Speed   := Moving_Speed   * Accelerator;
                  when Full_Screen  =>
                     if Keys_Released then
                        Full_Screen_Mode.Change_Full_Screen;
                     end if;
                  when Reset_Camera =>
                     case Camera_Mode is
                        when Scene =>
                           Position := Initial_Cams (Camera_Mode).Scene_Offset;
                           Rotation := Initial_Cams (Camera_Mode).Rotation;
                        when Chase =>
                           Position := Initial_Cams (Camera_Mode).Object_Offset;
                           Rotation := Initial_Cams (Camera_Mode).Rotation;
                     end case;
                  when Screen_Shot => Take_Shot;
                  when Toggle_Axis =>
                     if Keys_Released then
                        Show_Axis := not Show_Axis;
                     end if;
                  when Toggle_Lines =>
                     if Keys_Released then
                        Show_Connecting_Lines := not Show_Connecting_Lines;
                     end if;
                  when Text_Overlay =>
                     if Keys_Released then
                        Show_Text_Overlay := not Show_Text_Overlay;
                     end if;
                  when Space =>
                     if Keys_Released then
                        case Camera_Mode is
                           when Scene => Camera_Mode := Chase;
                           when Chase => Camera_Mode := Scene;
                        end case;
                     end if;

                     -- Rotation --
                  when Rotate_Left => Rotation := Rotate
                       (Rotation, To_Rotation (0.0, 0.0,  Rotation_Speed));
                  when Rotate_Right => Rotation := Rotate
                       (Rotation, To_Rotation (0.0, 0.0, -Rotation_Speed));
                  when Rotate_Up => Rotation := Rotate
                       (Rotation, To_Rotation (0.0,  Rotation_Speed, 0.0));
                  when Rotate_Down => Rotation := Rotate
                       (Rotation, To_Rotation (0.0, -Rotation_Speed, 0.0));
                  when Rotate_CW => Rotation := Rotate
                       (Rotation, To_Rotation (-Rotation_Speed, 0.0, 0.0));
                  when Rotate_AntiCW => Rotation := Rotate
                       (Rotation, To_Rotation  (Rotation_Speed, 0.0, 0.0));

                     -- Stepping --
                  when Strafe_Left     => Step (x) := Step (x) - Moving_Speed;
                  when Strafe_Right    => Step (x) := Step (x) + Moving_Speed;
                  when Strafe_Up       => Step (z) := Step (z) + Moving_Speed;
                  when Strafe_Down     => Step (z) := Step (z) - Moving_Speed;
                  when Strafe_Forward  => Step (y) := Step (y) + Moving_Speed;
                  when Strafe_Backward => Step (y) := Step (y) - Moving_Speed;

                     -- Swarm control --

                  when Add_Vehicle    =>
                     if Keys_Released then
                        if Natural (Length (Swarm_State)) = 0 then
                           Swarm_Monitor.Append_Random_Swarm (1);
                        else
                           Swarm_Monitor.Append_Random_Swarm (1, Swarm_Monitor.Centre_Of_Gravity, 0.0001);
                        end if;
                     end if;
                  when Remove_Vehicle =>
                     if Keys_Released then -- and then Natural (Length (Swarm_State)) > 1 then
                        Remove_Vehicles (1);
                     end if;
               end case;
            end if;
         end loop;

         Keys_Released := Commands = Command_Set_Reset;

         case Camera_Mode is
            when Scene => Step := Rotate (Step, Rotation);
            when Chase => null;
         end case;

         for Axes in Step'Range loop
            Position (Axes) := Position (Axes) + Step (Axes);
         end loop;

      end Act_On_Input;
   end Execute_Commands;

   --
   --
   --

   procedure Main_Operations is

      Time_Interval      : constant Time_Span  := Measure_Interval; -- Time since last call
      FrameRate          : constant Natural    := Natural (Average_Framerate (Time_Interval));
      Time_Interval_Real : constant Real       := Real (To_Duration (Time_Interval));

      Commands : Commands_Array := Command_Set_Reset;

   begin
      Framerate_Limiter (Intented_Framerate);

      Get_Keys (Commands);

      case Camera_Mode is
         when Scene =>
            Execute_Commands.Act_On_Input (Cam.Scene_Offset, Cam.Rotation, Time_Interval_Real, Commands);
            case Camera_Mode is
               when Scene =>
                  Cam.Position := Swarm_Monitor.Centre_Of_Gravity;
               when Chase =>
                  Cam := Initial_Cams (Camera_Mode);
            end case;

         when Chase =>
            Execute_Commands.Act_On_Input (Cam.Object_Offset, Cam.Rotation, Time_Interval_Real, Commands);
            case Camera_Mode is
               when Scene => Cam := Initial_Cams (Camera_Mode);
               when Chase =>
                  Cam.Position := Element (Swarm_State, 1).Position.all.Read;
                  declare
                     --                 Element_Roll  : constant Angle := Roll  (Element (Swarm_State, 1).Rotation);
                     Element_Pitch : constant Radiants := Pitch (Element (Swarm_State, 1).Rotation.all.Read);
                     Element_Yaw   : constant Radiants := Yaw   (Element (Swarm_State, 1).Rotation.all.Read);
                  begin
                     Cam.Rotation := To_Rotation (0.0, 0.0, -Element_Yaw);
                     Cam.Rotation := Rotate (Cam.Rotation, To_Rotation (0.0, -Element_Pitch, 0.0));
                     --                 Cam.Rotation := Rotate (Cam.Rotation, To_Rotation (-Element_Roll, 0.0, 0.0));
                  end;
--                    Cam.Rotation := Inverse (Element (Swarm_State, 1).Rotation);
            end case;
      end case;

      Position_Camera;

      for Element_Index in First_Index (Swarm_State) .. Last_Index (Swarm_State) loop
         declare
            This_Element : constant Swarm_Element_State := Element (Swarm_State, Element_Index);
            Charge_Index : constant Positive            :=
              Positive ((Real (This_Element.Charge.Level) * (Real (Spaceship_Gradient'Last (2) - Spaceship_Gradient'First (2))))
                        + Real (Spaceship_Gradient'First (2)));
         begin

            if This_Element.Controls.all.Read_Throttle /= Idle_Throttle then
               Draw (Spaceship_Gradient (G_Ruby,      Charge_Index), This_Element.Position.all.Read, This_Element.Rotation.all.Read);
            else
               Draw (Spaceship_Gradient (G_Turquoise, Charge_Index), This_Element.Position.all.Read, This_Element.Rotation.all.Read);
            end if;

            if Show_Connecting_Lines then
               for Neighbour_Index in Distance_Vectors.First_Index (This_Element.Neighbours.all) .. Distance_Vectors.Last_Index (This_Element.Neighbours.all) loop
                  declare
                     Distance_Entry : constant Distance_Entries := Distance_Vectors.Element (This_Element.Neighbours.all, Neighbour_Index);
                  begin
                     if Distance_Entry.Distance <= Comms_Range then
                        Draw_Lines ((This_Element.Position.all.Read, Element (Swarm_State, Distance_Entry.Index).Position.all.Read));
                     end if;
                  exception
                     when Constraint_Error => null; -- Neighbour died
                  end;
               end loop;
            end if;
         end;
      end loop;

      case Configuration is

         when Single_Globe_In_Orbit =>

            Sphere_Angles := Sphere_Angles + Sphere_Increment;

            for Globe_Ix in Globes'Range loop
               declare

                  Sin_x : constant Real := Sin (Sphere_Angles (x));
                  Cos_x : constant Real := Cos (Sphere_Angles (x));
                  Sin_y : constant Real := Sin (Sphere_Angles (y));
                  Cos_y : constant Real := Cos (Sphere_Angles (y));
                  Sin_z : constant Real := Sin (Sphere_Angles (z));
                  Cos_z : constant Real := Cos (Sphere_Angles (z));

                  Radius : constant Real := Average (Swarm_Monitor.Mean_Radius);

                  Sphere_Offset : constant Positions := (x => Sin_z * Radius * Cos_x * Cos_y,
                                                         y => Sin_z * Radius * Cos_x * Sin_y,
                                                         z => Cos_z * Radius * Sin_x);

                  New_Position : constant Positions := Average (Swarm_Monitor.Centre_Of_Gravity) + Sphere_Offset;

               begin
                  Globes (Globe_Ix).Velocity.all.Write ((New_Position - Globes (Globe_Ix).Position.all.Read) / Time_Interval_Real);
                  Globes (Globe_Ix).Position.all.Write (New_Position);
                  Draw (Model_Set (Sphere), New_Position, Zero_Rotation);
               end;
            end loop;

         when Dual_Globes_In_Orbit =>

            Sphere_Angles := Sphere_Angles + Sphere_Increment;

            for Globe_Ix in Globes'Range loop
               declare

                  Sin_x : constant Real := Sin (Sphere_Angles (x));
                  Cos_x : constant Real := Cos (Sphere_Angles (x));
                  Sin_y : constant Real := Sin (Sphere_Angles (y));
                  Cos_y : constant Real := Cos (Sphere_Angles (y));
                  Sin_z : constant Real := Sin (Sphere_Angles (z));
                  Cos_z : constant Real := Cos (Sphere_Angles (z));

                  Radius : constant Real := Average (Swarm_Monitor.Mean_Radius);

                  Sphere_Offset_1 : constant Positions := (x => Sin_z * Radius * Cos_x * Cos_y,
                                                           y => Sin_z * Radius * Cos_x * Sin_y,
                                                           z => Cos_z * Radius * Sin_x);

                  Sphere_Offset_2 : constant Positions := -Sphere_Offset_1;

                  New_Position_1 : constant Positions := Average (Swarm_Monitor.Centre_Of_Gravity) + Sphere_Offset_1;
                  New_Position_2 : constant Positions := Average (Swarm_Monitor.Centre_Of_Gravity) + Sphere_Offset_2;

               begin
                  if Globe_Ix = Globes'First then
                     Globes (Globe_Ix).Velocity.all.Write ((New_Position_1 - Globes (Globe_Ix).Position.all.Read) / Time_Interval_Real);
                     Globes (Globe_Ix).Position.all.Write (New_Position_1);
                     Draw (Model_Set (Sphere), New_Position_1, Zero_Rotation);

                  else
                     Globes (Globe_Ix).Velocity.all.Write ((New_Position_2 - Globes (Globe_Ix).Position.all.Read) / Time_Interval_Real);
                     Globes (Globe_Ix).Position.all.Write (New_Position_2);
                     Draw (Model_Set (Sphere), New_Position_2, Zero_Rotation);
                  end if;
               end;
            end loop;

         when Dual_Globes_In_Orbit_Fast =>

            Sphere_Angles := Sphere_Angles + Sphere_Increment_Fast;

            for Globe_Ix in Globes'Range loop
               declare

                  Sin_x : constant Real := Sin (Sphere_Angles (x));
                  Cos_x : constant Real := Cos (Sphere_Angles (x));
                  Sin_y : constant Real := Sin (Sphere_Angles (y));
                  Cos_y : constant Real := Cos (Sphere_Angles (y));
                  Sin_z : constant Real := Sin (Sphere_Angles (z));
                  Cos_z : constant Real := Cos (Sphere_Angles (z));

                  Radius : constant Real := Average (Swarm_Monitor.Mean_Radius);

                  Sphere_Offset_1 : constant Positions := (x => Sin_z * Radius * Cos_x * Cos_y,
                                                           y => Sin_z * Radius * Cos_x * Sin_y,
                                                           z => Cos_z * Radius * Sin_x);

                  Sphere_Offset_2 : constant Positions := -Sphere_Offset_1;

                  New_Position_1 : constant Positions := Average (Swarm_Monitor.Centre_Of_Gravity) + Sphere_Offset_1;
                  New_Position_2 : constant Positions := Average (Swarm_Monitor.Centre_Of_Gravity) + Sphere_Offset_2;

               begin
                  if Globe_Ix = Globes'First then
                     Globes (Globe_Ix).Velocity.all.Write ((New_Position_1 - Globes (Globe_Ix).Position.all.Read) / Time_Interval_Real);
                     Globes (Globe_Ix).Position.all.Write (New_Position_1);
                     Draw (Model_Set (Sphere), New_Position_1, Zero_Rotation);

                  else
                     Globes (Globe_Ix).Velocity.all.Write ((New_Position_2 - Globes (Globe_Ix).Position.all.Read) / Time_Interval_Real);
                     Globes (Globe_Ix).Position.all.Write (New_Position_2);
                     Draw (Model_Set (Sphere), New_Position_2, Zero_Rotation);
                  end if;
               end;
            end loop;

         when Random_Globes_In_Orbits => null;

            Sphere_Angles := Sphere_Angles + Sphere_Increment_Fast;

            declare

               Sin_x : constant Real := Sin (Sphere_Angles (x));
               Cos_x : constant Real := Cos (Sphere_Angles (x));
               Sin_y : constant Real := Sin (Sphere_Angles (y));
               Cos_y : constant Real := Cos (Sphere_Angles (y));
               Sin_z : constant Real := Sin (Sphere_Angles (z));
               Cos_z : constant Real := Cos (Sphere_Angles (z));

               Radius : constant Real := Average (Swarm_Monitor.Mean_Radius);

               Phase : constant Positions :=
                 (x => Sin_z * Radius * Cos_x * Cos_y,
                  y => Sin_z * Radius * Cos_x * Sin_y,
                  z => Cos_z * Radius * Sin_x);

               Sphere_Offsets : constant array (Globes'Range) of Positions :=
                 (1 => Phase,
                  2 => -Phase,
                  3 => (x => Phase (x),
                        y => Phase (z),
                        z => Phase (y)),
                  4 => (x => -Phase (x),
                        y => -Phase (z),
                        z => -Phase (y)),
                  5 => (x => Phase (z),
                        y => Phase (y),
                        z => Phase (x)),
                  6 => (x => -Phase (z),
                        y => -Phase (y),
                        z => -Phase (x))
                 );

            begin
               for Globe_Ix in Globes'Range loop
                  declare
                     New_Position : constant Positions := Average (Swarm_Monitor.Centre_Of_Gravity) + Sphere_Offsets (Globe_Ix);

                     function No_of_Active_Globes (Ix : Positive) return Natural is
                       ((if Globes (Ix).Active then 1 else 0)
                        + (if Ix < Globes'Last then No_of_Active_Globes (Ix + 1) else 0));

                  begin
                     Globes (Globe_Ix).Velocity.all.Write ((New_Position - Globes (Globe_Ix).Position.all.Read) / Time_Interval_Real);
                     Globes (Globe_Ix).Position.all.Write (New_Position);
                     if Random (Zero_to_One_Generator) < 0.001 then
                        Globes (Globe_Ix).Active := not Globes (Globe_Ix).Active;
                        if No_of_Active_Globes (Globes'First) < 2 then
                           Globes (Globe_Ix).Active := True;
                        end if;
                     end if;
                     if Globes (Globe_Ix).Active then
                        Draw (Model_Set (Sphere), New_Position, Zero_Rotation);
                     end if;
                  end;
               end loop;
            end;

         when Globe_Grid_In_Centre =>

            for Globe_Ix in Globes'Range loop
               declare
                  New_Position : constant Positions := Average (Swarm_Monitor.Centre_Of_Gravity) + Energy_Globes_Defaults (Globe_Ix).Position;
               begin
                  Globes (Globe_Ix).Velocity.all.Write ((New_Position - Globes (Globe_Ix).Position.all.Read) / Time_Interval_Real);
                  Globes (Globe_Ix).Position.all.Write (New_Position);
                  Draw (Model_Set (Sphere), Globes (Globe_Ix).Position.all.Read, Zero_Rotation);
               end;
            end loop;

         when Globe_Grid_Drifting =>

            for Globe_Ix in Globes'Range loop
               Globes (Globe_Ix).Velocity.all.Write (Energy_Globes_Velocity);
               Globes (Globe_Ix).Position.all.Write (Globes (Globe_Ix).Position.all.Read + Energy_Globes_Velocity * Time_Interval_Real);
               Draw (Model_Set (Sphere), Globes (Globe_Ix).Position.all.Read, Zero_Rotation);
            end loop;

      end case;

      -- Coordinate axes for reference
      --

--        Draw_Lines (((-1.0, 0.0, 0.0), (1.0, 0.0, 0.0)));
--        Draw_Lines (((0.0, -1.0, 0.0), (0.0, 1.0, 0.0)));
--        Draw_Lines (((0.0, 0.0, -1.0), (0.0, 0.0, 1.0)));

      if Show_Axis then
         declare
            Beam_Colour_Red     : constant RGBA_Colour := (Red => 1.00, Green => 0.00, Blue => 0.00, Alpha => 1.00);
            Beam_Colour_Green   : constant RGBA_Colour := (Red => 0.00, Green => 1.00, Blue => 0.00, Alpha => 1.00);
            Beam_Colour_Blue    : constant RGBA_Colour := (Red => 0.00, Green => 0.00, Blue => 1.00, Alpha => 1.00);
            Beam_Colour_Magenta : constant RGBA_Colour := (Red => 1.00, Green => 0.00, Blue => 1.00, Alpha => 1.00);
            Beam_Colour_Cyan    : constant RGBA_Colour := (Red => 0.00, Green => 1.00, Blue => 1.00, Alpha => 1.00);
            Beam_Colour_Yellow  : constant RGBA_Colour := (Red => 1.00, Green => 1.00, Blue => 0.00, Alpha => 1.00);

         begin
            Draw_Laser ((-1.0,  0.0,  0.0), (1.0,  0.0,  0.0), Beam_Radius => 0.0001, Aura_Radius => 0.008, Beam_Colour => Beam_Colour_Red);
            Draw_Laser ((0.0,  -1.0,  0.0), (0.0,  1.0,  0.0), Beam_Radius => 0.0001, Aura_Radius => 0.008, Beam_Colour => Beam_Colour_Green);
            Draw_Laser ((0.0,   0.0, -1.0), (0.0,  0.0,  1.0), Beam_Radius => 0.0001, Aura_Radius => 0.008, Beam_Colour => Beam_Colour_Blue);

            Draw_Laser ((-1.0,  0.0, -1.0), (1.0,  0.0,  1.0), Beam_Radius => 0.0001, Aura_Radius => 0.008, Beam_Colour => Beam_Colour_Magenta);
            Draw_Laser ((-1.0,  0.0,  1.0), (1.0,  0.0, -1.0), Beam_Radius => 0.0001, Aura_Radius => 0.008, Beam_Colour => Beam_Colour_Magenta);

            Draw_Laser ((0.0,  -1.0, -1.0), (0.0,  1.0,  1.0), Beam_Radius => 0.0001, Aura_Radius => 0.008, Beam_Colour => Beam_Colour_Cyan);
            Draw_Laser ((0.0,  -1.0,  1.0), (0.0,  1.0, -1.0), Beam_Radius => 0.0001, Aura_Radius => 0.008, Beam_Colour => Beam_Colour_Cyan);

            Draw_Laser ((-1.0, -1.0,  0.0), (1.0,  1.0,  0.0), Beam_Radius => 0.0001, Aura_Radius => 0.008, Beam_Colour => Beam_Colour_Yellow);
            Draw_Laser ((-1.0,  1.0,  0.0), (1.0, -1.0,  0.0), Beam_Radius => 0.0001, Aura_Radius => 0.008, Beam_Colour => Beam_Colour_Yellow);
         end;
      end if;

      if Show_Text_Overlay then
         declare
            Text_Colour : constant RGBA_Colour := (Red => 0.40, Green => 0.44, Blue => 0.40, Alpha => 0.80);
            use Cursor_Management;
         begin
            Set_Colour (Text_Colour);
            Home;
            Text_2D ("Framerate: " & Natural'Image (FrameRate) & " Hz");             Line_Feed;
            Text_2D ("Number of vehicles"); Indend (105); Text_2D (": " & Natural'Image (Natural (Length (Swarm_State))));  Line_Feed;
            Text_2D ("Swarm velocity    "); Indend (105); Text_2D (": " & Real'Image (Vectors_3D."abs" (Swarm_Monitor.Mean_Velocity)));   Line_Feed;
            Text_2D ("Average velocity  "); Indend (105); Text_2D (": " & Real'Image (Swarm_Monitor.Mean_Velocity));         Line_Feed;
            Text_2D ("Max swarm radius  "); Indend (105); Text_2D (": " & Real'Image (Swarm_Monitor.Maximal_Radius));        Line_Feed;
            Text_2D ("Mean swarm radius "); Indend (105); Text_2D (": " & Real'Image (Swarm_Monitor.Mean_Radius));           Line_Feed;
            Text_2D ("Mean spacing      "); Indend (105); Text_2D (": " & Real'Image (Swarm_Monitor.Mean_Closest_Distance)); Paragraph_Feed;

            Text_2D ("Press <space> to change to chase mode");                       Line_Feed;
            Text_2D ("<alt-.> to toggle neighbourhood lines");                       Line_Feed;
            Text_2D ("<alt-,> to toggle axis lines");                                Paragraph_Feed;

            Text_2D ("Fullscreen: <alt-f>");                                         Line_Feed;
            Text_2D ("Screenshot: <alt-s>");                                         Line_Feed;
            Text_2D ("Reset camera: <alt-c>");                                       Paragraph_Feed;

            Text_2D ("Translations: <a|d|s|w|q|e> - Rotation: <j|l|k|i|u|o>");       Line_Feed;
            Text_2D ("<alt-t> to make this text disappear");                         Paragraph_Feed;

            Text_2D ("<+> to add a vehicle, <-> to remove one");                     Line_Feed;
         end;
      end if;

      Show_Drawing;

--        Set_All_Accelerations;
--        Forward_All_Messages;
--        Move_All_Elements;
--        Update_All_Rotations;

      Distribute_Jobs (Set_Accelerations);
      Distribute_Jobs (Forward_Messages);
      Distribute_Jobs (Move_Elements);
      Distribute_Jobs (Update_Rotations);
      Remove_Empties;

      Simulator_Tick.Tick;

   exception
      when E : others => Show_Exception (E);

   end Main_Operations;

   ----------------------------
   -- Initialize Environment --
   ----------------------------

   procedure Initialize_Environment is

   begin
      Cam := Initial_Cams (Camera_Mode);
      Swarm_Monitor.Append_Random_Swarm;
      Reset (Zero_to_One_Generator);
   exception
      when E : others => Show_Exception (E);
   end Initialize_Environment;

begin
   Initialize_Environment;
end Callback_Procedures;
