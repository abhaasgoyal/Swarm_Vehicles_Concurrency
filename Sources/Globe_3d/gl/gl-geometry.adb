-------------------------------------------------------------------------
 --  GL.Geometry - GL geometry primitives
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

with GL.Math; use GL.Math;

with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
--  with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Characters.Latin_1;

package body GL.Geometry is

   package GL_Double_EF is new Ada.Numerics.Generic_Elementary_Functions (GL.Double);  -- tbd : make this public ?

   -- Plane
   --

   procedure Normalise (the_Plane : in out Plane) is

      use GL_Double_EF;
      inv_Magnitude  : constant GL.Double := 1.0 / Sqrt (the_Plane (0) * the_Plane (0)
                                                       + the_Plane (1) * the_Plane (1)
                                                       + the_Plane (2) * the_Plane (2));
   begin
      the_Plane := (0 => the_Plane (0) * inv_Magnitude,
                    1 => the_Plane (1) * inv_Magnitude,
                    2 => the_Plane (2) * inv_Magnitude,
                    3 => the_Plane (3) * inv_Magnitude);
   end Normalise;

   -- Bounds
   --

   function Max (L, R : Extent) return Extent is
     (Min => GL.Double'Max (L.Min,  R.Min),
      Max => GL.Double'Max (L.Max,  R.Max));

   function Max (L, R : Axis_Aligned_Bounding_Box) return Axis_Aligned_Bounding_Box is
     (X_Extent => Max (L.X_Extent,  R.X_Extent),
      Y_Extent => Max (L.Y_Extent,  R.Y_Extent),
      Z_Extent => Max (L.Z_Extent,  R.Z_Extent));

   function Max (L, R : Bounds_record) return Bounds_record is
     (Sphere_Radius => GL.Double'Max (L.Sphere_Radius, R.Sphere_Radius),
      Box           => Max (L.Box, R.Box));

   -- vertex_Id's
   --

   procedure Increment (Self  : in out vertex_Id_array) is

   begin
      for Each in Self'Range loop
         Self (Each) := Self (Each) + 1;
      end loop;
   end Increment;

   procedure Decrement (Self  : in out vertex_Id_array) is

   begin
      for Each in Self'Range loop
         Self (Each) := Self (Each) - 1;
      end loop;
   end Decrement;

   -- vertices
   --

   function Image (Self : GL_Vertex) return String is
     (" (" & Double'Image (Self (0)) & Double'Image (Self (1)) & Double'Image (Self (2)) & ")");

   function Bounds (Self : GL_Vertex_array) return GL.Geometry.Bounds_record is

      use GL_Double_EF;
      the_Bounds      : Bounds_record := null_Bounds;
      max_Distance_2  : GL.Double     := 0.0;      -- current maximum distance squared.

   begin
      for p in Self'Range loop
         max_Distance_2 := GL.Double'Max (Self (p) (0) * Self (p) (0)
                                        + Self (p) (1) * Self (p) (1)
                                        + Self (p) (2) * Self (p) (2),
                                          max_Distance_2);

         the_Bounds.Box := (X_Extent => (Min => GL.Double'Min (the_Bounds.Box.X_Extent.Min,  Self (p) (0)),
                                         Max => GL.Double'Max (the_Bounds.Box.X_Extent.Max,  Self (p) (0))),
                            Y_Extent => (Min => GL.Double'Min (the_Bounds.Box.Y_Extent.Min,  Self (p) (1)),
                                         Max => GL.Double'Max (the_Bounds.Box.Y_Extent.Max,  Self (p) (1))),
                            Z_Extent => (Min => GL.Double'Min (the_Bounds.Box.Z_Extent.Min,  Self (p) (2)),
                                         Max => GL.Double'Max (the_Bounds.Box.Z_Extent.Max,  Self (p) (2))));
      end loop;

      the_Bounds.Sphere_Radius := Sqrt (max_Distance_2);

      return the_Bounds;
   end Bounds;

   function Bounds (Given_Vertices : GL_Vertex_array; Given_Indices : vertex_Id_array) return GL.Geometry.Bounds_record is

      use GL_Double_EF;
      the_Bounds      : Bounds_record := null_Bounds;
      max_Distance_2  : GL.Double     := 0.0;      -- current maximum distance squared.

   begin
      for Each in Given_Indices'Range loop
         declare
            the_Point  : GL_Vertex renames Given_Vertices (Given_Indices (Each));
         begin
            max_Distance_2 := GL.Double'Max (the_Point (0) * the_Point (0)
                                           + the_Point (1) * the_Point (1)
                                           + the_Point (2) * the_Point (2),
                                             max_Distance_2);

            the_Bounds.Box := (X_Extent => (Min => GL.Double'Min (the_Bounds.Box.X_Extent.Min,  the_Point (0)),
                                            Max => GL.Double'Max (the_Bounds.Box.X_Extent.Max,  the_Point (0))),
                               Y_Extent => (Min => GL.Double'Min (the_Bounds.Box.Y_Extent.Min,  the_Point (1)),
                                            Max => GL.Double'Max (the_Bounds.Box.Y_Extent.Max,  the_Point (1))),
                               Z_Extent => (Min => GL.Double'Min (the_Bounds.Box.Z_Extent.Min,  the_Point (2)),
                                            Max => GL.Double'Max (the_Bounds.Box.Z_Extent.Max,  the_Point (2))));
         end;
      end loop;

      the_Bounds.Sphere_Radius := Sqrt (max_Distance_2);

      return the_Bounds;
   end Bounds;

   function Face_Count (Self : Geometry_t'Class) return Natural is

      the_Count  : Natural;

   begin
      case primitive_Id (Self) is
         when POINTS =>
            the_Count := Natural (indices_Count (Self));

         when LINES =>
            the_Count := Natural (indices_Count (Self) / 2);

         when LINE_LOOP =>
            the_Count := Natural (indices_Count (Self));

         when LINE_STRIP =>
            the_Count := Natural'Max (Natural (indices_Count (Self) - 1),  0);

         when TRIANGLES =>
            the_Count := Natural (indices_Count (Self) / 3);

         when TRIANGLE_STRIP =>
            the_Count := Natural'Max (Natural (indices_Count (Self) - 2),  0);

         when TRIANGLE_FAN =>
            the_Count := Natural'Max (Natural (indices_Count (Self) - 2),  0);

         when QUADS =>
            the_Count := Natural (indices_Count (Self) / 4);

         when QUAD_STRIP =>
            the_Count := Natural (indices_Count (Self) / 2  -  1);

         when POLYGON =>
            the_Count := 1;
      end case;

      return the_Count;
   end Face_Count;

   function Image (Self : GL_Vertex_array) return String is

      the_Image  : Unbounded_String;
      NL         : constant String := (1 => Ada.Characters.Latin_1.LF);   -- NL : New Line

   begin
      Append (the_Image, " (" & NL);
      for Each in Self'Range loop
         Append (the_Image, " " & vertex_Id'Image (Each) & " => " & Image (Self (Each)) & NL);
      end loop;
      Append (the_Image, ")" & NL);

      return To_String (the_Image);
   end Image;

   -- abstract base geometry class
   --

   procedure Free (Self  : in out p_Geometry) is

      procedure deallocate is new Ada.Unchecked_Deallocation (Geometry_t'Class, p_Geometry);

   begin
      destroy    (Self.all);
      deallocate (Self);
   end Free;

   function Vertex_Normals (Self : Geometry_t'Class) return GL_Normals_Vertex_Id is

   begin
      case primitive_Id (Self) is
         when TRIANGLES =>
            declare
               the_Vertices        :          GL_Vertex_array    renames Vertices (Self);
               the_Indices         :          vertex_Id_array renames Indices (Self);
               the_Normals         :          GL_Normals_Vertex_Id (the_Vertices'Range);

               Triangle_Face_Count : constant Positive := the_Indices'Length / 3;
               face_Normals        :          GL_Normals  (1 .. Triangle_Face_Count);

               N                   :          GL.Double_Vector_3D;
               length_N            :          GL.Double;

               function vertex_Id_for (Face : Positive; point_Id : Positive) return vertex_Id is
                 (the_Indices (positive_uInt (3 * (Face - 1) + point_Id)));

            begin
               -- Geometry (Normal of unrotated face)
               --
               for each_Face in 1 .. Triangle_Face_Count loop
                  N := (the_Vertices (vertex_Id_for (each_Face, 2)) - the_Vertices (vertex_Id_for (each_Face, 1)))
                     * (the_Vertices (vertex_Id_for (each_Face, 3)) - the_Vertices (vertex_Id_for (each_Face, 1)));
                  length_N := Norm (N);

                  case Almost_zero (length_N) is
                     when True  => face_Normals (each_Face) := N; -- 0 vector !
                     when False => face_Normals (each_Face) := (1.0 / length_N) * N;
                  end case;
               end loop;

               -- Calculate normal at each vertex.
               --
               declare
                  vertex_adjacent_faces_Count  : array (the_Vertices'Range) of Natural := (others => 0);
                  the_Vertex                   : vertex_Id;
                  Vertex_Length                : Double;
               begin

                  for p in the_Vertices'Range loop
                     the_Normals (p) := (0.0, 0.0, 0.0);
                  end loop;

                  for f in 1 .. Triangle_Face_Count loop
                     for p in 1 .. 3 loop
                        the_Vertex := vertex_Id_for (f, p);

                        vertex_adjacent_faces_Count (the_Vertex) := vertex_adjacent_faces_Count (the_Vertex) + 1;
                        the_Normals (the_Vertex)                 := the_Normals (the_Vertex) + face_Normals (f);
                     end loop;
                  end loop;

                  for p in the_Vertices'Range loop

                     Vertex_Length := Norm (the_Normals (p));

                     if not Almost_zero (Vertex_Length) then
                        the_Normals (p) := (1.0 / Vertex_Length) * the_Normals (p);
                     else
                        null; -- raise Constraint_Error;  -- tbd : proper exception as usual.
                     end if;
                  end loop;

               end;

               return the_Normals;
            end;

         when others =>
            raise Constraint_Error; -- tbd : finish these
      end case;

--        return Normal_array' (1 .. 0 => (others => 0.0));
   end Vertex_Normals;

end GL.Geometry;
