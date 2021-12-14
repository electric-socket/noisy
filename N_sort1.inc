// SortExt.inc  - Sort the extensions by popularity

      // this routine takes all extensions and sorts them into a list.
      // e
      procedure sortExt;
      Var
       CP: ExtCountP;
        PriorItem,
        NextItem,
        SP: ExtSortP;
        Done: boolean;


     // This creates two double-linked lists, that each item points
     // up to next and back to prior, the other link counts duplicates

     // While we only use this in order to sort from high to low,
     // it is possible to use it the other way. Set Ascending to false,
     // and use SortBottom instead of SortTop.
     begin
        ExtLast := Ext;
        SortTop := NIL;
        // Sort on numeric values
        repeat            // insert all items
            Done := False;

// ATTENTION PLEASE. MAY i HAVE YOUR ATTENTION!
// Yes, I know there is a lot of redundant code
// in this section, and the initialization of the
// records should be done by a captive procedure,
// instead of doing the same thing about five times,
// BUT, two things, I wrote it in less than 3 hours,
// and second, it works. Hey, if you don't like it, feel
// free to simplify this procedure. Besides, this is
// more of a demo than a usual polished, professional
// program for non-programmers. Would need some work
// and cleaning, but even if not updated, it might be useful.


            repeat             // insert one item numerically in list
            If SortTop = NIL then    // BLOCK "FIRST"
            begin // If the list is empty, inset it abd we're done!
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
            If   ExtLast^.Count < SortTop^.Count then  // BLOCK "BEGINNING"
            begin      // if it's less than the lowedt item, then
                       // insert it above the top, then move the top up by one
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
            if   ExtLast^.Count  = SortTop^.Count then   // BLOCK "EQUAL"
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
            // SECOND LOOP
            repeat // at this point the prior
                   // item was less than ExtLast^.Count, so let's see
                   // if this one is, is equal, or is more
                if NextItem = NIL then   // after last
                begin           // NO NEXT ITEM
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
                    break;
               end;
               if   ExtLast^.Count < NextItem^.Count then
               begin  // it goes before this one, after previous
                   // PRIOR ITEM
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
               begin     // FOUND ITEM
                   CP := NextItem^.Groups;
                   inc( NextItem^.GroupCount );
                   while CP^.Next <> NIL do      // Put it in groups with this many
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

      // Since this confused me, I'll explain why there are two
      // repeat statements in a row that both exit when done
      // is true.
      // This double loop insets one item in a ;inked list.
      // Within the outer block, we process this item., then done
      // How we do that is this:
      // First IF block FIRST inserts the very first item, then done
      // The second IF block BEFORE inserts if this isw less than the
      //    first item, it necomes the new first item, then done
      // The third IF block EQUAL incresdes the count of the top item
      // if any of these happen, it exits the outer repeat
      // At thiss point we know the item is higher than the top item.
      // we now make the top item the prior one and the next item
      // the top., then do something similar.
      // Start SECOND loop
      // If there is NO NEXT ITEM, create one, vhain the prior item's
      // next ti this one, move the data and we're done
      // If it is the PRIOR ITEM, i.e. it is greater than the one we
      // looked at before, but less than this one, break the chain,
      // insert this item i9nto the prior item's next item, insert this
      // into the next item's prior item, make our prior item the
      // prior item, make ours the prior to the current one, we're done.
      // if this is a FOUND ITEM, increase its usage count by 1, we're done
      // Now, it's higher than this item, so now, we make this item the
      // last one, it's next the current one, then go back to SECOND loop.
      // eventually we'll either be behind the current item, equal to the
      // current item,, or higher than the current but there iws no higher
      // item, so we become the new highest item, and we're done.
      // after that the outer repeat has us do this for thenext item, u
      // nntil they are all sorted.

            until  done;
          until done;
          ExtLast := ExtLast^.Next;
        until ExtLast = NIL;
     end;


