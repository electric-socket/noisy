// File open code

// this searches for a file in the list of folders
// tries to open, then if successful, reads the entire file
// into memory

procedure InitializeScanner(const Name: TString);
var
  F: TInFile;
  ActualSize: Integer;
  FolderIndex: Integer;

begin
     Buffer.Ptr := nil;

// First search the source folder, then the units folder, then the folders specified in $UNITPATH
     FolderIndex := 1;
     FileMode :=0; // force read-only in case file is read only

repeat
  Assign(F, TGenericString(Folders[FolderIndex] + Name));
  Reset(F, 1);
  if IOResult = 0 then Break;
  Inc(FolderIndex);
until FolderIndex > NumFolders;

FileMode := 1; // set filemode back to write only
if FolderIndex > NumFolders then
   Catastrophic('Fatal: Unable to open source file "' + Name+'".');

with Buffer do
  begin
  FileName := Name;
  Position := 0;
  with Buffer do
    begin
    Size := FileSize(F);
    Pos := 0;

    GetMem(Ptr, Size);

    ActualSize := 0;
    BlockRead(F, Ptr^, Size, ActualSize);
    Close(F);

    if ActualSize <> Size then
       Catastrophic('Fatal: Unable to read source file ' + Name);

    ch  := ' ';
    ch2 := ' ';
    EndOfUnit := FALSE;

  end;
end;
end;


// the master read procedure. The optional
// Peek parameter allows us to look at the
// character we are about to read
procedure ReadChar;
begin
     if ch = #10 then   // End of line found
        Inc(Line);

     ch := #0;
     with Buffer do
      begin
            if Pos < Size then
            begin
                ch := PCharacter(Integer(Ptr) + Pos)^;
                Inc(Pos);
            end
            else
                buffer.EndOfFile := TRUE;
        end;

end;




