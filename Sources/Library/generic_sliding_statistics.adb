package body Generic_Sliding_Statistics is

   Buffer     : array (1 .. Buffer_Size) of Element;
   Buffer_Ix  : Positive range Buffer'Range     := Buffer'First;
   Fill_Level : Natural  range 0 .. Buffer'Last := 0;

   package body Averages is

      function Average (New_Reading : Element) return Element is

      begin
         Add_Reading (New_Reading);
         return Average;
      end Average;

      --

      function Average return Element is

      begin
         if Fill_Level > 0 then
            declare
               Buffer_Sum : Element := Buffer (Buffer'First);
            begin
               for i in Buffer'First + 1 .. Fill_Level loop
                  Buffer_Sum := Buffer_Sum + Buffer (i);
               end loop;

               return Buffer_Sum / Real (Fill_Level);
            end;
         else
            raise No_Elements_in_Stats_Buffer;
         end if;
      end Average;

   end Averages;

   --

   package body MinMax is

      function Min (New_Reading : Element) return Element is

      begin
         Add_Reading (New_Reading);
         return Min;
      end Min;

      --

      function Max (New_Reading : Element) return Element is

      begin
         Add_Reading (New_Reading);
         return Max;
      end Max;

      --

      function Min return Element is

      begin
         if Fill_Level > 0 then
            declare
               Min_Element : Element := Buffer (Buffer'First);
            begin
               for i in Buffer'First + 1 .. Fill_Level loop
                  if Buffer (i) < Min_Element then
                     Min_Element := Buffer (i);
                  end if;
               end loop;

               return Min_Element;
            end;
         else
            raise No_Elements_in_Stats_Buffer;
         end if;
      end Min;

      --

      function Max return Element is

      begin
         if Fill_Level > 0 then
            declare
               Max_Element : Element := Buffer (Buffer'First);
            begin
               for i in Buffer'First + 1 .. Fill_Level loop
                  if Max_Element < Buffer (i) then
                     Max_Element := Buffer (i);
                  end if;
               end loop;

               return Max_Element;
            end;
         else
            raise No_Elements_in_Stats_Buffer;
         end if;
      end Max;

   end MinMax;

   -----------------
   -- Add_Reading --
   -----------------

   procedure Add_Reading (New_Reading : Element) is

   begin
      Buffer (Buffer_Ix) := New_Reading;

      if Buffer_Ix = Buffer'Last then
         Buffer_Ix := Buffer'First;
      else
         Buffer_Ix := Buffer_Ix + 1;
      end if;

      Fill_Level := Natural'Min (Fill_Level + 1, Buffer'Last);
   end Add_Reading;

end Generic_Sliding_Statistics;
