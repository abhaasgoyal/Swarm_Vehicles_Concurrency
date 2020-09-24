--
-- Jan & Uwe R. Zimmer, Australia, July 2011
--

package body Graphics_FrameRates is

   type Ring_Ix is mod Smoothing_Buffer_Size;

   Smoothing_Buffer    : array (Ring_Ix) of Time_Span := (others => Seconds (1));
   Smoothing_Buffer_Ix : Ring_Ix := Ring_Ix'First;

   Last_Call_To_Limiter          : Time := Clock;
   Last_Padding_Delay            : Time_Span := Time_Span_Zero;
   Last_Call_To_Measure_Interval : Time := Clock;

   --
   --
   --

   function Measure_Interval return Time_Span is

      Interval : constant Time_Span := Clock - Last_Call_To_Measure_Interval;

   begin
      Last_Call_To_Measure_Interval := Clock;
      return Interval;
   end Measure_Interval;

   -----------------------
   -- Average_Framerate --
   -----------------------

   function Average_Framerate (Interval : Time_Span) return Hz is

      Interval_Sum : Time_Span := Time_Span_Zero;

   begin
      Smoothing_Buffer (Smoothing_Buffer_Ix) := Interval;
      Smoothing_Buffer_Ix := Smoothing_Buffer_Ix + 1;

      for i in Ring_Ix'Range loop
         Interval_Sum := Interval_Sum + Smoothing_Buffer (i);
      end loop;

      if Interval_Sum = Time_Span_Zero then
         return 0.0;
      else
         return 1.0 / Real (To_Duration (Interval_Sum / Smoothing_Buffer_Size));
      end if;
   end Average_Framerate;

   --
   --
   --

   procedure Framerate_Limiter (Max_Framerate : Hz) is

      Intended_Time_Span    : constant Time_Span := To_Time_Span (Duration (1.0 / Max_Framerate));
      Actual_Execution_Time : constant Time_Span := (Clock - Last_Call_To_Limiter) - Last_Padding_Delay;
      Padding_Delay         :          Time_Span := Intended_Time_Span - Actual_Execution_Time;

   begin
      if Padding_Delay > Intended_Time_Span then
         Padding_Delay := Intended_Time_Span;
      elsif Padding_Delay < -Intended_Time_Span then
         Padding_Delay := -Intended_Time_Span;
      end if;

      Last_Call_To_Limiter := Clock;
      Last_Padding_Delay   := Padding_Delay;
      delay To_Duration (Padding_Delay);
   end Framerate_Limiter;

end Graphics_FrameRates;
