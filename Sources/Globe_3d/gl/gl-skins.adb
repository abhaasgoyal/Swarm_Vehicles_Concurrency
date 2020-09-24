-------------------------------------------------------------------------
 --  GL.Skins - models a 'skin' which describes the surface appearance of geometry.
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

 --  with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body GL.Skins is

   use GL.Geometry;
   use GL.Textures;
   use GL.Materials;

   -----------------------------------------------------------------
   -- tbd : ensure *all* skins disable *all* unneeded GL states !!!!!
   -----------------------------------------------------------------

   -- veneers
   --

   procedure Destroy (Self : in out Veneer) is

   begin
      null;
   end Destroy;

   procedure Free (Self  : in out p_Veneer) is

      procedure Deallocate is new Ada.Unchecked_Deallocation (Veneer'Class, p_Veneer);

   begin
      Destroy    (Self.all);
      Deallocate (Self);
   end Free;

   procedure Destroy (Self  : in out Skin) is

   begin
      null;
   end Destroy;

   procedure Free (Self  : in out p_Skin) is

      procedure Deallocate is new Ada.Unchecked_Deallocation (Skin'Class, p_Skin);

   begin
      Destroy    (Self.all);
      Deallocate (Self);
   end Free;

   procedure Set_Material (m : Materials.Material_type) is

--        use GL;

   begin
      Material (FRONT_AND_BACK, AMBIENT,   m.ambient);
      Material (FRONT_AND_BACK, DIFFUSE,   m.diffuse);
      Material (FRONT_AND_BACK, SPECULAR,  m.specular);
      Material (FRONT_AND_BACK, EMISSION,  m.emission);
      Material (FRONT_AND_BACK, SHININESS, m.shininess);
   end Set_Material;

   -- Skin_opaque_unlit_mono_color
   --

   overriding function New_Veneer (Self          : Skin_opaque_unlit_mono_color;
                                   for_Geometry  : GL.Geometry.Geometry_t'Class) return p_Veneer is (null);

   overriding procedure Enable (Self : in out Skin_opaque_unlit_mono_color) is

   begin
      GL.Disable              (LIGHTING);
      GL.Disable              (ALPHA_TEST);
      GL.Disable              (TEXTURE_2D);
      GL.Disable              (COLOR_MATERIAL);
      GL.Disable_Client_State (TEXTURE_COORD_ARRAY);

      Enable (BLEND); -- See 4.1.7 Blending
      BlendFunc (sfactor => SRC_ALPHA,
                 dfactor => ONE_MINUS_SRC_ALPHA);

      GL.Color   (Self.Color.Red,  Self.Color.Green,  Self.Color.Blue,  1.0);
   end Enable;

   overriding function is_Transparent (Self : Skin_opaque_unlit_mono_color) return Boolean is (False);

   -- Skin_opaque_lit_mono_color
   --

   overriding procedure Enable (Self : in out Veneer_opaque_lit_mono_color) is

   begin
      GL.BindBuffer          (GL.ARRAY_BUFFER, 0);    -- disable 'vertex buffer objects'
      GL.Enable_Client_State (GL.NORMAL_ARRAY);
      GL.Normal_Pointer      (GL_DOUBLE,  0,  to_Pointer (Self.Normals (1) (0)'Unchecked_Access));
   end Enable;

   overriding function new_Veneer (Self         : Skin_opaque_lit_mono_color;
                                   for_Geometry : GL.Geometry.Geometry_t'Class) return p_Veneer is
     (new Veneer_opaque_lit_mono_color'(Max_Normals => vertex_Count   (for_Geometry),
                                        normals     => Vertex_Normals (for_Geometry)));

   overriding procedure Enable (Self : in out Skin_opaque_lit_mono_color) is

   begin
      GL.Disable            (TEXTURE_2D);
      GL.Disable            (COLOR_MATERIAL);
      GL.Disable_Client_State (TEXTURE_COORD_ARRAY);
      GL.Disable            (ALPHA_TEST);

      GL.Enable    (LIGHTING);
      Set_Material (Self.Material);
   end Enable;

   overriding function is_Transparent (Self : Skin_opaque_lit_mono_color) return Boolean is (is_Transparent (Self.Material));

   -- Skin : transparent unlit textured
   --

   overriding procedure Enable (Self : in out Veneer_transparent_unlit_textured) is

   begin
      GL.BindBuffer          (GL.ARRAY_BUFFER, 0);    -- disable 'vertex buffer objects'
      GL.Enable_Client_State (GL.TEXTURE_COORD_ARRAY);
      GL.Tex_Coord_Pointer   (2,  GL_DOUBLE, 0, to_Pointer (Self.Texture_Coordinates (1).S'Unchecked_Access));
   end Enable;

   overriding procedure Destroy (Self  : in out Skin_transparent_unlit_textured) is

   begin
      Destroy (Self.Texture);
   end Destroy;

   overriding function New_Veneer (Self         : Skin_transparent_unlit_textured;
                                   for_Geometry : GL.Geometry.Geometry_t'Class) return p_Veneer is

      the_Veneer : constant p_Veneer_transparent_unlit_textured :=
        new Veneer_transparent_unlit_textured'(Num_Coordinates     => vertex_Count (for_Geometry),
                                               Texture_Coordinates => (others => (S => 0.0, T => 0.0)));
   begin
      if Self.Coordinate_Generator /= null then
         the_Veneer.all.Texture_Coordinates := To_Coordinates (Self.Coordinate_Generator.all, Vertices (for_Geometry));
      end if;

      return the_Veneer.all'Access;
   end New_Veneer;

   overriding procedure Enable (Self  : in out Skin_transparent_unlit_textured) is

   begin
      GL.Disable    (LIGHTING);
      GL.Disable    (COLOR_MATERIAL);
      GL.BindBuffer (GL.ARRAY_BUFFER, 0);    -- disable 'vertex buffer objects'

      GL.Color     (1.0, 1.0, 1.0, 1.0);

      GL.Enable     (ALPHA_TEST);
      GL.Alpha_Func (GREATER, 0.1);

      Enable (Self.Texture);
   end Enable;

   overriding function Is_Transparent (Self : Skin_transparent_unlit_textured) return Boolean is (Is_Transparent (Self.Texture));

   -- Skin : unlit textured vbo
   --

   overriding procedure Enable (Self  : in out Veneer_unlit_textured_vbo) is

      use GL.Buffer;

   begin
      Enable (Self.texture_Coordinates);
      GL.Tex_Coord_Pointer   (2, GL_DOUBLE, 0, null);
      GL.Enable_Client_State (GL.TEXTURE_COORD_ARRAY);
   end Enable;

   overriding procedure Destroy (Self : in out Skin_unlit_textured_vbo) is

   begin
      null;
   end Destroy;

   overriding function  New_Veneer (Self         : Skin_unlit_textured_vbo;
                                    for_Geometry : GL.Geometry.Geometry_t'Class) return p_Veneer is
     (new Veneer_unlit_textured_vbo);

   overriding procedure Enable (Self  : in out Skin_unlit_textured_vbo) is

   begin
      GL.Disable (LIGHTING);
      GL.Disable (ALPHA_TEST);

      Enable (Self.Texture);
   end Enable;

   overriding function Is_Transparent (Self : Skin_unlit_textured_vbo) return Boolean is (Is_Transparent (Self.Texture));

end GL.Skins;
