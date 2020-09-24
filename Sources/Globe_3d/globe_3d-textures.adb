with GL, GL.IO, UnZip.Streams;

with Ada.Characters.Handling;           use Ada.Characters.Handling;
with Ada.Exceptions;                    use Ada.Exceptions;
with Ada.Strings.Fixed;                 use Ada.Strings, Ada.Strings.Fixed;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;
with Ada.Containers.Hashed_Maps;
with Ada.Strings.Unbounded.Hash;

package body GLOBE_3D.Textures is

  ------------------------------------------------------------------
  -- 1) Fast access though the number (Image_ID - > Texture_info) : --
  ------------------------------------------------------------------
  type Texture_info is record
    loaded        : Boolean := False;
    blending_hint : Boolean := False;
    name          : Ident := empty;
  end record;

  type Texture_info_array is array (Image_ID range <>) of Texture_info;
  type p_Texture_info_array is access Texture_info_array;

  procedure Dispose is new Ada.Unchecked_Deallocation (Texture_info_array, p_Texture_info_array);

  -----------------------------------
  -- 2) Fast access through a name --
  -----------------------------------

  package Texture_Name_Mapping is new Ada.Containers.Hashed_Maps
     (Key_Type        => Ada.Strings.Unbounded.Unbounded_String,
      Element_Type    => Image_ID,
      Hash            => Ada.Strings.Unbounded.Hash,
      Equivalent_Keys => Ada.Strings.Unbounded."=");

  type Texture_2d_infos_type is record
    tex               : p_Texture_info_array;
    map               : Texture_Name_Mapping.Map;
    last_entry_in_use : Image_ID;
  end record;

  empty_texture_2d_infos : constant Texture_2d_infos_type :=
    (null,
      Texture_Name_Mapping.Empty_Map,
      null_image
);

  Texture_2d_Infos : Texture_2d_infos_type := empty_texture_2d_infos;

  -----------------------------
  -- Load_texture (internal) --
  -----------------------------

  procedure Load_texture_2D (id : Image_ID; blending_hint : out Boolean) is
    tex_name : constant String := Trim (Texture_2d_Infos.tex.all (id).name, Right);

    procedure Try (zif : in out Zip.Zip_info; name : String) is
      use UnZip.Streams;
      ftex : Zipped_File_Type;
      procedure Try_a_type (tex_name_ext : String; format : GL.IO.Supported_format) is
      begin
        Open (ftex, zif, tex_name_ext);
        GL.IO.Load (Stream (ftex), format, Image_ID'Pos (id) + 1, blending_hint);
        Close (ftex);
      exception
        when Zip.File_name_not_found =>
          raise;
        when e : others =>
          Raise_Exception (
            Exception_Identity (e),
            Exception_Message (e) & " on texture : " & tex_name_ext);
      end Try_a_type;
    begin -- Try
      Load_if_needed (zif, name);
      Try_a_type (tex_name & ".TGA", GL.IO.TGA);
    exception
      when Zip.File_name_not_found =>
        Try_a_type (tex_name & ".BMP", GL.IO.BMP);
    end Try;
  begin
    begin
      Try (zif_level, To_String (level_data_name));
    exception
      when Zip.File_name_not_found |
           Zip.Zip_file_open_Error =>
        -- Not found in level - specific pack
        Try (zif_global, To_String (global_data_name));
    end;
  exception
    when Zip.File_name_not_found |
         Zip.Zip_file_open_Error =>
      -- Never found - neither in level, nor in global pack
      Raise_Exception (Missing_texture'Identity, "texture : " & tex_name);
  end Load_texture_2D;

  function Valid_texture_ID (id : Image_ID) return Boolean is
  begin
    return id in null_image + 1 .. Texture_2d_Infos.last_entry_in_use;
  end Valid_texture_ID;

  procedure Check_2D_texture (id : Image_ID; blending_hint : out Boolean) is
  begin
    if not Valid_texture_ID (id) then
      raise Undefined_texture_ID;
    end if;
    if Texture_2d_Infos.tex.all (id).loaded then
      blending_hint := Texture_2d_Infos.tex.all (id).blending_hint;
    else
      Load_texture_2D (id, blending_hint);
      Texture_2d_Infos.tex.all (id).loaded := True;
      Texture_2d_Infos.tex.all (id).blending_hint := blending_hint;
    end if;
  end Check_2D_texture;

  procedure Check_2D_texture (id : Image_ID) is
    junk_blending_hint : Boolean; pragma Unreferenced (junk_blending_hint);
  begin
    Check_2D_texture (id, junk_blending_hint);
  end Check_2D_texture;

  procedure Check_all_textures is
  begin
    for i in null_image + 1 .. Texture_2d_Infos.last_entry_in_use loop
      Check_2D_texture (i);
    end loop;
  end Check_all_textures;

  procedure Reset_textures is
  begin
    if Texture_2d_Infos.tex /= null then
      Dispose (Texture_2d_Infos.tex);
    end if;
    Texture_2d_Infos := empty_texture_2d_infos;
  end Reset_textures;

  procedure Add_texture_name (name : String; id : out Image_ID) is
    new_tab : p_Texture_info_array;
    up_name : constant String := To_Upper (name);
    -- Convention : UPPER_CASE for identifiers
    n_id : Ident := empty;
    pos : Texture_Name_Mapping.Cursor;
    success : Boolean;
  begin
    if Texture_2d_Infos.tex = null then
      Texture_2d_Infos.tex := new Texture_info_array (0 .. 100);
    end if;
    if Texture_2d_Infos.last_entry_in_use >= Texture_2d_Infos.tex'Last then
      -- We need to enlarge the table : we double it .. .
      new_tab := new Texture_info_array (0 .. Texture_2d_Infos.tex'Last * 2);
      new_tab.all (Texture_2d_Infos.tex'Range) := Texture_2d_Infos.tex.all;
      Dispose (Texture_2d_Infos.tex);
      Texture_2d_Infos.tex := new_tab;
    end if;
    id := Texture_2d_Infos.last_entry_in_use + 1;
    for i in up_name'Range loop
      n_id (n_id'First + i - up_name'First) := up_name (i);
    end loop;
    Texture_2d_Infos.tex.all (id).name := n_id;
    Texture_2d_Infos.last_entry_in_use :=
      Image_ID'Max (Texture_2d_Infos.last_entry_in_use, id);
    -- Feed the name dictionary with the new name:
    Texture_Name_Mapping.Insert (
      Texture_2d_Infos.map,
      Ada.Strings.Unbounded.To_Unbounded_String (up_name),
      id,
      pos,
      success
);
    if not success then -- A.18.4. 45/2
      raise Duplicate_name with name & ", already stored as " & up_name;
    end if;
  end Add_texture_name;

  procedure Register_textures_from_resources is

    procedure Register (zif : in out Zip.Zip_info; name : String) is
      --
      procedure Action (Name_String : String) is
        dummy : Image_ID;
        ext : constant String := To_Upper (Name_String (Name_String'Last - 3 .. Name_String'Last));
      begin
        if ext = ".BMP" or else ext = ".TGA" then
          Add_texture_name (Name_String (Name_String'First .. Name_String'Last - 4), dummy);
        end if;
      end Action;
      --
      procedure Traverse is new Zip.Traverse (Action);
    begin
      Load_if_needed (zif, name);
      Traverse (zif);
      -- That's it!
    exception
      when Zip.Zip_file_open_Error =>
        null;
    end Register;

  begin
    Register (zif_level,  To_String (level_data_name));
    Register (zif_global, To_String (global_data_name));
  end Register_textures_from_resources;

  procedure Associate_textures is
    dummy : Image_ID;
  begin
    Reset_textures;
    for t in Texture_enum loop
      Add_texture_name (Texture_enum'Image (t), dummy);
    end loop;
  end Associate_textures;

  function Texture_name (id : Image_ID; Trim_Flag : Boolean) return Ident is
    tn : Ident;
  begin
    if not Valid_texture_ID (id) then
      raise Undefined_texture_ID;
    end if;
    tn := Texture_2d_Infos.tex.all (id).name;
    if Trim_Flag then
      return Ada.Strings.Fixed.Trim (tn, Right);
    else
      return tn;
    end if;
  end Texture_name;

  function Texture_ID (name : String) return Image_ID is
    trimmed : constant String := Trim (name, Both);
    up_name : constant String := To_Upper (trimmed);
  begin
    return Texture_Name_Mapping.Element (
            Texture_2d_Infos.map,
            Ada.Strings.Unbounded.To_Unbounded_String (up_name));
  exception
    when Constraint_Error =>
      raise Undefined_texture_name with
        "Texture : " & trimmed & ", searched as " & up_name & "." &
        ASCII.CR & ASCII.LF &
        "Check data files:" &
        ASCII.CR & ASCII.LF &
        ' ' & To_String (global_data_name) &
        ASCII.CR & ASCII.LF &
        ' ' & To_String (level_data_name) & '.' &
        ASCII.CR & ASCII.LF &
        "Check calls of Add_texture_name or Associate_textures.";
  end Texture_ID;

end GLOBE_3D.Textures;
