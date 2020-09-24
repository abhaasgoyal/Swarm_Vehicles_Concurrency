-- Changes
 --
 -- 11 - Nov - 2009 (GdM) : Unbounded_Stream.Write and .Set_Index are buffered
 -- 18 - Jan - 2009 (GdM) : Fixed Read (Stream, Item .. .) which read
 --                      only 1st element of Item

 -- with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;
 -- with Ada.Text_IO; -- use Ada.Text_IO;
with Zip;
package body Zip_Streams is

   procedure Set_Name (S : access Root_Zipstream_Type; Stream_Name : String) is

   begin
      S.all.Name := To_Unbounded_String (Stream_Name);
   end Set_Name;

   function Get_Name (S : access Root_Zipstream_Type) return String is (To_String (S.all.Name));

   procedure Set_Time (S : access Root_Zipstream_Type; Modification_Time : Time) is

   begin
      S.all.Modification_Time := Modification_Time;
   end Set_Time;

   function Get_Time (S : access Root_Zipstream_Type) return Time is (S.all.Modification_Time);

   procedure Set_Time (S                 : Zipstream_Class;
                       Modification_Time : Ada.Calendar.Time) is

   begin
     Set_Time (S, Calendar.Convert (Modification_Time));
   end Set_Time;

   function Get_Time (S : Zipstream_Class) return Ada.Calendar.Time is (Calendar.Convert (Get_Time (S)));

   procedure Set_Unicode_Name_Flag (S     : access Root_Zipstream_Type;
                                    Value :        Boolean) is

   begin
     S.all.Is_Unicode_Name := Value;
   end Set_Unicode_Name_Flag;

   function Is_Unicode_Name (S : access Root_Zipstream_Type) return Boolean is (S.all.Is_Unicode_Name);

   ---------------------------------------------------------------------
   -- Unbounded_Stream : stream based on an in - memory Unbounded_String --
   ---------------------------------------------------------------------

   procedure Get (Str  : Memory_Zipstream; Unb  : out Unbounded_String) is

   begin
      Unb := Str.Unb;
   end Get;

   procedure Set (Str  : in out Memory_Zipstream; Unb  : Unbounded_String) is

   begin
      Str.Unb := Null_Unbounded_String; -- clear the content of the stream
      Str.Unb := Unb;
      Str.Loc := 1;
   end Set;

   overriding procedure Read (Zip_Stream : in out Memory_Zipstream;
                              Item       :    out Stream_Element_Array;
                              Last       :    out Stream_Element_Offset) is

   begin
      -- Item is read from the stream. If (and only if) the stream is
      -- exhausted, Last will be < Item'Last. In that case, T'Read will
      -- raise an End_Error exception.
      --
      -- Cf : RM 13.13.1 (8), RM 13.13.1 (11), RM 13.13.2 (37) and
      -- explanations by Tucker Taft
      --
      Last := Item'First - 1;
      -- if Item is empty, the following loop is skipped; if Stream.Loc
      -- is already indexing out of Stream.Unb, that value is also appropriate
      for i in Item'Range loop
         Item (i) := Character'Pos (Element (Zip_Stream.Unb, Zip_Stream.Loc));
         Zip_Stream.Loc := Zip_Stream.Loc + 1;
         Last := i;
      end loop;
   exception
      when Ada.Strings.Index_Error =>
         null; -- what could be read has been read; T'Read will raise End_Error
   end Read;

   max_chunk_size : constant := 16 * 1024;

   overriding procedure Write (Zip_Stream : in out Memory_Zipstream;
                               Item       :        Stream_Element_Array) is

     I : Stream_Element_Offset := Item'First;
     chunk_size : Integer;
     tmp : String (1 .. max_chunk_size);

   begin
     while I <= Item'Last loop
       chunk_size := Integer'Min (Integer (Item'Last - I + 1), max_chunk_size);
       if Zip_Stream.Loc > Length (Zip_Stream.Unb) then
         -- . .. we are off the string's bounds, we need to extend it.
         for J in 1 .. chunk_size loop
           tmp (J) := Character'Val (Item (I));
           I := I + 1;
         end loop;
         Append (Zip_Stream.Unb, tmp (1 .. chunk_size));
       else
         -- . .. we can work (at least for a part) within the string's bounds.
         chunk_size := Integer'Min (chunk_size, Length (Zip_Stream.Unb) - Zip_Stream.Loc + 1);
         for J in 0 .. chunk_size - 1 loop
           Replace_Element (Zip_Stream.Unb, Zip_Stream.Loc + J, Character'Val (Item (I)));
           -- GNAT 2008's Replace_Slice does something very general
           -- even in the trivial case where one can make:
           -- Source.Reference (Low .. High) := By;
           -- - > still faster with elem by elem replacement
           -- Anyway, this place is not critical for zipping : only the
           -- local header before compressed data is rewritten after
           -- compression. So usually, we are off bounds.
           I := I + 1;
         end loop;
       end if;
       Zip_Stream.Loc := Zip_Stream.Loc + chunk_size;
     end loop;
   end Write;

   overriding procedure Set_Index (S  : access Memory_Zipstream; To  : Positive) is

     I, chunk_size : Integer;

   begin
     if To > Length (S.all.Unb) then
       -- . .. we are off the string's bounds, we need to extend it.
       I := Length (S.all.Unb) + 1;
       while I <= To loop
         chunk_size := Integer'Min (To - I + 1, max_chunk_size);
         Append (S.all.Unb, (1 .. chunk_size => ASCII.NUL));
         I := I + chunk_size;
       end loop;
     end if;
     S.all.Loc := To;
   end Set_Index;

   overriding function Size (S : access Memory_Zipstream) return Integer is (Length (S.all.Unb));

   overriding function Index (S : access Memory_Zipstream) return Integer is (S.all.Loc);

   overriding function End_Of_Stream (S : access Memory_Zipstream) return Boolean is

   begin
      if Size (S) < Index (S) then
         return True;
      else
         return False;
      end if;
   end End_Of_Stream;

   --------------------------------------------
   -- File_Zipstream : stream based on a file --
   --------------------------------------------

   procedure Open (Str  : in out File_Zipstream; Zipfile_Mode  : File_Mode) is

   begin
      Ada.Streams.Stream_IO.Open (Str.File, Zipfile_Mode, To_String (Str.Name),
                                 Form => To_String (Zip.Form_For_IO_Open_N_Create));
   end Open;

   procedure Create (Str  : in out File_Zipstream; Zipfile_Mode  : File_Mode) is

   begin
      Ada.Streams.Stream_IO.Create (Str.File, Zipfile_Mode, To_String (Str.Name),
                                 Form => To_String (Zip.Form_For_IO_Open_N_Create));
   end Create;

   procedure Close (Str  : in out File_Zipstream) is

   begin
      Ada.Streams.Stream_IO.Close (Str.File);
   end Close;

   overriding procedure Read (Zip_Stream : in out File_Zipstream;
                              Item       :    out Stream_Element_Array;
                              Last       :    out Stream_Element_Offset) is

   begin
      Ada.Streams.Stream_IO.Read (Zip_Stream.File, Item, Last);
   end Read;

   overriding procedure Write (Zip_Stream : in out File_Zipstream;
                               Item       :        Stream_Element_Array) is

   begin
      Ada.Streams.Stream_IO.Write (Zip_Stream.File, Item);
   end Write;

   overriding procedure Set_Index (S : access File_Zipstream; To : Positive) is

   begin
      Ada.Streams.Stream_IO.Set_Index (S.all.File, Positive_Count (To));
   end Set_Index;

   overriding function Size (S : access File_Zipstream) return Integer is (Integer (Ada.Streams.Stream_IO.Size (S.all.File)));

   overriding function Index (S : access File_Zipstream) return Integer is (Integer (Ada.Streams.Stream_IO.Index (S.all.File)));

   overriding function End_Of_Stream (S  : access File_Zipstream) return Boolean is (Ada.Streams.Stream_IO.End_Of_File (S.all.File));

   package body Calendar is

      -----------------------------------------------
      -- Time = DOS Time. Valid through Year 2107. --
      -----------------------------------------------

      procedure Split (Date          : Time;
                       Year_Num      : out Year_Number;
                       Month_Num     : out Month_Number;
                       Day_Num       : out Day_Number;
                       No_of_Seconds : out Day_Duration) is

         d_date  : constant Integer := Integer (Date  /  65536);
         d_time  : constant Integer := Integer (Date and 65535);
--           use Interfaces;
         hours        : Integer;
         minutes      : Integer;
         seconds_only : Integer;
      begin
         Year_Num := 1980 + d_date / 512;
         Month_Num := (d_date / 32) mod 16;
         Day_Num  := d_date mod 32;
         hours   := d_time / 2048;
         minutes := (d_time / 32) mod 64;
         seconds_only := 2 * (d_time mod 32);
         No_of_Seconds := Day_Duration (hours * 3600 + minutes * 60 + seconds_only);
      end Split;
      --
      function Time_Of (Year_Num      : Year_Number;
                        Month_Num     : Month_Number;
                        Day_Num       : Day_Number;
                        No_of_Seconds : Day_Duration := 0.0) return Time is

         year_2           : Integer := Year_Num;
         use Interfaces;
         hours            : Unsigned_32;
         minutes          : Unsigned_32;
         seconds_only     : Unsigned_32;
         seconds_day      : Unsigned_32;
         result : Unsigned_32;
      begin

         if year_2 < 1980 then -- avoid invalid DOS date
           year_2 := 1980;
         end if;
         seconds_day := Unsigned_32 (No_of_Seconds);
         hours := seconds_day / 3600;
         minutes :=  (seconds_day / 60) mod 60;
         seconds_only := seconds_day mod 60;
         result :=
           -- MSDN formula for encoding:
             Unsigned_32 ((year_2 - 1980) * 512 + Month_Num * 32 + Day_Num) * 65536 -- Date
           +
             hours * 2048 + minutes * 32 + seconds_only / 2; -- Time
         return Time (result);
      end Time_Of;

      function Convert (date : Ada.Calendar.Time) return Time is

         year_num         : Year_Number;
         month_num        : Month_Number;
         day_num          : Day_Number;
         seconds_day_dur  : Day_Duration;

      begin
         Split (date, year_num, month_num, day_num, seconds_day_dur);
         return Time_Of (year_num, month_num, day_num, seconds_day_dur);
      end Convert;

      function Convert (date : Time) return Ada.Calendar.Time is

         year_num         : Year_Number;
         month_num        : Month_Number;
         day_num          : Day_Number;
         seconds_day_dur  : Day_Duration;

      begin
         Split (date, year_num, month_num, day_num, seconds_day_dur);
         return Time_Of (year_num, month_num, day_num, seconds_day_dur);
      end Convert;

      function Convert (date : DOS_Time) return Time is (Time (date));     -- currently a trivial conversion

      function Convert (date : Time) return DOS_Time is (DOS_Time (date)); -- currently a trivial conversion

   end Calendar;

end Zip_Streams;
