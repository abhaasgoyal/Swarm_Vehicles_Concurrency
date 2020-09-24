
with GL.Buffer.general; pragma Elaborate_All (GL.Buffer.general);
with GL.Geometry;

package GL.Buffer.indices is new GL.Buffer.general (base_object   => GL.Buffer.element_array_Object,
                                                    index         => GL.positive_uInt,
                                                    element       => GL.geometry.vertex_Id,
                                                    element_array => GL.geometry.vertex_Id_Array);
