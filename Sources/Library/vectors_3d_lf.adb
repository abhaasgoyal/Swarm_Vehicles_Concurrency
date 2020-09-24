--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

package body Vectors_3D_LF is

   function "*" (V_Left, V_Right : Vector_3D_LF) return Vector_3D_LF is
     (x => (V_Left (y) * V_Right (z) - V_Left (z) * V_Right (y)),
      y => (V_Left (z) * V_Right (x) - V_Left (x) * V_Right (z)),
      z => (V_Left (x) * V_Right (y) - V_Left (y) * V_Right (x)));

end Vectors_3D_LF;
