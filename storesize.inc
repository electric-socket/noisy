// StoreSize.inc

    procedure storeSize;
    begin
        if sizeTop=nil then
        begin
           new(SizeTop);
           SizeTop^.next := NIL;
           SizeTop^.Size := rslt.size;
           SizeTop^.Count :=1;
           Inc(SizeCount);
           exit;
       end
       else
       begin
           Sizes := SizeTop;
           repeat
               if Sizes^.Size = rslt.size then
               begin
                      Sizes^.Count := Sizes^.Count +1;
                      exit;
                end
               else
               if Sizes^.next = NIL then
                begin
                    New(Sizes^.Next);
                    Sizes := Sizes^.next;
                    Sizes^.Count := 1;
                    Sizes^.Size := rslt.size;
                    Sizes^.Next:= nil;
                    Inc(SizeCount);
                    exit;
                end
             else
                  Sizes := Sizes^.next;
       until Sizes=nil;
     end;
    end;

