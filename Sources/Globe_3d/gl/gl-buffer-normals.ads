
with GL.Buffer.general; pragma Elaborate_All (GL.Buffer.general);
with GL.Geometry;

package GL.Buffer.normals is new GL.Buffer.general (base_object   => GL.Buffer.array_Object,
                                                    index         => GL.Geometry.positive_vertex_Id,
                                                    element       => GL.Geometry.GL_Normal,
                                                    element_array => GL.Geometry.GL_Normals_Vertex_Id);
