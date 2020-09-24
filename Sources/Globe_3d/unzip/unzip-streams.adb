with Zip.Headers, UnZip.Decompress;

with Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;
with Interfaces;                        use Interfaces;

package body UnZip.Streams is

   procedure Dispose is new
     Ada.Unchecked_Deallocation (String, p_String);

   procedure Dispose is new
     Ada.Unchecked_Deallocation (Ada.Streams.Stream_Element_Array,
                                 p_Stream_Element_Array);

   procedure Dispose is new
     Ada.Unchecked_Deallocation (UnZip_Stream_Type,
                                 Zipped_File_Type);

   --------------------------------------------------
   -- *The* internal 1 - file unzipping procedure.   --
   -- Input must be _open_ and won't be _closed_ ! --
   --------------------------------------------------

   procedure UnZipFile (zip_file         :        Zip_Streams.Zipstream_Class;
                        header_index     : in out Ada.Streams.Stream_IO.Positive_Count;
                        mem_ptr          :    out p_Stream_Element_Array;
                        password         : in out Ada.Strings.Unbounded.Unbounded_String;
                        hint_comp_size   :        File_size_type; -- Added 2007 for .ODS files
                        cat_uncomp_size  :        File_size_type) is

      work_index : Ada.Streams.Stream_IO.Positive_Count := header_index;
      local_header : Zip.Headers.Local_File_Header;
      data_descriptor_present : Boolean;
      encrypted : Boolean;
      method : PKZip_method;
      use Ada.Streams.Stream_IO, Zip, Zip_Streams;
   begin
      begin
         Zip_Streams.Set_Index (zip_file, Positive (header_index));
         declare
            TempStream  : constant Zipstream_Class := zip_file;
         begin
            Zip.Headers.Read_and_check (TempStream, local_header);
         end;
      exception
         when Zip.Headers.bad_local_header =>
            raise;
         when others =>
            raise Read_Error;
      end;

      method := Method_from_code (local_header.zip_type);
      if method = unknown then
         raise Unsupported_method;
      end if;

      -- calculate offset of data

      work_index :=
        work_index + Ada.Streams.Stream_IO.Count (
                                                  local_header.filename_length    +
                                                    local_header.extra_field_length +
                                                      Zip.Headers.local_header_length
                                                 );

      data_descriptor_present := (local_header.bit_flag and 8) /= 0;

      if data_descriptor_present then
         -- Sizes and crc are after the data
         local_header.dd.crc_32 := 0;
         local_header.dd.uncompressed_size := cat_uncomp_size;
         local_header.dd.compressed_size   := hint_comp_size;
      else
         -- Sizes and crc are before the data
         if cat_uncomp_size /= local_header.dd.uncompressed_size then
            raise Uncompressed_size_Error;
         end if;
      end if;

      encrypted := (local_header.bit_flag and 1) /= 0;

      begin
         Zip_Streams.Set_Index (zip_file, Positive (work_index)); -- eventually skips the file name
      exception
         when others => raise Read_Error;
      end;

      -- Unzip correct type
      UnZip.Decompress.Decompress_data (
                                        zip_file             => zip_file,
                                        format               => method,
                                        mode                 => write_to_memory,
                                        output_file_name     => "",
                                        output_memory_access => mem_ptr,
                                        feedback             => null,
                                        explode_literal_tree => (local_header.bit_flag and 4) /= 0,
                                        explode_slide_8KB    => (local_header.bit_flag and 2) /= 0,
                                        end_data_descriptor  => data_descriptor_present,
                                        encrypted            => encrypted,
                                        password             => password,
                                        get_new_password     => null,
                                        hint                 => local_header.dd
                                       );

      -- Set the offset on the next zipped file
      header_index := header_index +
        Count (
               File_size_type (
                 local_header.filename_length    +
                   local_header.extra_field_length +
                     Zip.Headers.local_header_length
                ) +
                 local_header.dd.compressed_size
              );

      if data_descriptor_present then
         header_index := header_index + Count (Zip.Headers.data_descriptor_length);
      end if;

   end UnZipFile;

   use Ada.Streams.Stream_IO;

   procedure S_Extract (from           :     Zip.Zip_info;
                        Zip_Stream     :     Zip_Streams.Zipstream_Class;
                        what           :     String;
                        mem_ptr        : out p_Stream_Element_Array;
                        Password       :     String;
                        Case_sensitive :     Boolean) is

      header_index  : Positive_Count;
      comp_size     : File_size_type;
      uncomp_size   : File_size_type;
      work_password : Ada.Strings.Unbounded.Unbounded_String :=
        Ada.Strings.Unbounded.To_Unbounded_String (Password);

   begin
      Zip.Find_offset (from, what, Case_sensitive,
                       header_index,
                       comp_size,
                       uncomp_size);

      UnZipFile (Zip_Stream,
                 header_index,
                 mem_ptr,
                 work_password,
                 comp_size,
                 uncomp_size);
      pragma Unreferenced (header_index, work_password);

   end S_Extract;

   -------------------- for exportation:

   procedure Close (File  : in out Zipped_File_Type) is
   begin
      if File = null or else File.all.state = uninitialized then
         raise Use_Error;
      end if;
      if File.all.delete_info_on_closing then
         Zip.Delete (File.all.archive_info);
      end if;
      Dispose (File.all.file_name);
      Dispose (File.all.Uncompressed);
      Dispose (File);
      File := null;
   end Close;

   function Is_Open (File : Zipped_File_Type) return Boolean is
     (File /= null and then File.all.state /= uninitialized);

   function End_Of_File (File : Zipped_File_Type) return Boolean is

   begin
      if File = null or else File.all.state = uninitialized then
         raise Use_Error;
      end if;
      return File.all.state = end_of_zip;
   end End_Of_File;

   procedure Open (File            : in out Zipped_File_Type; -- File - in - archive handle
                   Archive_Info    :        Zip.Zip_info;         -- loaded by Load_zip_info
                   Name            :        String;               -- Name of zipped entry
                   Password        :        String := "";         -- Decryption password
                   Case_sensitive  :        Boolean := False) is

      use Zip_Streams, Ada.Streams;

      MyStream      : aliased File_Zipstream;
      input_stream  : Zipstream_Class;
      use_a_file    : constant Boolean := Zip.Zip_Stream (Archive_Info) = null;

   begin
      if File = null then
         File := new UnZip_Stream_Type;
      elsif File.all.state /= uninitialized then -- forgot to close last time!
         raise Use_Error;
      end if;
      if use_a_file then
         input_stream := MyStream'Unchecked_Access;
         Set_Name (input_stream, Zip.Zip_name (Archive_Info));
         Open (MyStream, Ada.Streams.Stream_IO.In_File);
      else -- use the given stream
         input_stream := Zip.Zip_Stream (Archive_Info);
      end if;
      --
      File.all.archive_info := Archive_Info;
      File.all.file_name := new String'(Name);
      begin
         S_Extract (
                    File.all.archive_info,
                    input_stream,
                    Name,
                    File.all.Uncompressed,
                    Password,
                    Case_sensitive
                   );
         if use_a_file then
            Close (MyStream);
         end if;
      exception
         when others =>
            if use_a_file then
               Close (MyStream);
            end if;
            raise;
      end;
      File.all.index := File.all.Uncompressed'First;
      File.all.state := data_uncompressed;
      -- Bug fix for data of size 0 - 29 - Nov - 2002
      if File.all.Uncompressed'Last < File.all.index then -- (1 .. 0) array
         File.all.state := end_of_zip;
      end if;
      File.all.delete_info_on_closing := False; -- Close won't delete dir tree
      -- Bug fix 1 - Mar - 2007 : False was set only at initialization
   end Open;

   procedure Open (File            : in out Zipped_File_Type; -- File - in - archive handle
                   Archive_Name    :        String;               -- Name of archive file
                   Name            :        String;               -- Name of zipped entry
                   Password        :        String := "";         -- Decryption password
                   Case_sensitive  :        Boolean := False) is

      temp_info : Zip.Zip_info;
      -- this local record (but not the full tree) is copied by Open ( .. )

   begin
      Zip.Load (temp_info, Archive_Name, Case_sensitive);
      Open (File, temp_info, Name, Password, Case_sensitive);
      File.all.delete_info_on_closing := True; -- Close will delete temp. dir tree
   end Open;

   procedure Open (File            : in out Zipped_File_Type; -- File - in - archive handle
                   Archive_Stream  :        Zip_Streams.Zipstream_Class; -- Archive's stream
                   Name            :        String;               -- Name of zipped entry
                   Password        :        String := "";         -- Decryption password
                   Case_sensitive  :        Boolean := False) is

      temp_info : Zip.Zip_info;
      -- this local record (but not the full tree) is copied by Open ( .. )

   begin
      Zip.Load (temp_info, Archive_Stream, Case_sensitive);
      Open (File, temp_info, Name, Password, Case_sensitive);
      File.all.delete_info_on_closing := True; -- Close will delete temp. dir tree
   end Open;

   ------------------------------------------
   -- Read procedure for Unzip_Stream_Type --
   ------------------------------------------

   overriding procedure Read (UnZip_Stream  : in out UnZip_Stream_Type;
                              Item    :    out Ada.Streams.Stream_Element_Array;
                              Last    :    out Ada.Streams.Stream_Element_Offset) is

      use Ada.Streams;

   begin
      if UnZip_Stream.state = uninitialized then
         raise Use_Error;
      end if;
      if UnZip_Stream.state = end_of_zip then
         -- Zero transfer - > Last := Item'First - 1, see RM 13.13.1 (8)
         -- No End_Error here, T'Read will raise it : RM 13.13.2 (37)
         if Item'First > Stream_Element_Offset'First then
            Last := Item'First - 1;
            return;
         else
            -- Well, we cannot return Item'First - 1 .. .
            raise Constraint_Error; -- RM 13.13.1 (11) requires this.
         end if;
      end if;
      if Item'Length = 0 then
         -- Nothing to be read actually.
         Last := Item'Last; -- this is < Item'First
         return;
      end if;
      -- From now on, we can assume Item'Length > 0.

      if UnZip_Stream.index + Item'Length <= UnZip_Stream.Uncompressed'Last then
         -- * Normal case : even after reading, the index will be in the range
         Last := Item'Last;
         Item :=
           UnZip_Stream.Uncompressed.all (UnZip_Stream.index .. UnZip_Stream.index + Item'Length - 1);
         UnZip_Stream.index := UnZip_Stream.index + Item'Length;
         -- Now : Stream.index <= Stream.uncompressed'Last,
         -- then at least one element is left to be read, end_of_zip not possible
      else
         -- * Special case : we exhaust the buffer
         Last := Item'First + (UnZip_Stream.Uncompressed'Last - UnZip_Stream.index);
         Item (Item'First .. Last) :=
           UnZip_Stream.Uncompressed.all (UnZip_Stream.index .. UnZip_Stream.Uncompressed'Last);
         UnZip_Stream.state := end_of_zip;
         -- If Last < Item'Last, the T'Read attribute raises End_Error
         -- because of the incomplete reading.
      end if;
   end Read;

   function Stream (File  : Zipped_File_Type) return Stream_Access is (Stream_Access (File));

   overriding procedure Write (UnZip_Stream : in out UnZip_Stream_Type;
                               Item         :        Ada.Streams.Stream_Element_Array) is

      write_not_supported : exception;

   begin
      raise write_not_supported;
   end Write;

end UnZip.Streams;
