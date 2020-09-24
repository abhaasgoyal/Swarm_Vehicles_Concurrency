pragma Warnings (Off);
pragma Style_Checks (Off);

with GL.Buffer.general;
with GL.Geometry;

package GL.Buffer.vertex is new GL.Buffer.general (base_object   => GL.Buffer.array_Object,
                                                   index         => GL.geometry.positive_vertex_Id,
                                                   element       => GL.geometry.GL_Vertex,
                                                   element_array => GL.geometry.GL_vertex_Array);
