// printChain.inc - print the chain of files


     procedure printchain(isPacked:boolean; Show:ShowType = showInvalid);
     Const
         Margin = 78;
         Spaces = '          '; // 10 Chars
     var

        D: AnsiString;
        F: UnicodeString;
        p: filesP;
        LineWidth: byte;
        c: char;
        ListCount: Int64;
     begin
         if filechain = NIL then
           exit;
         P := filechain;
         if SizeDown then
            P := filechainlast;
         LineWidth :=0;
         Listcount :=0;

         repeat
             inc(ListCount);
             write('  ',ListCount:5,' ');
             C :=' ';
             D := '';
             If ShowDate Then
                 D := FormatDateTime( DateFormatChars, P^.Date )+' ';
             If SizeOnly Then
                Begin
                    D := Comma(P^.Size);
                    D := LeftStr(Spaces, 10-Length(D))+D+' ';
                end;
             if show = showName then
               F :=P^.Name
             else if show=ShowMedium then
               F := P^.rpath + P^.Name
             else if show=ShowFQFN then
               F :=  P^.FQFN
             else
                begin
                    writeln('Invalid show qualifier');
                    exit;
                end;
             if pos(' ',F)<>0 then  // if any part of the name contains spaces
                C:='"';             // put it in quotes
             if ispacked then
             begin             // squeeze as many entries as possible
                 if LineWidth+Length(P^.Name)>margin then
                 begin
                    writeln;
                    LineWidth := 0;
                 end;
             end
             else
                write('    ');
             If ShowDate or SizeOnly then write(D);
             write(c, F, c,' ');
             if ispacked then
                 LineWidth := LineWidth+Length(P^.Name)+3
               else
                  writeln;
            if SizeDown then
                P := P^.Prev
            else
                P := P^.Next;
          until P = nil;
          if LineWidth>0 then
            writeln;
     end;

