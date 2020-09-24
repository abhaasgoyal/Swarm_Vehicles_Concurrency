-------------------------------------------------------------------------
 --  GL.Geometry - GL geometry primitives
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

 -- with GLUT;

 -- with Ada.Text_IO;
 -- with Ada.Numerics.Generic_Elementary_functions;
 -- with Ada.Strings.Unbounded;
 -- with Ada.Unchecked_Deallocation;

package body GL.Skinned_Geometry is

   use GL.Geometry, GL.Skins;

   procedure Destroy (Self : in out Skinned_Geometry_t) is

   begin
      Free (Self.Geometry);
      Free (Self.Skin);
      Free (Self.Veneer);
   end Destroy;

end GL.Skinned_Geometry;
