pragma Warnings (Off);
pragma Style_Checks (Off);

-------------------------------------------------------------------------
 --  GL.Geometry - GL geometry primitives
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

 -- with Ada.Numerics.Generic_Elementary_functions;
 -- with Ada.Text_IO; use Ada.Text_IO;

package body GL.Geometry.VBO is

   use GL.Buffer;

   function  primitive_Id (Self  : in     vbo_Geometry) return GL.ObjectTypeEnm
   is
   begin
      return self.primitive_Id;
   end;

   function  vertex_Count  (Self  : in     vbo_Geometry) return GL.geometry.vertex_Id
   is
   begin
      return vertex_Id (self.vertex_Count);
   end;

   function  indices_Count (Self  : in     vbo_Geometry) return GL.positive_uInt
   is
   begin
      return GL.positive_uInt (self.indices_Count);
   end;

   function  Bounds (Self  : in     vbo_Geometry) return GL.geometry.Bounds_record
   is
   begin
      return self.Bounds;
   end;

   procedure draw (Self  : in     vbo_Geometry)
   is
   begin
      self.Vertices.enable;
      GL.vertexPointer (3, GL_DOUBLE, 0, null);

      self.Indices.enable;

      GL.Enable_Client_State  (gl.VERTEX_ARRAY);

      GL.drawElements       (self.primitive_Id,  self.indices_Count, GL.UNSIGNED_INT, null);
      GL.Disable_Client_State (gl.VERTEX_ARRAY);
   end;

   --  Modified by zheng, 2011.1.20
   function Vertices (Self  : in     vbo_Geometry) return GL.geometry.GL_Vertex_array
   is
      self_buf : aliased vbo_Geometry :=self;
   begin
      return self_buf.Vertices.get;
   end;

   --  Modified by zheng, 2011.1.20
   function Indices (Self  : in     vbo_Geometry) return GL.geometry.vertex_Id_array
   is
      self_buf : aliased vbo_Geometry :=self;
      gl_Indices  : vertex_Id_array := self_buf.Indices.get;
   begin
      increment (gl_Indices);
      return gl_Indices;
   end;

   procedure destroy (Self  : in out vbo_Geometry)
   is
   begin
      destroy (self.Vertices);
      destroy (self.Indices);
   end;

end GL.Geometry.VBO;
