with Ada.Numerics.Generic_Elementary_Functions;

package Real_Type is

   subtype Real is Long_Float;

   package Real_Elementary_Functions is
     new Ada.Numerics.Generic_Elementary_Functions (Real);

end Real_Type;
