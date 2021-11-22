// SortExt.inc


      procedure sortExt;
      Var
       CP: ExtCountP;
        PriorItem,
        NextItem,
        SP: ExtSortP;
        Done: boolean;

     begin
        ExtLast := Ext;
        SortTop := NIL;
        // Sort on numeric values
        repeat            // insert all items
            Done := False;
            repeat             // insert one item numerically in list
            If SortTop = NIL then
            begin
                New(SortTop);
                New(CP);
                SortTop^.Prev := NIl;
                SortTop^.Next := NIL;
                SortBottom := SortTop;
                CP^.Ext := ExtLast^.Exten;
                SortTop^.Groups := CP;
                SortTop^.GroupCount :=1;
                CP^.Next := Nil;
                SortTop^.Count := ExtLast^.Count;
                SortTop^.Groups := CP ;
                SortTop^.GroupCount :=1;
                done := True;
                break;
            end;
            If   ExtLast^.Count < SortTop^.Count then // before beginning
            begin
                New(SP);
                New(CP);
                SP^.Prev := NIL;
                SP^.Next := SortTop;
                SortTop^.Prev := SP;
                SortTop := SP;
                SortTop^.Groups := CP;
                SortTop^.GroupCount :=1;
                CP^.Ext := ExtLast^.Exten;
                CP^.Next := Nil;
                SortTop^.Count := ExtLast^.Count;
                SortTop^.Groups := CP ;
                SortTop^.GroupCount :=1;
                done := True;
                break;
            end;
            if   ExtLast^.Count  = SortTop^.Count then
            begin
                CP := SortTop^.Groups  ;
                Inc( SortTop^.GroupCount);
                while CP^.Next <> NIL do
                    CP := CP^.Next;
                New(CP^.Next);
                CP := CP^.Next;
                CP^.Ext := ExtLast^.Exten;
                CP^.Next := NIL;
                done := True;
                break;
            end;
            PriorItem := SortTop;
            NextItem := SortTop^.Next;
            repeat // at this point the prior
                   // item was less than ExtLast^.Count, so let's see
                   // if this one is, is equal, or is more
                if NextItem = NIL then   // after last
                begin
                    New(SP);
                    New(CP);
                    SP^.Next := NIL;
                    SP^.Prev := PriorItem;
                    PriorItem^.Next := SP;
                    SortBottom := SP;
                    SP^.Groups := CP;
                    SP^.GroupCount := 1;
                    CP^.Ext := ExtLast^.Exten;
                    CP^.Next := Nil;
                    SP^.Count := ExtLast^.Count;
                    SP^.Groups := CP ;
                    SP^.GroupCount := 1;
                    done :=true;
                    break;                                break;
               end;
               if   ExtLast^.Count < NextItem^.Count then
               begin  // it goes before this one, after previous
                   New(SP);
                   New(CP);
                   PriorItem^.Next := SP;
                   SP^.Next := NextItem;
                   NextItem^.Prev := SP;
                   SP^.Prev := PriorItem;
                   SP^.Groups := CP;
                   CP^.Ext := ExtLast^.Exten;
                   CP^.Next := Nil;
                   SP^.Count := ExtLast^.Count;
                   SP^.Groups := CP ;
                   SP^.GroupCount := 1;
                   done := True;
                   break;
               end;
               if   ExtLast^.Count  = Nextitem^.Count then
               begin
                   CP := NextItem^.Groups;
                   inc( NextItem^.GroupCount );
                   while CP^.Next <> NIL do
                       CP := CP^.Next;
                   New(CP^.Next);
                   CP := CP^.Next;
                   CP^.Ext := ExtLast^.Exten;
                   CP^.Next := NIL;
                   done := True;
                   break;
               end;
               PriorItem := NextItem;
               NextItem := NextItem^.Next;
            until  done;
          until done;
          ExtLast := ExtLast^.Next;
        until ExtLast = NIL;
     end;


