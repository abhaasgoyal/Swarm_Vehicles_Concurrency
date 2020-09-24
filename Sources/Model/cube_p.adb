--
 -- Jan & Uwe R. Zimmer, Australia, July 2011
 --

with GL, GL.Materials, GLOBE_3D.Math;

package body Cube_P is
   -- Pretty output: FALSE
   use GL, GL.Materials, GLOBE_3D, GLOBE_3D.Math;

   -- begin Separator # 1
   -- VRML: [# triangle mesh
   -- ]

   matos_1 : constant Material_type := (ambient =>   (0.0, 0.0, 0.0, 1.0),
                                      specular =>  (0.0, 0.0, 0.0, 1.0),
                                      diffuse =>   (1.0, 1.0, 1.0, 1.0),
                                      emission =>  (0.0, 0.0, 0.0, 1.0),
                                      shininess => 128.0);

   matos_red : constant Material_type := (ambient =>   (0.0, 0.0, 0.0, 1.0),
                                        specular =>  (0.0, 0.0, 0.0, 1.0),
                                        diffuse =>   (1.0, 0.0, 0.0, 1.0),
                                        emission =>  (0.0, 0.0, 0.0, 1.0),
                                        shininess => 128.0);
   matos_blue : constant Material_type := (ambient =>   (0.0, 0.0, 0.0, 1.0),
                                         specular =>  (0.0, 0.0, 0.0, 1.0),
                                         diffuse =>   (0.0, 0.0, 1.0, 1.0),
                                         emission =>  (0.0, 0.0, 0.0, 1.0),
                                         shininess => 128.0);

   coord_1 : constant Point_3D_array :=
     ((0.0, 0.0, 0.0), -- VRML: [# coord point    0
      -- ]
      (0.0, 0.0, 1.0), (1.0, 0.0, 0.0), (1.0, 0.0, 1.0), (1.0, 0.0, 0.0),
      (1.0, 0.0, 1.0), (1.0, 1.0, 0.0), (1.0, 1.0, 1.0), (1.0, 1.0, 0.0), (1.0, 1.0, 1.0),
      (0.0, 1.0, 0.0), (0.0, 1.0, 1.0), (0.0, 1.0, 0.0), (0.0, 1.0, 1.0), (0.0, 0.0, 0.0),
      (0.0, 0.0, 1.0), (0.0, 0.0, 0.0), (1.0, 0.0, 0.0), (1.0, 1.0, 0.0), (0.0, 1.0, 0.0),
      (0.0, 0.0, 1.0), (1.0, 0.0, 1.0), (1.0, 1.0, 1.0), (0.0, 1.0, 1.0)  --  24
     );
   -- VRML: [# 24 vertices
   -- ]
   -- begin Separator # 2
   -- VRML: [#triangle mesh
   -- ]

   idx_2 : constant Idx_4_array_array :=
     ((1, 3, 4, 0), -- VRML: [# triangle    0
      -- ]
      (1, 4, 2, 0), (5, 7, 8, 0), (5, 8, 6, 0), (9, 11, 12, 0), (9, 12, 10, 0), (13, 15, 16, 0), (13, 16, 14, 0),
      (18, 17, 20, 0), (20, 19, 18, 0), (22, 24, 21, 0), (24, 22, 23, 0) --  12
     );
   -- VRML: [# 12 triangles
   -- ]
   -- last index now: 0
   -- end Separator # 2
   -- VRML: [#triangle mesh
   -- ]
   -- last index now: 0
   -- end Separator # 2
   -- VRML: [# triangle mesh
   -- ]

   procedure Create (object       : in out GLOBE_3D.p_Object_3D;
                     object_scale :        GLOBE_3D.Real;
                     centre       :        GLOBE_3D.Point_3D)
   is
      face_0 : Face_type; -- takes defaults values
   begin
      object :=
        new Object_3D (Max_points => 24, Max_faces => 12);
      object.all.Centre := centre;
      Set_name (object.all, "insect_body");
      face_0.skin := material_only;
      face_0.material := VRML_Defaults;
      -- Creating separator # 1
      if Almost_zero (object_scale - 1.0) then
         object.all.Point (1 .. 24) := coord_1;
      else
         for p in 1 .. 24 loop
            object.all.Point (0 + p) := object_scale * coord_1 (p);
         end loop;
      end if;
      face_0.material := matos_1;
      -- Creating separator # 2
      for f in 1 .. 12 loop
         face_0.P := idx_2 (f);
         object.all.face (0 + f) := face_0;
      end loop;

      for f in 9 .. 10 loop
         object.all.face (f).material := matos_red;
      end loop;

      for f in 11 .. 12 loop
         object.all.face (f).material := matos_blue;
      end loop;

   end Create;
end Cube_P;
 -- Converted by Wrl2Ada
