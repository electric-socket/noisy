// FreeFiles.inc - release the memory requested for the files list

// This demonstratex releasing memory one item at a time, by
// (depending on whether to dispose top down or bottom up)
// one of the following methods
// if going bottom up
//    following filechainlast up along the PREV chain,
//    displosing  of that element, then moving to the
//    prior element.
// if going top down
//    following filechain down along the NEXT chain,
//    displosing  of that element, then moving to the
//    following element.

procedure FreeFilesPrev;
     Var
        P: FilesP;
     begin
        P := FileChain;
        while FileChain<>Nil do
        begin
            FileChain := FileChain^.Prev;
            Dispose(P);
            P := FileChain;
        end;
        FileChain := Nil;
        FileChainLast := NIL;
     end;

procedure FreeFilesNext;
     Var
        P: FilesP;
     begin
        P := FileChainLast;
        while FileChainLast<>Nil do
        begin
            FileChainLast := FileChainLast^.Prev;
            Dispose(P);
            P := FileChainLast;
        end;
        FileChain := Nil;
        FileChainLast := NIL;
     end;

