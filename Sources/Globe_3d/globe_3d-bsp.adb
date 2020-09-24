pragma Warnings (Off);
pragma Style_Checks (Off);

with Ada.Unchecked_Deallocation;

with GLOBE_3D.Math;

package body GLOBE_3D.BSP is

  use Ada.Strings.Unbounded;

  procedure Locate (P : Point_3D; tree : p_BSP_node; area : out p_Object_3D) is

    procedure Locate_point (tree_point : p_BSP_node) is
      -- ^ internal, for skipping useless parameter passing
      use Math, GL;
    begin
      info_b_str1 := info_b_str1 & " - > " & Integer'Image (tree_point.node_id);
      info_b_ntl1 := info_b_ntl1 + 1;
      if P * tree_point.normal + tree_point.distance > 0.0 then -- in front
        if tree_point.front_child = null then
          area := tree_point.front_leaf;
        else
          Locate_point (tree_point.front_child);
        end if;
      else -- in back
        if tree_point.back_child = null then
          area := tree_point.back_leaf;
        else
          Locate_point (tree_point.back_child);
        end if;
      end if;
    end Locate_point;

  begin
    info_b_str1 := Null_Unbounded_String;
    info_b_ntl1 := 0; -- depth counter
    area := null;
    if tree /= null then
      Locate_point (tree);
    end if;
    info_b_bool1 := area /= null;
  end Locate;

  procedure Delete (tree : in out p_BSP_node) is
    procedure Dispose is new Ada.Unchecked_Deallocation (BSP_node, p_BSP_node);
  begin
    if tree/=null then
      Delete (tree.front_child);
      Delete (tree.back_child);
      Dispose (tree);
      tree := null;
    end if;
  end Delete;

end GLOBE_3D.BSP;
