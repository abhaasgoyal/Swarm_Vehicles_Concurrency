pragma Warnings (Off);
pragma Style_Checks (Off);

package body GLOBE_3D.Culler is

   procedure Viewer_is (Self  : in out Culler'Class;   Now  : p_Window)
   is
   begin
      self.Viewer := Now.all'Access;
   end;

   function Viewer (Self  : in     Culler'Class) return p_Window
   is
   begin
      return self.Viewer;
   end;

end globe_3d.Culler;
