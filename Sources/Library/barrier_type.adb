package body Barrier_Type is

   -------------
   -- Barrier --
   -------------

   protected body Barrier is

      ----------
      -- Wait --
      ----------

      entry Wait when Opened is

      begin
         Opened := Wait'Count > 0;
      end Wait;

      ----------
      -- Open --
      ----------

      procedure Open is

      begin
        Opened := True;
      end Open;

      -----------
      -- Close --
      -----------

      procedure Close is

      begin
        Opened := False;
      end Close;

   end Barrier;

end Barrier_Type;
