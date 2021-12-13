unit N_perform;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

Type
       ExtP   = ^Extension;
     Extension =   Record
            Prev,
            Next:   ExtP;
            Exten:  unicodeString;
     end ;


Var
    Take,               //< Extensions
    TakeWork: ExtP;

type
    FilesP = ^TheFiles;  //< File Descriptor pointer
    // file descriptor
    TheFiles = Record
        Prev,            //< previous: only used if double-linked list is used
        Next:   FilesP;  //< Next link in chain
        SubDirCount:Integer;  //M subdirectories if this has any
        Attr: Integer;    //< File attributes
        Size: Int64;      //< Size in bytes
        Date: TdateTime;  //< File last write
        Name,             //< file name including extension
        NameOnly,         //< Name w/o extension
        ext,              //< extension in lower case
        Path,             //< directories it's in
        rpath,            //< relative path
        FQFN: UnicodeString; //< full name including directories and drive
    End;
Var
    FileChain,          //< Files
    FileChainLast: FilesP;
    Rslt: TUnicodeSearchRec;
    Attr,
    TotalFileCount,
    GlobalFileCount: Integer;
    MaxSize: Int64;

    // Directories
    CurrentDir,
    OriginalDir,
    Path:   UnicodeString;

    TopLines,
    BottomLines: array[1..6] of  UnicodeString;

const
    SlashChar = '\';
    DateFormatChars = 'yyyy"-"mm"-"dd hh":"nn":"ss';



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
// methosd must be used instead unless both a top pointer,
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

// Converts a file name into direcvtory, name, extension.
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

// does what splitpath does but just gets extension (in lower case)
// the dot before the extension is dicarded
Procedure GetExt(const Path: UnicodeString; var Ext: UnicodeString);
var
    DotPos,  i: Integer;

begin
    DotPos := 0;
    Ext := '';

    for i := Length(Path) downto 1 do
        if (Path[i] = '.') and (DotPos = 0) then
        begin
            DotPos := i;
            break;
        end;
    if DotPos > 0 then
        Ext  :=LowerCase( Copy(Path, DotPos+1, Length(Path) - DotPos + 1));
end;

Procedure ScanFiles(Const Prefix: UnicodeString);    // from where
                                                  //   are we searching?
var
   Rslt: TUnicodeSearchRec;    // since this proc is recursive,
                               // this must be local
   TheFilePath,
   TheNameOnly,
   TheExtension: UnicodeString;

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
           Ext   := TheExtension;
           Attr  := rslt.attr;
           Date  := rslt.TimeStamp;
           Size  := rslt.size;
           rpath := prefix;
           FQFN  := Currentdir + SlashChar  + prefix +  Rslt.Name;

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
           iF P^.rpath<>'' THEN WRITE('\');
           WRITELN(p^.name);
           Inc(I);
           P := P^.Next;
       end;
       writeln;
end;

Procedure Process;
Begin

end;


end.

