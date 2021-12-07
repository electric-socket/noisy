// scansort.inc

{ The following code is used by both
  SortExtnsions (which sets the **Extensions**
                 compile-time define) and by 
  Scanfiles     (which sets the **Files** 
                compile-time define)

 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License,  version 2,     *
 *   as published by the Free Software Foundation.                         *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.   *
 *                                                                         *
 ***************************************************************************

  Author: Paul Robinson

  Comments:
    2021-12-03 This code does two things, First, it scans a directory
               and all subdirectories for files.

               Now, depending on which program invoked it, it
               will do one of two things:
               For Scanfiles, it thenn counts and displays all files
                   thjat it fou7nd.
               For SortExtensions, it sorts, by usage, all extensions
                   that it finds, then counts how many it found, in order
                   from most popular to least popular, then if more than
                   one extension has that many uses, it lists all the
                   extesions that do.

    2021-11-21:  I set both programs aside for so long I've
    forgotten exactly what it does...

    Was not using source code control (my bad), probably not
    a good idea, but I didn't think - an unfortunatley all 
    too common practice -- that this code would be of much 
    importance or really have a lot of use. Then I got an 
    idea on how to improve its performance and create a new 
    use for it. (Program Noisy)
    

  Latest update: 2021-11-21 -- Add this boilerplate, minor changes

  Previous versions: 2020-11-23 -- Program essentially completed,

}

uses  SysUtils;

//faReadOnly   = $00000001;
//faHidden     = $00000002 platform;
//faSysFile    = $00000004 platform;
//faVolumeId   = $00000008 platform deprecated;
//faDirectory  = $00000010;
//faArchive    = $00000020;
//faNormal     = $00000080;
//faTemporary  = $00000100 platform;
//faSymLink    = $00000400 platform;
//faCompressed = $00000800 platform;
//faEncrypted  = $00004000 platform;
//faVirtual    = $00010000 platform;
//faAnyFile    = $000001FF;

Const
{$IFDEF Files}
    Banner = 'ScanFiles - Scan a directory and all subs and list all files (or just list sizes).';
{$ENDIF}
{$IFDEF Extensions}
    Banner = 'ScanExtensions - Scan a directory and all subs and list count of all file extensions.';
{$ENDIF}
    SlashChar = '\';
    DateFormatChars = 'yyyy"-"mm"-"dd hh":"nn":"ss';

type
      FilesP = ^TheFiles;
      ExtP   = ^Extension;
      ExtSortP = ^SortedExt;
      ExtCountP = ^ExtCount;
      SizeP = ^SizeTable;

      TheFiles =   Record
        Prev,           // only used if double-linked list is used
        Next:   FilesP;
        SubDirCount:Integer;  // subdirectories if this is one
        Attr: Integer;
        Size: Int64;
        Date: TdateTime;
        Name,
        Path,
        rpath,
        FQFN: UnicodeString;
    End;

        Extension =   Record
            Prev,
            Next:   ExtP;
            Count: Integer;
            Exten:  unicodeString;
        end ;

        SortedExt = record
            Prev,
            Next:   ExtSortP;
            Count: Integer;
            Groups: ExtCountP;
            GroupCount: Integer;
        end;

        SizeTable = Record
             Prev,
             Next:   SizeP;
             Size: Int64;
             Count: Int64;
        end;

        ExtCount = record
             Next: ExtCountP;
             Ext: UnicodeString;
        end;
      showtype = (ShowInvalid, ShowName, ShowMedium, ShowFQFN);

var
      f: text;
      totalext: integer = 0;
      CurrentDir,
      OriginalDir,
      Path:   UnicodeString;
      Attr,
      TotalDirCount,
      GlobalFileCount,
      TotalFileCount:Integer;
      D: TDatetime;
      FileChain,
      FileChainLast: FilesP;

      Ext,
      ExtLast: ExtP;
      SortMoveP,
      SortTop,
      SortBottom: ExtSortP;
      Sizes,
      SizeTop: SizeP;

      Rslt: TUnicodeSearchRec;


      Maxsize: Int64 = 0;
      SizeCount: Int64 = 0;
      SizeOnly: boolean = FALSE;
      ShowDate: boolean = FALSE;



      Function Comma(K:Int64):string;
var
   i:integer;
   s: string;
begin
    S := IntToStr(K);
    i := length(s)-3;
    while i>0 do
    begin
        S := Copy(S,1,i) +','+copy(s,i+1,length(s));
        I := I-3;
    end;
    Result := S;
end;



    Function GetExtension(Name:UnicodeString):UnicodeString;
    var
        P,
        Final: integer;
    begin
        // find the period in the name
        P:= pos('.',Name);
        // If no period, no extension
        if p = 0 then
        begin
            result := '';
            exit;
        end;
        final := p+1;
        while P<>0 do
        begin
            P := pos('.',Name,final) ;
            if p<>0 then
               final := P+1;
        end;
        Result :=  Copy(Name, final,length(Name));
    end;

Procedure ScanDir(Const Prefix: UnicodeString;    // from where
                                                  //   are we searching?
                  Const Recurse,                  // Search that place
                                                  //   recursively?
                        Dirs,                     // include directories
                                                  //   themselves in
                                                  //   items we list?
                        Files: Boolean);          // Do we also want to
                                                  //   collect files?
                                                  // (FALSE when we are
                                                  //    only collecting
                                                  //    directory names.)
var
   Rslt: TUnicodeSearchRec;
   E: UnicodeString;

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
end;

// unsorted collection - simple one-way (downward)
// linked list
procedure CollectFile(Const prefix:  UnicodeString);
BEGIN
    GetFileItem;
    with FileChainLast^ do
    begin
        Name  := rslt.name;
        Attr  := rslt.attr;
        Date  := rslt.TimeStamp;
        Size  := rslt.size;
        rpath := prefix;
        FQFN  := Currentdir + SlashChar  + prefix +  Rslt.Name;
        Inc(TotalFileCount);
        if rslt.size >Maxsize then
            Maxsize := rslt.size;

        if isDirectory then
        begin  // only count directories
            FQFN := FQFN+SlashChar;
            Inc(SubDirCount);
            Inc(TotalDirCount)
        end
    end;
end;

{$IFDEF Files}
{$I StoreSize.inc}
{$ENDIF}


{$Ifdef Extensions}
{$Include storeExt.inc}
{$ENDIF}

// not dirs means don't put directories in the list, not to exclude
// searching them if recurse is true
begin // scandir

   // If just listing directory(ies) and
   // not recursing, don't bother with
   // the status indicator
   if not dirs or recurse then
      WRITE(GLOBALFILECOUNT:7,#8#8#8#8#8#8#8#8#8);
    If FindFirst(Prefix+Path,Attr,rslt) = 0 Then
    Repeat
        If (rslt.Name = '.') Or  (rslt.Name = '..') Then
            continue;  // skip parent and self
        if isDirectory then
        begin
           if dirs then
                    // collectfile will Count them
               CollectFile(Prefix)
           else
               Inc(TotalDirCount);  // count directories even if not listing them
           if recurse then
               ScanDir(prefix+rslt.Name+SlashChar,TRUE,Dirs,Files);
        end
        else    // NOT a directory
           if files then
           begin
               // Check extension



               CollectFile(Prefix);
               inc(GlobalFileCount);

{$IFDEF Extensions}
               // If not collecting extensions
               // then skip this
                 E := LowerCase(GetExtension(rslt.Name)); // so all extensions are the same
                 StoreExt;
{$ENDIF}
           end;

    Until FindNext(rslt) <> 0;
    FindClose(rslt);
 end;



{$IFDEF Extensions}
{$I SortExt.inc}
{$ENDIF}

{$i FreeFiles.inc}

{$I printchain.inc}

{$IFDEF Extensions}
     Procedure printext;
     Const
         Ascending = False;

     VAR
        CP:ExtCountP;
        S: UnicodeString;
        N: Byte;

     begin
        Writeln('. Total extensions found: ',TotalExt);
        // NOTE: Since ascending is a constant,
        // one of these lines will get a "dead code walking"
        // message, i.e. Unreachable Code warninhg
        if Ascending then
            SortMoveP := SortTop
        else
            SortMoveP := SortBottom;

         writeln('Extensions by usage');
        while SortMoveP <> nil do
        begin
           CP := SortMoveP^.Groups;
           If CP =NIL then continue;

           write(SortMoveP^.count:8);
           if sortmovep^.Groupcount >4 then
             write (' (',SortMoveP^.Groupcount:3,') ')
           else
             write ('  ':7)
           ;

           N := 10;

           while CP<>nil do
           begin
              S := CP^.Ext;
              If S='' then
                S :='[No Extension]'
               else
                 S := '".'+S+'"';

              If N+Length(S) > 76 then
              begin
                  writeln;
                  write(' ':10);
                  N := 10;
              end;
              Write(S,'  ');
              N := N+Length(CP^.Ext)+2;
              CP := CP^.Next;
           end;
           writeln;
           // NOTE: Since ascending is a constant,
           // one of these lines will get a "dead code walking"
           // message, i.e. Unreachable Code warninhg
           if Ascending then
              SortMoveP := SortMoveP^.next
            else
              SortMoveP := SortMoveP^.prev;
         end;
        writeln;
     end;

{ $I DoubleCheck.inc - if needed}

     Procedure DumpExt;
     begin
         ExtLast := Ext;
         While extLast<>nil do
         begin
             writeln('  ',extlast^.count,' ',extlast^.Exten );

            Extlast := ExtLast^.next;
         end;
     end;

{$ENDIF}
     Procedure One;
     var
        newpath:UnicodeString;

     begin
// initialization
       path := '*';
       attr := faAnyFile;

{$IFDEF Extensions}       
       TotalExt := 0;
{
       Write('For Analysis, the ',
             'RSLT record size is ',
             SizeOf(Rslt),' bytes. ');
       WriteLn('The File record is ',SizeOf(TheFiles),
             ' bytes, Extension record is ',
             Sizeof(Extension));
       Writeln('Sort record is ',SizeOf(SortedExt),
              ' bytes, and Count record is ',
 ['{8AA0331B-F305-48E9-A2E6-C8AE339FE1ED}']              SizeOf(ExtCount),' bytes.');
       }
{$ENDIF}
        Writeln(Banner);
        repeat
            GlobalFileCount := 0;
            TotalDirCount :=0;
            Writeln('Current Directory is ',CurrentDir);

            scandir('', false,true,false);  // collect only directories
                                            // when starting

            WRITELN;
            Writeln('Available subdirectories ',TotalDirCount,':');
            PrintChain(true,ShowName);
            Writeln;
            FreeFilesNext ;
            Write('Enter new path, : to exit, ');
{$IFDEF Files}
            Write(':: to just list sizes, ');
            Write('> to show files from here with date and time, ');
{$ENDIF}
            writeln;
            write('or Enter for files from here: ');
            readln(NewPath);
            if newpath=':' then halt;
{$IFDEF Files}
            if newpath='>'  then begin ShowDate := TRUE; newpath :=''; END;
            if newpath='::' then begin SizeOnly := TRUE; newpath :=''; END;
{$ENDIF}
            if newpath <> '' then
            begin
                MaxSize := 0;

                Chdir(newPath);
                Currentdir   := utf8dECODE(GetCurrentDir);
            end;
        until newpath = '';

        writeln('Scan of ',CurrentDir);
        GlobalFileCount := 0;
        TotalFileCount := 0;
{$IFDEF Extensions}  
        scandir( Currentdir+SlashChar, true,false,true);
{$ENDIF}          
{$IFDEF Files}
        scandir('' , true,false,true);
        Writeln(Comma(GlobalFileCount),' files. ',
               ' Largest file is ',Comma(maxsize),' bytes');
        write('PRESS RETURN: '); READLN;
         printChain(False,ShowMedium);
{$ENDIF}       
{$IFDEF Extensions}
//  SortExt will write something directly after this
//  that starts with a comma, so don't use WRITELN or
//  add a period, unless you change it too.
        Write(' ',Comma(GlobalFileCount),' files');
        SortExt;
 //       DoubleCheck;

         printext;
       // dumpExt;
{$ENDIF}       
        writeln;

      end;


begin  // main

        Originaldir   := utf8dECODE(GetCurrentDir);
        CurrentDir := Originaldir;
        FileChain := nil;
        FileChainLast := nil;

       One;

        Writeln;
        write('Press return: ');
        readln;
end.
