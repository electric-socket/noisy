// File open code

// this searches for a file in the list of folders
// tries to open, then if successful, either reads
// the entire file into memory, or reads it in a
// "block" at a time, where "block" is a chunk of
// memory of a reasonable size.`'Rwasonable" being
// relative to the size of programs and the amount
// of menory they are routinely given.

// NOTE: This will only be expected to work if files are smaller
//       than the amount of memory you can acquire. otherwuse you
//       need to use a buffer and blockread the file up to that
//       memory amount, then once exhausted, read another block,
//       until the amount read is smaller than the buffer. it
//       depends on how much memory you can acquire, possibly
//       asllocating 100-500K depending on how hard it is to
//       get memory, then buffer as needed. Or the customary
//       size of most files you deal with.

procedure SplitPath(const Path: UnicodeString; var Folder, Name, Ext: UnicodeString);
var
    DotPos, SlashPos, i: Integer;

begin
    Folder := '';
    Name := Path;
    Ext := '';

    DotPos := 0;
    SlashPos := 0;

    for i := Length(Path) downto 1 do
        if (Path[i] = '.') and (DotPos = 0) then
            DotPos := i
        else if (Path[i] = '\') and (SlashPos = 0) then
            SlashPos := i;

    if DotPos > 0 then
    begin
        Name := Copy(Path, 1, DotPos - 1);
        Ext  := Copy(Path, DotPos, Length(Path) - DotPos + 1);
    end;

    if SlashPos > 0 then
    begin
        Folder := Copy(Path, 1, SlashPos);
        Name   := Copy(Path, SlashPos + 1, Length(Name) - SlashPos);
    end;
end;

procedure InitializeScanner(const Name: TString; Const Bufnum:Integer);
var

  PriorFileMode,          // save its old value
  ActualSize: LargeInt;   // actual size of file
  FolderIndex: Integer;   // Should be more than enough

begin
     Buffer[BufNum].InPtr := nil;    // heen starting, start at zero

// First search the source folder, then the units folder, then the
// folders specified in $UNITPATH

     FolderIndex := 1;
     PriorFileMode := FileMode;
     FileMode := 0; // force read-only in case file is read only

     with Buffer[BufNum] do
     repeat
         Assign(InFile, TGenericString(Folders[FolderIndex] + Name));
         Reset(InFile, 1);
         if IOResult = 0 then Break;
         Inc(FolderIndex);
     until FolderIndex > NumFolders;

     FileMode := PriorFileMode; // set filemode back
     if FolderIndex > NumFolders then
         Catastrophic('Fatal: Unable to find source file "' + Name+'".');

     with Buffer[BufNum] do
     begin
         InName := Name;
         InPos := 0;
         InSize := FileSize(F);
         Free := False;        // buffer not available


         // this has to change to handle buffered files
         // which are too big to inhale completely
         // Either predefine a buffer or allocate one
         // up to a fixed maximum size or filesiaze, whichever
         // is less
         If InSize <= MaxBufSize then
         begin
             isblocked :- FALSE;
             GetMem(InPtr, InSize);
             ActualSize := 0;
             BlockRead(InFile, Ptr^, InSize, ActualSize);
             Close(InFile);
             if ActualSize <> InSize then
             begin // this mi9ght be an error

             end;
         end
         ELSE
         begin
             isblocked :- TRUE;
             GetMem(InPtr, MaxBufSize);
             ActualSize := 0;
             BlockRead(InFile, Ptr^, MaxBufSize, ActualSize);
             if ActualSize <> MaxBufSize then
             begin // this mi9ght be an error
             end;
          end;
         ch  := ' ';
         ch2 := ' ';
         EndOfUnit := FALSE;
     end;  // with buffer
end;


// the master read procedure.
procedure ReadChar( Const Bufnum:Integer);
begin
     with Buffer[BufNum] do
     begin
         if ch2 = #10 then   // End of line found
            Inc(Line);
         ch := Ch2;

         ch2 := #0; // used to indicate "read beyond end of file"
         if (inPos <= InBufSize) and (not EndOfFile) then
         begin
             ch2 := PCharacter(LargeInt(InPtr) + InPos)^;
             Inc(InPos);
         end
         else
            // if we are using buffered reads, then
            // this may simply mean we nead to read
            // the next buffersize bytes in. If it was
            // small enough to fit. this is correct and
            // we are at end of file.
              If not EndofFile then    // if already at end, don't need to reload
              begin
                  EndOfFile :=  IsBlocked;
                  if IsBlockef then
                  begin   // read the next block
                      BlockRead(InFile, Ptr^, MaxBufSize, ActualSize);
                      if ActualSize <> MaxBufSize then
                      begin // This is the last block
                          InBufSize := ActualSize;
                      end;  //lastblock
                      ch2 := PCharacter(ILargeInt(InPtr) + InPos)^;
                      Inc(InPos);
                  end;  // isblocked
               end; // not end of file
     end; // with
end;


  Procedure WriteCh(Const Bufnum:Integer; C:Char);
  begin
     with buffer[BufNum do
     begin
         PCharacter(Integer(outPtr) + outPos)^ := C;
         Inc(outPos);

         // at this point, we need to see if we've reached
         // the block (buffer) size. If we have, we need
         // to flush the buffer to disc, reset the pointer
         // to the start of thr buffer, then continue
         // until finished.


         // This is how to flush the buffer
         with buffer do
         begin
             BlockWrite(F, OutPtr^,BufSize);
             OutPtr := ;
          end;
      end;
  end;

  Procedure WriteString(S:string);
  var
      L: Integer;

  begin
      For L := 1 to Length(S) do
        WriteCh(S[L]);
  end;





