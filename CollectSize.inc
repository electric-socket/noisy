// CollectSize.inc  - Inser files by size

      // this routine takes all file sizes and orders them into a list.
      //
      procedure CollectSize(Const prefix: UnicodeString);
      Var

        PriorItem,
        NextItem,
        CP: FilesP;
        Done: boolean;


     // This creates two double-linked lists, that each item points
     // up to next and back to prior

     // While we only use this in order to sort from high to low,
     // it is possible to use it the other way. Set Ascending to false,
     // and use SortBottom instead of SortTop.
     begin
          New(CP);
          with CP^ do
          begin
              Name  := rslt.name;
              Attr  := rslt.attr;
              Date  := rslt.TimeStamp;
              Size  := rslt.size;
              rpath := prefix;
              FQFN  := Currentdir + SlashChar  + prefix +  Rslt.Name;
              prev  := NIL;
              next  := NIL;
              Inc(TotalFileCount);
              if rslt.size >Maxsize then
                  Maxsize := rslt.size;
          END;
       // Sort on numeric values

        if FileChain = NIL then
        begin
            FileChain := CP;    // Nothing else to do
            FileChainLast := CP; // Top and bottom point to same item
            exit;
        end
        else
        if CP^.Size <= FileChain^.Size then
        begin       // It's new lowest item or is same value
            Filechain^.PREV := CP;
            CP^.Next := FileChain;
            Filechain := CP;           // Is now new lower item
            Exit;
        end;
        if FileChain^.Next = NIL then
        begin // This is the new bottom
            FileChain^.Next := CP;
            CP^.prev := FileChain;
            FileChainLast := CP;      // New bottom
        end;

        Done := False;
        // insert one item numerically in list
        // At this point we know filechain has an entry
        // and CP is higher in value
        PriorItem := FileChain;
        NextItem := FileChain^.Next;
        // real simple/ Scan the list until we get an item that's
        // greater than or equal to this one, then we slip it after
        // the prior one and before the next one. If we run out
        // of more items befor we find one lyjay we are less
        // than or equal, it's the new bottom
        repeat // at this point we test to see where to insert this
            if   CP^.Size <= NextItem^.size then
            begin  // it goes before this one, after previous
                      // PRIOR ITEM
                   CP^.Next := PriorItem^.Next;
                   PriorItem^.Next := CP;
                   CP^.Prev := PriorItem;
                   NextItem^.Prev := CP;
                   break;
            end;
            if  Nextitem^.next = NIL  then // This is new bottom
            begin
                   CP^.prev := NextItem;
                   NextItem^.Next := CP;
                   FileChainLast := CP; // New last entry
                   break;
            end;   // follow the chain until you find your place or find
                   // a new place
            PriorItem := NextItem;
            NextItem := NextItem^.Next;
        until done;
     end;


