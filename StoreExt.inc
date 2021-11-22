// StoreExt.inc

    procedure storeExt;
    begin
        if ext=nil then
        begin
           new(ext);
           ext^.next := NIL;
           ext^.exten := E;
           ext^.Count :=1;
           Inc(TotalExt);
           exit;
       end
       else
       begin
           extLast := ext;
           repeat
               if extlast^.exten = E then
               begin
                      Extlast^.Count := Extlast^.Count +1;
                      exit;
                end
               else
               if extLast^.next = NIL then
                begin
                    New(ExtLast^.Next);
                    ExtLast := ExtLast^.next;
                    extlast^.Count := 1;
                    ExtLast^.Exten := E;
                    extlast^.Next:= nil;
                    Inc(TotalExt);
                    exit;
                end
             else
                  extlast := extlast^.next;
       until extlast=nil;
     end;
    end;

