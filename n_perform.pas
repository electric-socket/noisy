// Performs the processing of the files
// 2021-12-13 Paul Robinson
// part of the Noisy program
{$I NoisyPrefixCode.inc}
unit N_perform;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, N_Utility, N_Static;



Procedure Init;
Procedure ScanFiles(Const Prefix: UnicodeString);
Procedure VerifyRequest;
Procedure Process;
Procedure AddExt(Const TheExtension:UnicodeString);
Function FindExt(Const TheExtension:UnicodeString): Boolean;

implementation

// This inserts an extension into the lisr.
// Note: once take is initialized, takework would always
// point to the last entry in the list. I'm doing it this
// way for didactic i.e. educational, purposes. However, if
// the list has both added to and and searches then this
// method *must* be used instead unless both a top pointer,
// bottom pointer, and a work pointer are used
Procedure AddExt(Const TheExtension:UnicodeString);
begin
   If take = nil then
   begin         // table is empty
       New(Take);
       Takework := Take;
   end
   else
   begin   // find bottom of table
       Takework := Take;
       while takework^.Next <> nil do
          Takework := TakeWork^.next;
       New(TakeWork^.next);
       Takework := Takework^.Next;
   end;    // insert new item
   TakeWork^.Next := Nil;
   Takework^.Exten := TheExtension;
end;

Function FindExt(Const TheExtension:UnicodeString): Boolean;
begin
    Result := FALSE;
    If take=Nil then exit;
    TakeWork := take;
    While takework<>Nil do
    If takework^.Exten = TheExtension then
        begin
            Result := True;
            Exit;
        end
    else
        TakeWork := TakeWork^.next;
end;

Procedure Init;
Begin
     AddExt('pp');
     AddExt('pas');
     AddExt('inc');
     Attr := faAnyFile  ;
     path := '*';

end;




// Recursively scan directories
Procedure ScanFiles(
            Const Prefix: UnicodeString);  //< from where are we searching?
var
   Rslt: TUnicodeSearchRec;    //< since this proc is recursive,
                               //< this must be local
   TheFilePath: UnicodeString = '';  //< File name spliot into path
   TheNameOnly: UnicodeString = '';  //< File Name w/o extenion
   TheExtension: UnicodeString = ''; //< File Name extension

   Function isDirectory: boolean;
   begin
     result := (rslt.Attr And faDirectory) = faDirectory;
   end;

   Procedure GetFileItem;
   begin
       If filechain = nil then  // first time
       begin
           new(FileChain);
           FileChain^.prev := nil;
           FileChain^.next := nil;
           FileChainLast := FileChain;
       end
       else
       begin
           New(FileChainLast^.next);
           FileChainLast^.next^.prev := FileChainLast;
           FileChainLast := FileChainLast^.next;
           FileChainLast^.Next := Nil;
       end;
   end; // GetFileItem

   // unsorted collection - simple one-way (downward)
   // linked list
   procedure CollectFile(Const prefix:  UnicodeString);
   BEGIN
        if isDirectory then exit; // we don't save directoies
       GetFileItem;
       with FileChainLast^ do
       begin
           Name  := rslt.name;
           NameOnly := TheNameOnly;
           Writeln('** Mame=',name,' NameOnly=',NameOnly);
           Ext   := TheExtension;
           Attr  := rslt.attr;
           Date  := rslt.TimeStamp;
           Size  := rslt.size;
           rpath := prefix;

           FQFN  := Currentdir;
           If LeftStr(String(Currentdir),1)<>SlashChar then
               FQFN  := FQFN + SlashChar;
           FQFN  := FQFN + prefix +  Rslt.Name;

// Only use these if counting sizes
           if rslt.size >Maxsize then
              Maxsize := rslt.size;
       end;
   end;

begin
       WRITE(GLOBALFILECOUNT:7,#8#8#8#8#8#8#8#8#8);

    If FindFirst(Prefix+Path,Attr,rslt) = 0 Then
    Repeat
        If (rslt.Name = '.') Or  (rslt.Name = '..') Then
            continue;  // skip parent and self

        if isDirectory then     // don't collect directory
                                // but do scan it
               ScanFiles(prefix+rslt.Name+SlashChar)  // recursive search
        else    // NOT a directory
        begin
           Inc(TotalFileCount);
           SplitPath(rslt.name,TheFilePath,TheNameOnly,TheExtension);

        // Write('Name=',rslt.Name,' Ext=',TheExtension);
           If Not FindExt(theExtension) then
           begin
           //   writeln(' -- no');
           continue ; // don't want this one
           end;

        // We do want this one
           // writeln(' YES');
            CollectFile(Prefix);
            inc(GlobalFileCount);
        end;

    Until FindNext(rslt) <> 0;
    FindClose(rslt);
 end;


Procedure VerifyRequest;
VAR
    I:INTEGER;
    Answer: UnicodeString;
    P: FilesP;
Begin
       WRITELN;
       Writeln('Toral files found: ',TotalFileCount,' Selected: ',GlobalFileCount);
       writeln;
       WRITELN('** VERIFY **');
       writeln;
       I := 1;
       P := Filechain;
       while P<>NIL do
       begin
           Write(I:4,'. ',P^.rpath);
           WRITELN(p^.name);
           Inc(I);
           P := P^.Next;
       end;
       writeln;
       writeln('Are these the files you want to change?');
       repeat
          Writeln('(a) Add lines to files not marked by Noisy');
          Writeln('(d) Delete Noisy lines from files previously marked');
          writeln('(q) Quit without doing anything');
          write('Enter A,D, or Q: ');
          Readln(Answer);
          Answer := UpperCase(Trim(Answer));
       until (answer[1] in ['A','D','Q']);

       if Answer[1]<>'Q' then
       begin
          IF answer[1]='A' then
              AddNoise
          else
              RemoveNoise;
          writeln('Completed.');
          exit;
       end;

       Writeln;
       Writeln('***** Cancelled.');
end;

Procedure Process;
Begin

end;


end.

