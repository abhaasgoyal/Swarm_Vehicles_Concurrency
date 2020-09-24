--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with GLOBE_3D;

package Models is

   pragma Elaborate_Body;

   type Model_Name is (Spaceship, Sphere);

--     type Model_Name is (Arrow,
--                         Cube,
--                         Duck,
--                         Plane,
--                         Spaceship,
--                         Spaceship_Ruby,
--                         Sphere);

   type Gradient_Materials is (G_Turquoise, G_Ruby);

   type Models_Field   is array (Model_Name)                                     of GLOBE_3D.p_Object_3D;
   type Gradient_Field is array (Gradient_Materials range <>, Positive range <>) of GLOBE_3D.p_Object_3D;

   Model_Set : Models_Field;

   Spaceship_Gradient : Gradient_Field (Gradient_Materials'Range, 1 .. 10);

end Models;
