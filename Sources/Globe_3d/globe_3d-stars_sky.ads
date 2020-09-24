generic

  No_of_Stars : Natural := 400;
  far_side    : GLOBE_3D.Real;

package GLOBE_3D.Stars_sky is

   pragma Elaborate_Body;

   procedure Display (Rotation : Matrix_33);

end GLOBE_3D.Stars_sky;
