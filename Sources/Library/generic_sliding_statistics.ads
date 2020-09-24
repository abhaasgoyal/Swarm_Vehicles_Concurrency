--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Real_Type; use Real_Type;

generic

   type Element is private;
   Buffer_Size  : Positive;

package Generic_Sliding_Statistics is

   procedure Add_Reading (New_Reading : Element);

   generic
      with function "+" (Left, Right : Element)        return Element is <>;
      with function "/" (Left : Element; Right : Real) return Element is <>;

   package Averages is
      function Average (New_Reading : Element) return Element;
      function Average                         return Element;
   end Averages;

   --

   generic
      pragma Warnings (Off, "declaration of ""<"" hides predefined operator");
      with function "<" (Left, Right : Element) return Boolean is <>;
      pragma Warnings (On,  "declaration of ""<"" hides predefined operator");

   package MinMax is
      function Min (New_Reading : Element) return Element;
      function Max (New_Reading : Element) return Element;
      function Min                         return Element;
      function Max                         return Element;
   end MinMax;

   No_Elements_in_Stats_Buffer : exception;

end Generic_Sliding_Statistics;
