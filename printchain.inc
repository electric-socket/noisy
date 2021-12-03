// printChain.inc - print the chain of files


     procedure printchain(isPacked:boolean; Show:ShowType = showInvalid);
     Const
         Margin = 78;
     var
        ListCount: Int64;
        D: AnsiString;
        F: UnicodeString;
        p: filesP;
        LineWidth: byte;
        c: char;
     begin
         if filechain = NIL then
           exit;
         P := filechain;
         LineWidth :=0;
         ListCount := 0;

         repeat
             inc(ListCount);
             write('  ',ListCount:5,' ');
             C :=' ';
             D := FormatDateTime( DateFormatChars, P^.Date )+' ';
             if show = showName then
               F :=P^.Name
             else if show=ShowMedium then
               F := P^.rpath + P^.Name
             else if show=ShowFQFN then
               F :=  P^.FQFN
             else
                begin
                    write('Invalid show qualifier');
                    exit;
                end;
             if pos(' ',F)<>0 then  // if any part of the name contains spaces
                C:='"';             // put it in quotes
             if ispacked then
             begin
                 if LineWidth+Length(P^.Name)>margin then
                 begin
                    writeln;
                    LineWidth := 0;
                 end;
             end
             else
                write('    ');
             If ShowDate then write(D);
             write(c, F, c,' ');
             if ispacked then
                 LineWidth := LineWidth+Length(P^.Name)+3
               else
                  writeln;

            P := P^.Next;
          until P = nil;
          if LineWidth>0 then
            writeln;
     end;

