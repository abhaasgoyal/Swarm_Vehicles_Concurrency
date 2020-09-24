-------------------------------------------------------------------------
 --  GL.Errors - GL error support
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with GLU;
with Interfaces.C.Strings;     use Interfaces.C.Strings;

package body GL.Errors is

   function Current return String is

      function to_chars_ptr is new Ada.Unchecked_Conversion (GL.ubytePtr, chars_ptr);

   begin
      return Value (to_chars_ptr (GLU.Error_String (GL.Get_Error)));
   end Current;

   procedure log (Prefix : String := "") is

      Current_GL_Error : constant String := Current;

   begin
      if Current_GL_Error /= "no error" then
         case Prefix = "" is
            when True  => Put_Line ("openGL error : '" & Current_GL_Error & "'");
            when False => Put_Line (Prefix &    " : '" & Current_GL_Error & "'");
         end case;

         raise openGL_Error;  -- tbd : use ada.exceptions to attach the openg error string to the exception.
      end if;
   end log;

   procedure log (Prefix : String := ""; error_Occurred : out Boolean) is

      Current_GL_Error  : constant String := Current;

   begin
      error_Occurred := Current_GL_Error /= "no error";
      if error_Occurred then
         case Prefix = "" is
            when True  => Put_Line ("openGL error : '" & Current_GL_Error & "'");
            when False => Put_Line (Prefix &    " : '" & Current_GL_Error & "'");
         end case;
      end if;
   end log;

end GL.Errors;
