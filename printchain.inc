// printChain.inc - print the chain of files


     procedure printchain(isPacked:boolean; Show:ShowType = showInvalid);
     Const
         Margin = 78;
     var
        F: UnicodeString;
        p: filesP;
        N: byte;
        c: char;
     begin
         if filechain = NIL then
           exit;
         P := filechain;
         N :=0;
         repeat
             write('  ');
             C :=' ';
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
                 if N+Length(P^.Name)>margin then
                 begin
                    writeln;
                    n := 0;
                 end;
             end
             else
                write('    ');;
             write(c, F, c,' ');
             if ispacked then
                 N := N+Length(P^.Name)+3
               else
                  writeln;

            P := P^.Next;
          until P = nil;
          if n>0 then
            writeln;
     end;

