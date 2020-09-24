-------------------------------------------------------------------------
 --  GL.Geometry - GL vertex buffer Object
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

--  with GL.Geometry;
--  with GL.Textures;

package GL.Buffer is

   subtype vbo_Name is GL.Uint;     -- an openGL vertex buffer 'name', which is a natural integer.

   -- buffer object
   --
   type Object is abstract tagged private;

   procedure Enable  (Self  :        Object'Class);
   procedure Destroy (Self  : in out Object'Class);

   function Extract_VBO_Target (Self : Object) return GL.VBO_Target is abstract;

   -- 'array' and 'element array' base classes
   --

   type array_Object         is new Object with private;
   type element_array_Object is new Object with private;

   -- refer to child packages, for specific buffers:
   --
   -- - GL.Buffer.vertex
   -- - GL.Buffer.texture_coords
   -- - GL.Buffer.normals
   -- - GL.Buffer.indices
   --
   -- (tbd : pixel pack/unpack buffers)

   no_platform_Support  : exception;
   --
   -- raised by buffer 'Map' functions when OS platform does not support GL Buffer objects.

private

   type Object is abstract tagged
      record
         Name    : aliased vbo_Name := 0;
         Length  :         Positive;
      end record;

   overriding function Extract_VBO_Target (Self : array_Object)         return GL.VBO_Target;
   overriding function Extract_VBO_Target (Self : element_array_Object) return GL.VBO_Target;

   type array_Object         is new Object with null record;
   type element_array_Object is new Object with null record;

   type vertex_buffer_Object is new array_Object with null record;

   -- support

   procedure Verify_Name (Self  : in out Object'Class);

end GL.Buffer;
