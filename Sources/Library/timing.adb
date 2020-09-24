--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

package body Timing is

   Time_Keeper :  Time := Clock;

   function Timer return Time_Span is

      Timed : constant Time_Span := Clock - Time_Keeper;

   begin
      Time_Keeper := Time_Keeper + Timed;
      return Timed;
   end Timer;

end Timing;
