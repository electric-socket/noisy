// This program proceeds to do what
// is automatically done on most systems,
// read a file in one block at a time,
// a block being whatever chunk of memory
// set aside for this purpose.
program Buffer_Test;
const
     MaxBufSize = 1000;
     Buffercount = 10;
     MAXFOLDERS = 10;

type

     Pcharacter = ^Char;

     TBuffer = record
         InFile,                  // the input
         OutFile: File;           //  and output files
         InName,                  // name of the input
         OutName: UnicodeString;  //  and output files
         inPtr,                   // where we are in the buffer
         OutPtr: PCharacter;      //  for input and output files
         Ch, Ch2,                 // the characters being read
         OutCh: Char;             //  and written
         Line,                    // Line number in input file
         LinePosition: integer;   // poition on line
         Free,                    // is this buffer in use?
         isBlocked,               // was the buffer space smaller than the file?
         EndOfUnit: Boolean;      // we have reached the actual EOF
      // as file size and positioning
      // these might be larger than integer
         InBufSize,               // How much memory we have
         OutBufSuze,
         InSize,                  // size of input file
         OutSize,                 //  and output file
         inPos,                   // current position on in file
         OutPos: Int64;        //  and on out file
     end;

var
    Buffer: Array[1..Buffercount] of TBuffer;    //< Buffers to hold files
    Folders: array [1..MAXFOLDERS] of UnicodeString;   //< Folders to search
                                                       // for files
    NumFolders: integer;                         //< number of folders in use

procedure InitializeScanner(const Name: UnicodeString; Const Bufnum:Integer);
var

  PriorFileMode,          // save its old value
  ActualSize: Int64;   // actual size of file
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
         Assign(InFile, UnicodeString(Folders[FolderIndex] + Name));
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



begin
end.

