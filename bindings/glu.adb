with Ada.Unchecked_Conversion, System;

package body GLU is

  type loc_DoublePtr is new GL.doublePtr;

  pragma No_Strict_Aliasing (Matrix_Double_Ptr);
  pragma No_Strict_Aliasing (Viewport_Ptr);
  pragma No_Strict_Aliasing (loc_DoublePtr);
  -- recommended by GNAT 2005

  procedure Get (pname  : GL.ParameterNameEnm;
                 params : out Matrix_Double) is
    function Cvt is new Ada.Unchecked_Conversion (System.Address, Matrix_Double_Ptr);
    -- This method is functionally identical as GNAT's Unrestricted_Access
    -- but has no type safety (cf GNAT Docs)
  begin
    Get (pname, Cvt (params (0, 0)'Address));
  end Get;

  procedure Get (params : out Viewport_Rec) is
    function Cvt is new Ada.Unchecked_Conversion (System.Address, Viewport_Ptr);
  begin
    Get (GL.VIEWPORT, Cvt (params.X'Address));
  end Get;

  procedure Project (objx        : GL.Double;
                     objy        : GL.Double;
                     objz        : GL.Double;
                     modelMatrix : Matrix_Double;
                     projMatrix  : Matrix_Double;
                     viewport    : Viewport_Rec;
                     winx        : out GL.Double;
                     winy        : out GL.Double;
                     winz        : out GL.Double;
                     result      : out Boolean)
  is
    function CvV is new Ada.Unchecked_Conversion (System.Address, Viewport_Ptr);
    function CvM is new Ada.Unchecked_Conversion (System.Address, Matrix_Double_Ptr);
    function Cvt is new Ada.Unchecked_Conversion (System.Address, loc_DoublePtr);
    wx, wy, wz : GL.Double;
    use GL;
  begin
    -- Call the same function with C style
    result := Project (
      objx, objy, objz,
      CvM (modelMatrix'Address),
      CvM (projMatrix'Address),
      CvV (viewport'Address),
      GL.doublePtr (Cvt (wx'Address)),
      GL.doublePtr (Cvt (wy'Address)),
      GL.doublePtr (Cvt (wz'Address))
)
    =
      GL.GL_Boolean'Pos (GL.GL_True);
    winx := wx;
    winy := wy;
    winz := wz;
  end Project;

end GLU;
