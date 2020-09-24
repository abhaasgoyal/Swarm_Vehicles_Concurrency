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

with GL.Buffer.vertex;
with GL.Buffer.indices;
 -- with ada.unchecked_Deallocation;

package GL.Geometry.VBO is

   -- vertex buffer object geometry
   --

   type vbo_Geometry is new Geometry_t with
      record
         primitive_Id   :         GL.ObjectTypeEnm;
         vertex_Count   :         GL.SizeI;
         indices_Count  :         GL.SizeI;
         Vertices       : aliased GL.Buffer.vertex.General_Object;
         Indices        : aliased GL.Buffer.indices.General_Object;    -- Indices of 'Vertices' which describe the primitive geometry.
      end record;

   type p_vbo_Geometry is access all vbo_Geometry;

   function  primitive_Id  (Self  : in     vbo_Geometry) return GL.ObjectTypeEnm;

   function  vertex_Count  (Self  : in     vbo_Geometry) return GL.geometry.vertex_Id;
   function  Vertices      (Self  : in     vbo_Geometry) return GL.geometry.GL_Vertex_array;

   function  indices_Count (Self  : in     vbo_Geometry) return GL.positive_uInt;
   function  Indices       (Self  : in     vbo_Geometry) return GL.geometry.vertex_Id_array;

   function  Bounds        (Self  : in     vbo_Geometry) return GL.geometry.Bounds_record;

   procedure Draw          (Self  : in     vbo_Geometry);

   procedure destroy       (Self  : in out vbo_Geometry);

end GL.Geometry.VBO;
