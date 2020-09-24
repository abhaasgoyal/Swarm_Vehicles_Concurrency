-------------------------------------------------------------------------
 --  GL.Buffer.general - a generic for producing the various types of openGL vertex buffer objects.
 --
 --  Copyright (c) Rod Kay 2007
 --  AUSTRALIA
 --  Permission granted to use this software, without any warranty,
 --  for any purpose, provided this copyright note remains attached
 --  and unmodified if sources are distributed further.
 -------------------------------------------------------------------------

with Interfaces.C.Pointers;

generic
   type base_Object is new GL.Buffer.Object with private;

   type Index         is mod <>;
   type Element       is private;
   type Element_Array is array (Index range <>) of aliased Element;

package GL.Buffer.general is

   pragma Elaborate_Body;

   type General_Object is new base_Object with private;

   function  To_Buffer (From : access Element_Array; Usage  : VBO_Usage) return General_Object;

   procedure Set (Self         : in out General_Object;
                  Set_Position :        Positive := 1;    -- tbd : make this raise 'constraint_Error' instead of openGL_Error, when bounds are violated.
                  To           :        Element_Array);
   function  Get (Self : access General_Object) return Element_Array;

   -- buffer memory map
   --

   type memory_Map is abstract tagged private;

   procedure Release (Self : memory_Map);
   --
   -- 'release' must be called to release the buffers data back to the GL server.
   --
   -- May raise Corrupt_Buffer if the Buffer has become corrupt since the data
   -- was initially mapped. This can occur for system - specific reasons that affect the availability of graphics memory,
   -- such as screen mode changes. In such situations, the data store contents are undefined, and an application
   -- reinitialize the data store.
   --
   Corrupt_Buffer  : exception;

   type read_only_Map  is new memory_Map with private;

   function  Map (Self  : access General_Object) return read_only_Map'Class;

   function  Get (Self : read_only_Map; Get_Position : Index) return Element;
   function  Get (Self : read_only_Map; Get_Position : Index; Count : Positive) return Element_Array;

   type write_only_Map is new memory_Map with private;

   function  Map (Self : access General_Object) return write_only_Map'Class;

   procedure Set (Self : write_only_Map; Set_Position : Index; To : access Element);
   procedure Set (Self : write_only_Map; Set_Position : Index; To :        Element);

   type read_write_Map is new memory_Map with private;

   function  Map (Self  : access General_Object) return read_write_Map'Class;

   function  Get (Self : read_write_Map; Get_Position : Index) return Element;
   function  Get (Self : read_write_Map; Get_Position : Index; Count : Positive) return Element_Array;

   procedure Set (Self : read_write_Map; Set_Position : Index; To : access Element);
   procedure Set (Self : read_write_Map; Set_Position : Index; To :        Element);

private

   type General_Object is new base_Object with null record;

   default_Terminator : Element;     -- no 'i.c.Pointers' subprogram is called which uses this, so a default 'Element' should suffice.

   pragma Warnings (Off, """default_Terminator"" may be referenced before it has a value");
   package Element_Pointers is new interfaces.C.Pointers (Index, Element, Element_Array, default_Terminator);
   pragma Warnings (On,  """default_Terminator"" may be referenced before it has a value");

   type memory_Map is abstract tagged
      record
         vbo_Target  : GL.VBO_Target;

         Data  : Element_Pointers.Pointer;
         Last  : Index;
      end record;

   type read_only_Map  is new memory_Map with null record;
   type write_only_Map is new memory_Map with null record;
   type read_write_Map is new memory_Map with null record;

end GL.Buffer.general;
