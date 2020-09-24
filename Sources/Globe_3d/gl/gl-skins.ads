-------------------------------------------------------------------------
 --  GL.Skins - appearance of the surfaces of geometry primitives
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

with GL.Geometry, GL.Textures, GL.Materials;
with GL.Buffer.texture_coords;
--  with GL.Buffer.normals;

package GL.Skins is

   type Veneer is abstract tagged null record;   -- contains skin data specific to a particular geometric primitive.

   type p_Veneer is access all Veneer'Class;

   procedure Destroy (Self  : in out Veneer);
   procedure Free    (Self  : in out p_Veneer);

   procedure Enable (Self  : in out Veneer)   is abstract;

   -- 'Skin' : base of skin class

   type Skin is abstract tagged
      record
         null;
      end record;

   type p_Skin is access all Skin'Class;
   type Skin_Array is array (Positive range <>) of p_Skin;

   procedure Destroy (Self  : in out Skin);
   procedure Free    (Self  : in out p_Skin);

   function  New_Veneer (Self         : Skin;
                         for_Geometry : GL.Geometry.Geometry_t'Class) return p_Veneer is abstract;

   procedure Enable         (Self  : in out Skin)                  is abstract;
   function  is_Transparent (Self  :        Skin) return Boolean   is abstract;

   null_Skins : constant Skin_Array (1 .. 0) := (others => null);

   -- Skin : opaque unlit mono_color
   --

   type Skin_opaque_unlit_mono_color is new Skin with
      record
         Color  : RGB_Color;
      end record;

   overriding function  New_Veneer     (Self :        Skin_opaque_unlit_mono_color; for_Geometry : GL.Geometry.Geometry_t'Class) return p_Veneer;
   overriding procedure Enable         (Self : in out Skin_opaque_unlit_mono_color);
   overriding function  is_Transparent (Self :        Skin_opaque_unlit_mono_color) return Boolean;

   -- Skin : opaque lit mono_color
   --

   type Veneer_opaque_lit_mono_color (Max_Normals  : GL.Geometry.vertex_Id) is new Veneer with
      record
         Normals  : GL.Geometry.GL_Normals_Vertex_Id (1 .. Max_Normals);
      end record;

   overriding procedure Enable (Self  : in out Veneer_opaque_lit_mono_color);

   type Skin_opaque_lit_mono_color is new Skin with
      record
         Material  : GL.Materials.Material_type := Materials.neutral_material;
      end record;

   overriding function  new_Veneer (Self :        Skin_opaque_lit_mono_color; for_Geometry : GL.Geometry.Geometry_t'Class) return p_Veneer;
   overriding procedure Enable     (Self : in out Skin_opaque_lit_mono_color);

   overriding function  is_Transparent (Self : Skin_opaque_lit_mono_color) return Boolean;

   -- Skin : transparent unlit textured (used by 'impostor's)  -- tbd : get rid of 'transparent' since might not be !
   --

   type Veneer_transparent_unlit_textured (Num_Coordinates  : GL.Geometry.vertex_Id) is new Veneer with
      record
         Texture_Coordinates  : GL.Textures.Coordinate_2D_array (1 .. Num_Coordinates);
      end record;

   type p_Veneer_transparent_unlit_textured is access all Veneer_transparent_unlit_textured'Class;

   overriding procedure Enable (Self  : in out Veneer_transparent_unlit_textured);

   type Skin_transparent_unlit_textured is new Skin with
      record
         Texture               : GL.Textures.Object;
         Coordinate_Generator  : GL.Textures.p_coordinate_Generator;
      end record;

   type p_Skin_transparent_unlit_textured is access all Skin_transparent_unlit_textured;

   overriding procedure Destroy (Self  : in out Skin_transparent_unlit_textured);

   overriding function  New_Veneer     (Self :        Skin_transparent_unlit_textured; for_Geometry :  GL.Geometry.Geometry_t'Class) return p_Veneer;
   overriding procedure Enable         (Self : in out Skin_transparent_unlit_textured);
   overriding function  is_Transparent (Self :        Skin_transparent_unlit_textured) return Boolean;

   -- Skin : unlit textured vbo
   --

   type Veneer_unlit_textured_vbo is new Veneer with
      record
         -- texture_Coordinates  : GL.Buffer.vertex_buffer_Object;
         texture_Coordinates  : GL.Buffer.texture_coords.General_Object;
      end record;

   type p_Veneer_unlit_textured_vbo is access all Veneer_unlit_textured_vbo'Class;

   overriding procedure Enable (Self : in out Veneer_unlit_textured_vbo);

   -- tbd : 'destroy' for veneers !

   type Skin_unlit_textured_vbo is new Skin with
      record
         Texture  : GL.Textures.Object;
      end record;

   type p_Skin_unlit_textured_vbo is access all Skin_unlit_textured_vbo;

   overriding procedure Destroy (Self  : in out Skin_unlit_textured_vbo);

   overriding function  new_Veneer (Self :        Skin_unlit_textured_vbo; for_Geometry : GL.Geometry.Geometry_t'Class) return p_Veneer;
   overriding procedure Enable     (Self : in out Skin_unlit_textured_vbo);

   overriding function  is_Transparent (Self : Skin_unlit_textured_vbo) return Boolean;

   -- . .. other common skin specialisations . ..
   -- . ..

   -- standard skins
   --

   green_Skin     : p_Skin := new GL.Skins.Skin_opaque_unlit_mono_color'(Color => (Red   => 1.0,
                                                                                   Green => 1.0,
                                                                                   Blue  => 1.0));

   lit_green_Skin : p_Skin := new GL.Skins.Skin_opaque_lit_mono_color;  -- tbd : set to a green colour (defaults to neutral grey atm :)

   -- . .. other standard skins

end GL.Skins;

 -- tbd : use consistent naming for Max_* vs Num_*
