with GL;
with GLOBE_3D.Math;

package body Actors is

--     use GLOBE_3D, GLOBE_3D.Math, GLOBE_3D.REF, Game_Control, GL;
   use GLOBE_3D, GLOBE_3D.Math, Game_Control, GL;

   procedure Limited_Translation (actor          : in out GLOBE_3D.Camera;
                                  gc             :        Game_Control.Command_set;
                                  gx, gy         :        GLOBE_3D.Real;
                                  unitary_change :        GLOBE_3D.Real;
                                  deceleration   :        GLOBE_3D.Real;
                                  time_step      :        GLOBE_3D.Real) is

      pragma Unreferenced (gx);

      unitary_movement, eye_movement : Real;
      step : Vector_3D;

   begin
      unitary_movement := (case gc (run_mode) is
                           when True  => 300.0,
                           when False => 100.0);
      unitary_movement := unitary_movement * unitary_change;
      eye_movement := unitary_movement * 2.0;

      actor.Speed (2) := actor.Speed (2) + (case gc (go_forward) is
                                            when True  => -eye_movement,
                                            when False => +eye_movement);

      actor.Speed (1) := actor.Speed (1) + (if    gc (slide_vertical_graduated) then +gy * 2.0 * unitary_movement
                                            elsif gc (slide_down)               then -eye_movement
                                            elsif gc (slide_up)                 then +eye_movement
                                            else 0.0);
      actor.Speed (0) := actor.Speed (0) + (if    gc (slide_vertical_graduated) then +gy * 2.0 * unitary_movement
                                            elsif gc (slide_down)               then -eye_movement
                                            elsif gc (slide_up)                 then +eye_movement
                                            else 0.0);

      step := time_step * (Transpose (actor.World_Rotation) * actor.Speed);
      --  (speed (0),    -- lateral sliding
      --    speed (1),    -- vertical sliding
      --    speed (2));  -- forward/backwards
      --   -- ^ vector in the local referential

      Limiting (step);

      actor.Clipper.Eye_Position := actor.Clipper.Eye_Position + step;

      actor.Speed := deceleration * actor.Speed;

   end Limited_Translation;

   procedure No_Limitation (step : in out GLOBE_3D.Vector_3D) is
   null;

   procedure Translation_inst is new Limited_Translation (No_Limitation);

   procedure Translation (actor          : in out GLOBE_3D.Camera;
                          gc             :        Game_Control.Command_set;
                          gx, gy         :        GLOBE_3D.Real;
                          unitary_change :        GLOBE_3D.Real;
                          deceleration   :        GLOBE_3D.Real;
                          time_step      :        GLOBE_3D.Real) renames Translation_inst;

   procedure Rotation (actor          : in out GLOBE_3D.Camera;
                       gc             :        Game_Control.Command_set;
                       gx, gy         :        GLOBE_3D.Real;
                       unitary_change :        GLOBE_3D.Real;
                       deceleration   :        GLOBE_3D.Real;
                       time_step      :        GLOBE_3D.Real) is

      incremental_rotation : Vector_3D := (0.0, 0.0, 0.0);

   begin
      Abstract_rotation (gc, gx, gy,
                         unitary_change, deceleration, incremental_rotation, time_step,
                         actor.rotation_Speed);
      actor.rotation := actor.rotation + incremental_rotation;
      if actor.compose_rotations then
         actor.World_Rotation :=
           XYZ_rotation (incremental_rotation) * actor.World_Rotation;
         Re_Orthonormalize (actor.World_Rotation);
      else
         declare
            r : Vector_3D renames actor.rotation;
            -- We need to turn around the axes in this order : Y, X, Z
         begin
            actor.World_Rotation :=
              XYZ_rotation (0.0,  0.0, r (2)) *  -- 3) turn around the nose
              XYZ_rotation (r (0),  0.0,  0.0) *  -- 2) lift or lower the head
              XYZ_rotation (0.0, r (1),  0.0);    -- 1) pivotate around the feet
         end;
      end if;
   end Rotation;

   procedure Abstract_rotation (gc             :        Game_Control.Command_set;
                                gx, gy         :        GLOBE_3D.Real;
                                unitary_change :        GLOBE_3D.Real;
                                deceleration   :        GLOBE_3D.Real;
                                vector         : in out GLOBE_3D.Vector_3D;
                                time_step      :        GLOBE_3D.Real;
                                rotation_speed : in out GLOBE_3D.Vector_3D) is

      unitary_movement, mouse_rotation, key_rotation : Real;

   begin
      if gc (run_mode) then
         unitary_movement := 40.0;
      else
         unitary_movement := 20.0;
      end if;
      unitary_movement := unitary_movement * unitary_change;
      mouse_rotation := 2.0  * unitary_movement;
      key_rotation  := 0.17 * unitary_movement;

      if gc (swing_plus) then
         rotation_speed (2) := rotation_speed (2) + key_rotation;
      end if;
      if gc (swing_minus) then
         rotation_speed (2) := rotation_speed (2) - key_rotation;
      end if;
      if gc (turn_left) then
         rotation_speed (1) := rotation_speed (1) + key_rotation;
      end if;
      if gc (turn_right) then
         rotation_speed (1) := rotation_speed (1) - key_rotation;
      end if;
      if gc (turn_up) then
         rotation_speed (0) := rotation_speed (0) - key_rotation;
      end if;
      if gc (turn_down) then
         rotation_speed (0) := rotation_speed (0) + key_rotation;
      end if;
      if gc (turn_lateral_graduated) then
         rotation_speed (1) := rotation_speed (1) - gx * mouse_rotation;
      end if;
      if gc (turn_vertical_graduated) then
         rotation_speed (0) := rotation_speed (0) - gy * mouse_rotation;
      end if;
      vector := vector + time_step * rotation_speed;
      rotation_speed := deceleration * rotation_speed;
   end Abstract_rotation;

   procedure Abstract_rotation (gc             :        Game_Control.Command_set;
                                gx, gy         :        GLOBE_3D.Real;
                                unitary_change :        GLOBE_3D.Real;
                                deceleration   :        GLOBE_3D.Real;
                                rot_matrix     : in out GLOBE_3D.Matrix_33;
                                time_step      :        GLOBE_3D.Real;
                                rotation_speed : in out GLOBE_3D.Vector_3D) is

      incremental_rotation : Vector_3D := (0.0, 0.0, 0.0);

   begin
      Abstract_rotation (gc, gx, gy,
                         unitary_change, deceleration, incremental_rotation, time_step,
                         rotation_speed);
      rot_matrix := rot_matrix * XYZ_rotation (incremental_rotation);
   end Abstract_rotation;

end Actors;
