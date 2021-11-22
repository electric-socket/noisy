// doubleCheck.inc - Checks for duplicate entries


    Procedure DoubleCheck;
    Var
        CP:ExtCountP;
        SP: ExtSortP;
        E: UnicodeString;
        I,J,K:INTEGER;

        Procedure CPCheck;
        Begin
            While CP<> nil do
            begin
                If CP^.Ext = E THEN
                   WRITELN('$$$$ Dup I=',I,' J=',J,' K=',K,' Ext="',E,'"');
                CP := CP^.Next;
                K := K+1;
             end;
         end;

    begin    // DoubleCheck
        SortMoveP := SortBottom;
        CP := SortMoveP^.Groups;
        E :=  CP^.Ext;
        CP := CP^.Next;
        i := 1;
        j := I+1;
        k := 2;

        while SortMoveP <> Nil do
        begin
            CPCheck;
            SP := SortMoveP^.Prev;
            J := I+1; // Check all after I
            While SP <> NIL do
            begin
                CP := SP^.Groups;
                K := 1;
                CPCheck;
                SP := SP^.Prev;
                if SP<>NIL then
                   if SP^.Groups<>NIL then
                      CP := SP^.Groups;;
                J := J+1;
             end;
             SortMoveP := SortMoveP^.Prev;
             If SortMoveP<>NIL then
             begin
                 CP := SortMoveP^.Groups;
                 E :=  CP^.Ext;
                 CP := CP^.Next;
             end;
             I := I+1;
             J := I; // On each loop, J should equal I
             K := 2; // Because we don't want to check
                     // first value against itself
        end;
     end;

