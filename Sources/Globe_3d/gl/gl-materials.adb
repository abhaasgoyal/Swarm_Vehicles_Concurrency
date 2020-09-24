package body GL.Materials is

   function is_Transparent (Self : Material_type) return Boolean is (Self.diffuse (3) < 1.0);

end GL.Materials;
