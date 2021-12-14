// adds "noise" to, or removes "noise" from, the files
// 2021-12-13 Paul Robinson
// part of the Noisy program

{$I NoisyPrefixCode.inc}
unit N_Static;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, N_Utility;
Var
   P: FilesP;          //< to loop through chain
   FM,                 //< holds FileMode
   NumberDone:Integer; //< Number of files completed


  // add the lines to the programs
  Procedure AddNoise;
  // remove the lines from the programs
  Procedure RemoveNoise;

implementation

Procedure AddNoise;
var
    InFile,
    OutFile,
    FText:   text;
    FFile:  file;
    AlreadyProcessed,
    Fail: boolean;
    Comment: TypeUsed;
    I,
    NumLines:Integer;
    CurrentName,
    NewName: UnicodeString;
    LineBuffer: Array[1..10] of UnicodeString;

begin
    P := FileChain;
    NumberDone := 0;
    while P <> NIL do
    begin
         Fail := False;
         AlreadyProcessed := FALSE;
         Inc(Numberdone);
         Write('Processing #',NumberDone:4,' ',P^.Rpath,P^.name);
//     processing rules
//  *. Loop Cycle
//  *.     open that file
//  *.     if error, report and skip to next
         FM := filemode;
         FileMode := 0; // force read-only in case file is read only
         CurrentName := P^.path;
         if CurrentName<>'' then
             CurrentName := CurrentName+SlashChar;
         CurrentName := CurrentName+P^.Name;
         Assign(FFile,CurrentName);
         {$I-} Reset(FFile); {$I+}
         IR := IOResult;
         if IR<>0 then
         begin
             writeln('Error #',IR,' skipping.');
             Fail := true;
         end
         else
//  *.     if 0 byte file
         if filesize(FFile)=0 then
         begin
//  *.         report empty
             writeln('File empty, skipping');
//  *,         Skip
             Fail := TRUE;
         end;
         if not fail then
         begin
//  *.         close file
              close(FFile);
//  *.     Open as text
              Assign(Ftext,CurrentName);
              Reset(FText);
//  *.     Read the first 5 lines
              For NumLines := 1 to 5 do
              begin
                  if eof(ftext) then break;
                  readln(Ftext,LineBuffer[NumLines]);
              end;
//  *.     close file
              close(FText);
//  *.     see if there is a .bak file present
              NewName :=P^.Path;
              if NewName<>'' then
                  Newname := NewName+'\';
              NewName := NewName+P^.NameOnly+'.bak';
              writeln('** Currentname=',CurrentName,' ',
                      'Newname=',Newname); write(' *? '); readln;
              if fileExists(NewName,FALSE) then
//  *.     if present, delete it
                 if not DeleteFile(newname) then
//  *.     if can't delete,
                 begin
//  *.         report can't remove backup file
                      Writeln('Can''t delete backup, skipping');
//  *.         skip file
                      Fail := true;
                 end;
         end;
         if not fail then
         begin
//  *.     if any of the lines read have the string of
//              Open brace.Noisy  or  paren star.Noisy  or
//              slash slash .noisy then
//  *.         set alreadyprocessed true
              For I:= 1 to NumLines do
                          // check for .noisy with braces
                if pos(Settings.Flag,LineBuffer[I])>0 then
                begin
                    AlreadyProcessed := TRUE;
                    break;
                end;

//  *.     rename file to end with .bak
               If not RenameFile(CurrentName,NewName) then
               begin
//  *.     If rename fails, report it
                   Writeln('Cannot make backup, skipping');
                   Fail := TRUE;
               end;
         end;
         if not fail then
         begin
//  *.     open that file read only
               Assign(InFile,newname);
               {$I-} Reset(Infile); {$I+}
               IR := IOResult;
               if IR<>0 then
               begin
                   Close(InFile);
                   Writeln;
                   Write('?Error ',IR,', problem copying, ');
                   If RenameFile(NewName,CurrentName) then
                       Writeln('skipping file')
                   else       // xan't reset it
                       Writeln('file renamed to ',Newname);
                   Fail := TRUE;
               end;
         end;
         if not fail then
         begin
//  *.     create the original file
                FileMode :=FM;     // reset filemode so files can be written
                Assign(OutFile,CurrentName);
                {$i-} Rewrite(Outfile); {$I+}
                IR := IOResult;
                if IR<>0 then
                begin
                    Close(InFile);
                    Writeln;
                    Write('?Error ',IR,' trying to create output file, ');
                    If RenameFile(NewName,CurrentName) then
                        Writeln('skipping')
                    else
                        Writeln('original renamed to ',Newname);
                    Fail := TRUE;
                end;
//  *.     if not alreadyprocessed
         end;
         if not fail then
         begin
             If not AlreadyProcessed then
//  *.       write the noisy header
                 For I := 1 to 6 do
                    if Settings.FillTop[I]<>'' then
                    begin
                        if Settings.TopType = SlashSlash then
                        // if // marker, put before flag
                            Write(OutFile,Settings.Flag);
                        Write(OutFile,StartComment[Settings.TopType],
                                 Settings.FillTop[I],
                                 EndComment[Settings.TopType]);
                        if Settings.TopType <> SlashSlash then
                        // if not // type, put flag after
                            Write(OutFile,Settings.Flag);
                        Writeln(OutFile);

                end;





//  *.     read 10 lines into block[1..10] or to EOF
//  *.     loop
//  *.        write line[1] of block
//  *.        move lines[2-10] to [1-9]
//  *.        clear [10]
//  *.        if not eof read line[10]
//  *.     end on eof
//  *      write lines 1-8
//  *.     if {.noisy appears on any of lines 5-9
//  *.        if alreadyprocessed
//  *.           report that file has already been processed
//  *.        else
//  *.           report bottom is already marked
//  *.           set bottomprocessed
//  *.  else
//  *.     write noisy footer
//  *.  write line[9]
//  *.  if bottomproccessed
//  *.      report file was previously processed on top.
//  *.      but was processed on bottom
//  *.  close file
             Close(OutFile);
             Close(InFile);
//  *.  clear flags
         END;
         P := P^.next
//  *.  end cycle
    end;
end;

Procedure RemoveNoise;
begin
    P := FileChain;
    NumberDone := 0;
    while P <> NIL do
    begin
         Inc(Numberdone);
         Writeln('Removing from #',NumberDone:4,' ',P^.Rpath,P^.name);






         P := P^.next
    end;

end;

end.

