{$ifdef mswindows}{$apptype console}{$endif}
Program NoisyDelSimple;
// Simple, quick program to remove prefix code at the beginning of a
// program, and remove suffix code from the end of the program
//
//
// Paul Robinson 2021-12-17

{$mode ObjFPC}{$H+}
uses
   windows, SysUtils;

Const
 // We still keep suffixes so we only do those files

    // These are the extensiobns we search
    Extensions: Array[1 .. 5] of String =(
    'pp',
    'pas',
    'inc',
    '',
    ''
    );

   Months: array[1..12] of string[9]=
            ('January',   'February','March',    'April',
              'May',      'June',    'July',     'August',
              'September','October', 'November', 'December');

    Days: Array[0..6] of string[9]=
            ('Sunday','Monday','Tuesday','Wednesday',
            'Thursday','Friday','Saturday');

    path = '*';
    Attr = faAnyFile  ;
    SlashChar = '\';


Var
    IR,
    GlobalFileCount,
    i: integer;

    Infile,
    Outfile: text;

    EndTS,
    TS: SystemTime;
    TimeStamp: String;



    // Converts a file name into directory, name, extension.
    // This removes the dot in the extension. To keep it,
    // remove the // in front of Ext := and insert it in
    // the line after it
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
            else if (Path[i] = SlashChar) and (SlashPos = 0) then
                SlashPos := i;

        if DotPos > 0 then
        begin
            Name := Copy(Path, 1, DotPos - 1);
    //        Ext  := LowerCase(Copy(Path, DotPos, Length(Path) - DotPos + 1));
            Ext  := LowerCase(Copy(Path, DotPos+1, Length(Path) - DotPos + 1));
        end;

        if SlashPos > 0 then
        begin
            Folder := Copy(Path, 1, SlashPos);
            Name   := Copy(Path, SlashPos + 1, Length(Name) - SlashPos);
        end;

    end;

  Function CTS(Const CTime:SystemTime): AnsiString;
begin
   Result := Days[CTime.dayOfWeek]+
             ' '+Months[CTime.month]+
             ' '+IntToStr(CTime.day)+
             ', '+IntToStr(CTime.year)+
             ' '+IntToStr(CTime.Hour)+
             ':';
   if CTime.Minute < 10 then Result := Result+'0';
   Result := Result+ IntToStr(CTime.Minute)+':';
   if CTime.Second < 10 then Result := Result+'0';
   Result := Result+ IntToStr(CTime.Second);
end;

  // Recursively scan directories
  Procedure ScanFiles(
              Const Prefix: UnicodeString);  //< from where are we searching?
  var
     Rslt: TUnicodeSearchRec;    //< since this proc is recursive,
                                 //< this must be local
     FullName,     //< Full name of input file
     Backup,       //< Name of backup file
     Line,         //< A line read from the input file
     TheFilePath,  //< File name split into path
     TheNameOnly,  //< File Name w/o extenion
     TheExtension: UnicodeString; //< File Name extension

     // Determine if a file is a directory
     Function isDirectory: boolean;
     begin
       result := (rslt.Attr And faDirectory) = faDirectory;
     end;

      // try to put file back if there was am error
     procedure putback;
     begin // try to put file back
         close(infile);
         if renameFile(backup,FullName) then // we did
             Writeln('?Error ',IR,' Unable to read file "',
                     FullName,'" file skipped')
         else                   // can't put it back
             Writeln('Unable to restore file "',
                      FullName,'", renamed to ',Backup,
                     '" file skipped');
     end;

  // the real "meat" of this program. Recursively scan all files
  // to find the ones having the extensions we use
  begin // scanfiles

      // Open the directoru and get first file
      // this will probably be . or ..
      If FindFirst(Prefix+Path,Attr,rslt) = 0 Then
      // If there are any files, pick them
      Repeat
          // skip parent directory and self
          If (rslt.Name = '.') Or  (rslt.Name = '..') Then
              continue;

          if isDirectory then     //< don't collect directory
                                  //< but do scan it
                 ScanFiles(prefix+rslt.Name+SlashChar)  //< recursive search
          else    // NOT a directory
          begin   // split the file name into components
             SplitPath(rslt.name,TheFilePath,TheNameOnly,TheExtension);

             // search the array of preferred extensions
             For I := 1 to 5 do
             if Extensions[I]<>'' then   //< vjeck this extension
                 If theExtension = Extensions[I] then  //< found it
                 begin           //< We do want this one
                     FullName := Prefix+rslt.name;   //< Get the original name
                     Backup   := FullName + '.bak';  //< Get the nackup name
                     // rename to Fullname + .bak, e.g pascal.pas.bak
                     if FileExists(Backup) then
                     // erase old backup
                         If not DeleteFile(Backup) then
                         // Error deleting previous backup
                         begin
                              Writeln('Uname to delete backup of "',
                                    FullName,'" file skipped');
                              break;  // exit FOR loop
                         end;
                     // If we can't rename the file to the baxkup
                     // name, that's an error so bail out
                     if not renameFile(FullName,backup) then
                     begin
                        // tell them cam't backup
                        Writeln('Unable to backup file "',
                                FullName,'" file skipped');
                        // bail
                        break;  //< exit FOR loop
                     end;
                     // Open the source for reading
                     Assign(Infile,Backup);
                     FileMode := 0; // open input file read only
                     {$I-} Reset(Infile); {$I+}
                     IR := IOResult;  //< Check if error
                     if IR<>0 then    //< sorry, error
                     begin // try to put it back
                        putback;
                        break;
                     end;
                     // if we are here, start copying
                     Assign(Outfile,Fullname); // name replacement
                     {$I-} Rewrite(Outfile); {$I+}  // create replacement
                     IR := IOResult;
                     if IR<>0 then        // then there's an error
                     begin // try to put it back
                        putback;
                        break;
                     end;
                     // now we can copy the file
                     while not eof(infile) do
                     begin
                         Readln(Infile, Line); // delete the "noisy" lines
                         if Copy(LowerCase(Line),1,7) <>  //< ignore case
                              '{.noisy' then
                             writeln(outfile, Line);
                     end;
                     // it worked, save it
                     Close(OutFile);     // Sve the new file
                     Close(Infile);
                     inc(GlobalFileCount);
                     Write('           ',#13,globalFileCount,#13);
                     break
                 end;  // If TheExtension

          end;
       // get the next file
      Until FindNext(rslt) <> 0;
      FindClose(rslt);
   end;

Procedure Banner;
begin

   Writeln('NoisyDelSimple - Remove compiler flags from Pascal source files');
   Writeln('previously processed by Noisy or NoisyAdd.');
   writeln('Preparing to remove "Noisy" mmarks from all .pas. .pp, and ');
   Writeln('.inc files in this directory and all subdirectories.');
   writeln('Started: ',TimeStamp,', please wait...');



end;

Function Plural(N:Integer; Plu:String; Sng: String): string;
Var
   s:String;
Begin
    S := IntToStr(N);
    S := ' '+S+' ';
    If n<>1 Then
        Result:= S+ Plu
     Else
        Result := S + Sng;
End;



Procedure Elapsed(CONST StartTime,EndTime: SystemTime);
Var
   H,M,S,MS: Integer;
   TimeString: String;

Begin
       // Now tell them how long it took

    H :=  EndTime.Hour;
    if StartTime.Hour < EndTime.Hour  then
        h:=H + 24;
    h := h - StartTime.Hour;
    M := EndTime.Minute ;
    if M < StartTime.minute then
    begin
        H := H-1;
        M := M+60;
    end;
    M := M - StartTime.minute;
    S := EndTime.second  ;
    if S < StartTime.second then
    BEGIN
        M := M-1;
        S := S+60;
    END;
    S := S-StartTime.second;
    MS := EndTime.MilliSecond;
    IF MS < StartTime.MilliSecond then
    begin
        MS := MS+1000;
        S := S-1;
    end;
    MS := MS-StartTime.MilliSecond;

// we won't bother with days,
// nobody is going to process something taking that long

    TimeString := '';   // Make sure it has nothing left over
    If H >0 then
        Timestring := Plural(H,'hours','hour')+' ';
    If M >0 then
        Timestring := TimeString + Plural(M,'minutes','minute')+' ';
    if timestring <> '' then
        Timestring := Timestring +' and ';
    Timestring := TimeString + IntToStr(S)+'.' + IntToStr(MS)+' seconds.';
    Writeln('Elapsed time: ',TimeString)
end;

begin
      TS.Year:=0; EndTS.Month:= 0 ;
      //< silence compiler warning about uninitialized variables
      GetLocalTime(TS);
      TimeStamp := CTS(TS);
      Banner;
      ScanFiles(''); // Start Here


      writeln;
      GetLocalTime(EndTS);
      TimeStamp := CTS(EndTS);
      Writeln('Completed ',TimeStamp);
      writeln('De-processed ',GlobalFileCount,' files.');
      Elapsed(TS,EndTS);

end.
