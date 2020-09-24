-------------------------------------------------------------------------
 --  GL.Geometry - GL vertex buffer Object
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

--  with GL.Errors;

--  with Ada.Numerics.Generic_Elementary_functions;
--  with Ada.Text_IO; use Ada.Text_IO;

--  with System;

package body GL.Buffer is

   -- 'Name' support
   --

   function new_vbo_Name return vbo_Name is

      the_Name : aliased vbo_Name;

   begin
      GL.Gen_Buffers (1,  the_Name'Unchecked_Access);
      return the_Name;
   end new_vbo_Name;

   procedure Free (the_vbo_Name : vbo_Name) is

      the_Name  : aliased vbo_Name := the_vbo_Name;

   begin
      GL.Delete_Buffers (1, the_Name'Unchecked_Access);
   end Free;

   pragma Unreferenced (Free);

   -- object
   --

   procedure Verify_Name (Self : in out Object'Class) is

   begin
      if Self.Name = 0 then
         Self.Name := new_vbo_Name;
      end if;
   end Verify_Name;

   procedure Enable (Self : Object'Class) is

   begin
      pragma Assert (Self.Name > 0);

      GL.BindBuffer (Extract_VBO_Target (Self),  Self.Name);
   end Enable;

   procedure Destroy (Self : in out Object'Class) is

   begin
      GL.BindBuffer    (Extract_VBO_Target (Self), 0);
      GL.Delete_Buffers (1, Self.Name'Unchecked_Access);
   end Destroy;

   -- array object
   --

   overriding function Extract_VBO_Target (Self : array_Object) return GL.VBO_Target is (GL.ARRAY_BUFFER);

   -- element array object
   --

   overriding function Extract_VBO_Target (Self : element_array_Object) return GL.VBO_Target is (GL.ELEMENT_ARRAY_BUFFER);

 --     -- texture coordinates
 --     --
 --
 --     procedure set_texture_Coordinates (Self  : in out vertex_buffer_Object;   To  : access GL.textures.Coordinate_2D_array)
 --     is
 --        use type GL.SizeIPtr;
 --     begin
 --        verify_Name (Self);
 --
 --        GL.bindBuffer (gl.ARRAY_BUFFER,  self.Name);
 --        GL.bufferData (gl.ARRAY_BUFFER,  To.all'size / 8,
 --                                         to_Pointer (To (To'First).S'Access),
 --                                         GL.STATIC_DRAW);                        -- tbd : make this a parameter.
 --     end;

end GL.Buffer;
