--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

with Ada.Real_Time; use Ada.Real_Time;
with Real_Type;    use Real_Type;

package Graphics_FrameRates is

   Smoothing_Buffer_Size : constant Positive := 24;

   subtype Hz is Real range 0.0 .. Real'Last;

   function Measure_Interval return Time_Span;

   function Average_Framerate (Interval : Time_Span) return Hz;

   procedure Framerate_Limiter (Max_Framerate : Hz);

end Graphics_FrameRates;
