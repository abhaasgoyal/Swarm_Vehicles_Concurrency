pragma Warnings (Off);
pragma Style_Checks (Off);

with GL,
     GL.Textures,
     GL.Skins;                                 use GL, GL.Textures;
with GL.Buffer.vertex,
     GL.Buffer.indices,
     GL.Buffer.texture_coords;
with GL.Geometry.VBO;
with GL.skinned_Geometry;
with GL.IO;

with GLOBE_3D.Math;                            use GLOBE_3D.Math;

with Ada.Numerics;                             use Ada.Numerics;
with ada.text_io;                              use ada.text_io;

package body Terrain is

   -- tbd : this package uses a 'Sprite', whereas a 'triMesh.vbo' would probably be more appropriate.

   function to_Matrix (tga_Heights  : in String) return Matrix
   is
      use globe_3d, GL.IO;

      the_Image    : GL.io.Image                  := to_TGA_Image (tga_Heights);
      the_Pixels   : GL.io.Byte_grid              := to_greyscale_Pixels (the_Image);
      the_Heights  : Matrix (the_Pixels'Range (1),
                            the_Pixels'Range (2));
   begin
      for Row in the_Heights'Range (1) loop
         for Col in the_Heights'Range (2) loop
            the_Heights (Row, Col) := Real (the_Pixels (Row, Col));
         end loop;
      end loop;

      free (the_Image.Data);

      return the_Heights;
   end;

   function to_Height_Map (the_Matrix  : in Matrix) return height_Map
   is
      the_height_Map  : height_Map (column_Count => the_Matrix'Length (2),
                                   row_Count    => the_Matrix'Length (1));
   begin
      for Row in the_Matrix'Range (1) loop
         for Col in the_Matrix'Range (2) loop
            the_height_Map.Heights (Row, Col) := the_Matrix (Row, Col);

            the_height_Map.min_Height := Real'Min (the_height_Map.min_Height,  the_Matrix (Row, Col));
            the_height_Map.max_Height := Real'Max (the_height_Map.max_Height,  the_Matrix (Row, Col));
         end loop;
      end loop;

      return the_height_Map;
   end;

   function Width  (Self  : in height_Map) return Real
   is
   begin
      return Real (self.column_Count - 1);
   end;

   function Depth (Self  : in height_Map) return Real
   is
   begin
      return Real (self.row_Count - 1);
   end;

   function Vertex_Id_for (the_height_Map  : in height_Map;
                           Row, Col        : in Positive) return GL.geometry.vertex_Id is
   begin
      return GL.geometry.vertex_Id ((Row - 1) * the_height_Map.column_Count  +  Col);
   end Vertex_Id_for;

   procedure set (the_Vertices     : in out GL.geometry.GL_Vertex_Array;
                  from_height_Map  : in     height_Map;
                  scale            : in     GLOBE_3D.Vector_3D;
                  height_Offset    :    out Real)
   is
      use GLOBE_3D, GL, GL.Geometry, GLOBE_3D.REF, GLOBE_3D.Math, globe_3d.tri_Mesh;

      the_height_Offset  : Real               := from_height_Map.min_Height + (from_height_Map.max_Height - from_height_Map.min_Height) / 2.0;
      MidPoint           : GL.geometry.GL_Vertex := ((Real (from_height_Map.column_Count - 1) / 2.0),
                                                 the_height_Offset,
                                                 (Real (from_height_Map.row_Count - 1) / 2.0));

      procedure apply_scaling (the_Vertex  : in out Vector_3D) is
      begin
         the_Vertex (0) := the_Vertex (0) * Scale (0);
         the_Vertex (1) := the_Vertex (1) * Scale (1);
         the_Vertex (2) := the_Vertex (2) * Scale (2);
      end apply_scaling;

   begin
      for Row in from_height_Map.Heights'Range (1) loop
         for Col in from_height_Map.Heights'Range (2) loop
            declare
               use type GL.geometry.GL_Vertex;
               the_Point  : GL.geometry.GL_Vertex renames the_Vertices (Vertex_Id_for (from_height_Map,  Row, Col));
            begin
               the_Point := GL.geometry.GL_Vertex' (Real (Col) - 1.0,          -- '- 1.0' adjusts for '1 based' indexing.
                                                from_height_Map.Heights (Row, Col),
                                                Real (Row) - 1.0)
                            - Midpoint;

               apply_scaling (the_Point);
            end;
         end loop;
      end loop;

      height_Offset := Scale (1) * the_height_Offset;
   end set;

end Terrain;
