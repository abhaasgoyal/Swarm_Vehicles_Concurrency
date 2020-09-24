
with GL.Buffer.general; pragma Elaborate_All (GL.Buffer.general);
with GL.Geometry;
with GL.Textures;

package GL.Buffer.texture_coords is new GL.Buffer.general (base_object   => GL.Buffer.array_Object,
                                                           index         => GL.Geometry.Positive_Vertex_Id,
                                                           element       => GL.Textures.Coordinate_2D,
                                                           element_array => GL.Textures.Coordinate_2D_array);
