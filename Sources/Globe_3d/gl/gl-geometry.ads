-------------------------------------------------------------------------
 --  GL.Geometry - GL geometry primitives
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;
with Interfaces.C.Pointers;
with Ada.Unchecked_Conversion;

package GL.Geometry is

   -- planes
   --

   type Plane is array (0 .. 3) of aliased GL.Double;   -- a general plane in equation form (tbd : use  1 .. 4  ?)

   procedure Normalise (the_Plane  : in out Plane);

   -- bounds
   --

   type Extent is
      record
         Min, Max  : GL.Double;
      end record;

   function Max (L, R : Extent) return Extent;

   type Axis_Aligned_Bounding_Box is
      record
         X_Extent  : Extent;    -- extents in object space
         Y_Extent  : Extent;
         Z_Extent  : Extent;
      end record;

   function Max (L, R : Axis_Aligned_Bounding_Box) return Axis_Aligned_Bounding_Box;

   type Bounds_record is   -- tbd : better name . .. 'type Bounds' conflicts with 'Bounds' trait function. . .. sphere_box_Bounds ?
      record
         Sphere_Radius  : GL.Double;
         Box            : Axis_Aligned_Bounding_Box;
      end record;

   null_Bounds  : constant Bounds_record := (Sphere_Radius => 0.0,
                                             Box           => (X_Extent => (Min => GL.Double'Last,
                                                                            Max => GL.Double'First),
                                                               Y_Extent => (Min => GL.Double'Last,
                                                                            Max => GL.Double'First),
                                                               Z_Extent => (Min => GL.Double'Last,
                                                                            Max => GL.Double'First)));

   function Max (L, R : Bounds_record) return Bounds_record;

   -- vertices
   --

   -- vertex Id (an index into a vertex_Array)
   --

   type   vertex_Id       is new GL.Uint;
   type p_vertex_Id       is access all vertex_Id;

   type   vertex_Id_array is array (GL.positive_uInt range <>) of aliased vertex_Id;
   type p_vertex_Id_array is access all vertex_Id_array;

   function to_gl_Pointer is new Ada.Unchecked_Conversion (p_vertex_Id, GL.pointer);

   procedure Increment (Self  : in out vertex_Id_array);
   procedure Decrement (Self  : in out vertex_Id_array);

   function  to_void_Pointer is new Ada.Unchecked_Conversion   (p_vertex_Id,     GL.pointer);
   procedure free            is new Ada.Unchecked_Deallocation (vertex_Id_array, p_vertex_Id_array);

   subtype Positive_Vertex_Id is vertex_Id range 1 .. vertex_Id'Last;

   -- vertex
   --

   subtype GL_Vertex       is GL.Double_Vector_3D;                             -- tbd : can GL.Double_vector_3D use '1'- based indexing ?
   type    GL_Vertex_array is array (Positive_Vertex_Id range <>) of aliased GL_Vertex;
   type  p_Vertex_array is access all GL_Vertex_array;

   package vertex_pointers is new interfaces.C.Pointers (Positive_Vertex_Id, GL_Vertex, GL_Vertex_array, (others => GL.Double'Last));
   subtype p_Vertex is vertex_pointers.Pointer;

   function to_p_Vertex is new Ada.Unchecked_Conversion (GL.pointer, p_Vertex);
   function Image (Self : GL_Vertex) return String;

   null_Vertex  : constant GL_Vertex := (GL.Double'Last, GL.Double'Last, GL.Double'Last); -- tbd : use NAN instead of 'Last ?

   procedure free is new Ada.Unchecked_Deallocation (GL_Vertex_array, p_Vertex_array);

   function Bounds (Self : GL_Vertex_array) return GL.Geometry.Bounds_record;
   function Image  (Self : GL_Vertex_array) return String;

   function Bounds (Given_Vertices : GL_Vertex_array; Given_Indices : vertex_Id_array) return GL.Geometry.Bounds_record;

   -- lighting normals
   --

   subtype GL_Normal            is GL.Double_Vector_3D;
   type    GL_Normals           is array (Positive           range <>) of aliased GL_Normal;
   type    GL_Normals_Vertex_Id is array (Positive_Vertex_Id range <>) of aliased GL_Normal;  -- tbd : rename vertex_Normal_array

   -- abstract base geometry class
   --

   type Geometry_t is abstract tagged
      record
         Bounds  : Bounds_record;
      end record;

   type p_Geometry is access all Geometry_t'Class;

   function  primitive_Id   (Self : Geometry_t) return GL.ObjectTypeEnm             is abstract;

   function  vertex_Count   (Self : Geometry_t) return GL.Geometry.vertex_Id        is abstract;
   function  Vertices       (Self : Geometry_t) return GL.Geometry.GL_Vertex_array  is abstract;

   function  indices_Count  (Self : Geometry_t) return GL.positive_uInt             is abstract;
   function  Indices        (Self : Geometry_t) return GL.Geometry.vertex_Id_array  is abstract;

   function  Bounds         (Self : Geometry_t) return GL.Geometry.Bounds_record    is abstract;

   function  Face_Count     (Self : Geometry_t'Class) return Natural;
   --
   -- for point primitives, each point is considered a 'face'.
   -- for line  primitives, each line  is considered a 'face'.

   procedure Draw           (Self : Geometry_t)                                     is abstract;

   function  Vertex_Normals (Self : Geometry_t'Class) return GL_Normals_Vertex_Id;

   procedure destroy (Self : in out Geometry_t)                                     is abstract;
   procedure Free    (Self : in out p_Geometry);

end GL.Geometry;
