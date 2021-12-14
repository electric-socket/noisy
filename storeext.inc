// N_StoreExt.inc   -- store rxtensiom in list
// written by Paul Robinson

    procedure storeExt;    // Extension to store is in E
    begin
        if ext=nil then
        begin           // brand new list
           new(ext);
           ext^.next := NIL;
           ext^.exten := E;
           Inc(TotalExt);
           exit;
       end
       else
       begin
           extLast := ext;
           repeat
               if extLast^.next = NIL then
                begin
                    New(ExtLast^.Next);
                    ExtLast := ExtLast^.next;
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

