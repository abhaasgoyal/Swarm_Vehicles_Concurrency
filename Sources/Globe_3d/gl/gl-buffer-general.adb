-------------------------------------------------------------------------
--  GL.Geometry - GL vertex buffer Object
--
--  Copyright (c) Rod Kay 2007
--  AUSTRALIA
--  Permission granted to use this software, without any warranty,
--  for any purpose, provided this copyright note remains attached
--  and unmodified if sources are distributed further.
-------------------------------------------------------------------------

with GL.Errors;

--  with Ada.Numerics.Generic_Elementary_Functions;
--  with Ada.Text_IO; use Ada.Text_IO;

--  with System;

package body GL.Buffer.general is

   use Element_Pointers;

   function to_gl_Pointer      is new Ada.Unchecked_Conversion (Element_Pointers.Pointer, GL.pointer);
   function to_element_Pointer is new Ada.Unchecked_Conversion (GL.pointer,               Element_Pointers.Pointer);

   -- vertex buffer object
   --

   function To_Buffer (From  : access Element_Array;   Usage  : VBO_Usage) return General_Object is

      use type GL.sizeiPtr;

      new_Buffer  : General_Object;

   begin
      Verify_Name (new_Buffer);
      new_Buffer.Length := From'Length;

      Enable (new_Buffer);
      GL.Buffer_Data (Extract_VBO_Target (new_Buffer),  From.all'Size / 8,
                      to_gl_Pointer (From.all (From'First)'Access),
                      Usage);
      return new_Buffer;
   end To_Buffer;

   procedure Set (Self          : in out General_Object;
                  Set_Position  :        Positive := 1;
                  To            :        Element_Array) is

      use type GL.sizeiPtr;

      new_Vertices         : aliased Element_Array := To;
      Vertex_Size_in_bits  : constant Natural                 := To (To'First)'Size;

   begin
      Enable (Self);
      GL.BufferSubData (Extract_VBO_Target (Self),  offset => GL.intPtr ((Set_Position - 1) * Vertex_Size_in_bits / 8),
                        size   => new_Vertices'Size / 8,
                        data   => to_gl_Pointer (new_Vertices (new_Vertices'First)'Unchecked_Access));
      GL.Errors.log;
   end Set;

   function Get (Self : access General_Object) return Element_Array is

      --        use GL.Geometry, GL.Buffer;

      the_Map      : read_only_Map'Class renames Map (Self);
      the_Vertices : constant Element_Array := Get (the_Map, Index'First, Self.all.Length);

   begin
      Release (the_Map);
      return the_Vertices;
   end Get;

   -- memory Maps
   --

   procedure Release (Self : memory_Map) is

      Status  : constant GL_Boolean := UnmapBuffer (Self.vbo_Target);

   begin
      if Status /= GL_True then
         raise Corrupt_Buffer;
      end if;
   end Release;

   function Get (Self : memory_Map; Get_Position : Index) return Element is

      use Interfaces.C;

      Start : constant Element_Pointers.Pointer := Self.Data + ptrdiff_t (Get_Position - 1);

   begin
      return Value (Start, 1) (1);
   end Get;

   function Get (Self         : memory_Map;
                 Get_Position : Index;
                 Count        : Positive) return Element_Array is

      use Interfaces.C;

      Start  : constant Element_Pointers.Pointer := Self.Data + ptrdiff_t (Get_Position - 1);

   begin
      return Value (Start, ptrdiff_t (Count));
   end Get;

   procedure Set (Self         :        memory_Map;
                  Set_Position :        Index;
                  To           : access Element) is

      --        use GL.Geometry, Element_Pointers, interfaces.C;
      use Interfaces.C;

   begin
      Copy_Array (Element_Pointers.Pointer (To),  Self.Data + ptrdiff_t (Set_Position - 1),  1);
   end Set;

   procedure Set (Self         : memory_Map;
                  Set_Position : Index;
                  To           : Element) is

      the_Vertex : aliased Element := To;

   begin
      Set (Self, Set_Position, To => the_Vertex'Unchecked_Access);
   end Set;

   -- read - only

   function Map (Self : access General_Object) return read_only_Map'Class is

      --        use GL.Geometry;

      the_Map  : read_only_Map;

   begin
      Enable (Self.all);

      the_Map.Data := to_element_Pointer (MapBuffer (Extract_VBO_Target (Self.all),  GL.READ_ONLY));
      if the_Map.Data = null then
         raise GL.Buffer.no_platform_Support;
      end if;

      the_Map.Last       := Index (Self.all.Length);
      the_Map.vbo_Target := Extract_VBO_Target (Self.all);

      return the_Map;
   end Map;

   function Get (Self : read_only_Map; Get_Position : Index) return Element is (Get (memory_Map (Self), Get_Position));

   function Get (Self         : read_only_Map;
                 Get_Position : Index;
                 Count        : Positive) return Element_Array is (Get (memory_Map (Self), Get_Position, Count));

   -- write - only

   function Map (Self : access General_Object) return write_only_Map'Class is

      --        use GL.Geometry;

      the_Map  : write_only_Map;

   begin
      Enable (Self.all);

      the_Map.Data := to_element_Pointer (MapBuffer (Extract_VBO_Target (Self.all), GL.WRITE_ONLY));
      if the_Map.Data = null then
         raise GL.Buffer.no_platform_Support;
      end if;

      the_Map.Last       := Index (Self.all.Length);
      the_Map.vbo_Target := Extract_VBO_Target (Self.all);

      return the_Map;
   end Map;

   procedure Set (Self         :        write_only_Map;
                  Set_Position :        Index;
                  To           : access Element) is

   begin
      Set (memory_Map (Self), Set_Position, To);
   end Set;

   procedure Set (Self         : write_only_Map;
                  Set_Position : Index;
                  To           : Element) is

   begin
      Set (memory_Map (Self), Set_Position, To);
   end Set;

   -- read - write

   function Map (Self  : access General_Object) return read_write_Map'Class is

      --        use GL.Geometry;

      the_Map  : read_write_Map;

   begin
      Enable (Self.all);

      the_Map.Data := to_element_Pointer (MapBuffer (Extract_VBO_Target (Self.all), GL.READ_WRITE));
      if the_Map.Data = null then
         raise GL.Buffer.no_platform_Support;
      end if;

      the_Map.Last       := Index (Self.all.Length);
      the_Map.vbo_Target := Extract_VBO_Target (Self.all);

      return the_Map;
   end Map;

   function Get (Self : read_write_Map; Get_Position : Index) return Element is (Get (memory_Map (Self), Get_Position));

   function Get (Self          : read_write_Map;
                  Get_Position : Index;
                  Count        : Positive) return Element_Array is (Get (memory_Map (Self), Get_Position, Count));

   procedure Set (Self         :        read_write_Map;
                  Set_Position :        Index;
                  To           : access Element) is

   begin
      Set (memory_Map (Self), Set_Position, To);
   end Set;

   procedure Set (Self         : read_write_Map;
                  Set_Position : Index;
                  To           : Element) is

   begin
      Set (memory_Map (Self), Set_Position, To);
   end Set;

end GL.Buffer.general;
