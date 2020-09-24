--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

package body Matrices is

   function "*" (A, B : Matrix) return Matrix is

      AB : Matrix;

   begin
      for Row in Matrix'Range (1) loop
         for Col in Matrix'Range (2) loop
            declare
               Sum : Real := 0.0;
            begin
               for k in Matrix'Range (1) loop
                  Sum := Sum + (A (Row, k) * B (k, Col));
               end loop;
               AB (Row, Col) := Sum;
            end;
         end loop;
      end loop;
      return AB;
   end "*";

   --
   --
   --

   function Transpose (M : Matrix) return Matrix is

      M_T : Matrix;

   begin
      for Row in Matrix'Range (1) loop
         for Col in Matrix'Range (2) loop
            M_T (Row, Col) := M (Col, Row);
         end loop;
      end loop;
      return M_T;
   end Transpose;

   --

end Matrices;
