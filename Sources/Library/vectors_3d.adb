--
-- Jan & Uwe R. Zimmer, Australia, September 2019
--

package body Vectors_3D is

   function "*" (V_Left, V_Right : Vector_3D) return Vector_3D is
     (x => (V_Left (y) * V_Right (z) - V_Left (z) * V_Right (y)),
      y => (V_Left (z) * V_Right (x) - V_Left (x) * V_Right (z)),
      z => (V_Left (x) * V_Right (y) - V_Left (y) * V_Right (x)));

end Vectors_3D;
