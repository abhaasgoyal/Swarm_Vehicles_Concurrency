--
 -- Jan & Uwe R. Zimmer, Australia, July 2011
 --

with GLOBE_3D;

package Plane_P is

   procedure Create (object       : in out GLOBE_3D.p_Object_3D;
                     object_scale :        GLOBE_3D.Real;
                     centre       :        GLOBE_3D.Point_3D);

end Plane_P;
