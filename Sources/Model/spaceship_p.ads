--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with GLOBE_3D;

package Spaceship_P is

   procedure Create (Object       : in out GLOBE_3D.p_Object_3D;
                     Object_Scale :        GLOBE_3D.Real;
                     Centre       :        GLOBE_3D.Point_3D);

end Spaceship_P;
