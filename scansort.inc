// scansort.inc

{ The following code is used by both
  SortExtnsions (which sets the **Extensions**
                 compile-time define) and by 
  Scanfiles     (which sets the **Files** 
                compile-time define)

 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
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
    2021-11-21:  I set both programs aside for so long I've
    forgotten exactly what it does...

    Was not using source code control (my bad, probably not
    a good idea, but I didn't think - an unfortunatley all 
    too common practice -- that this code would be of much 
    importance or really have a lot of use. Then I got an 
    idea on how to improve its performance and create a new 
    use for it. (Program Noisy)
    

  Latest update: 2021-11-21 -- Add this boilerplate, minor changes

  Previous versions: 2020-11-23 -- Program essentially completed,

}

uses  SysUtils ;

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
    Banner = 'ScanFiles - Scan a directory and all subs and list all files.');
{$ENDIF}
{$IFDEF Extensions}
    Banner = 'ScanExtensions - Scan a directory and all subs and list count of all file extensions.';
{$ENDIF}
    SlashChar = '\';

type
      FilesP = ^TheFiles;
      ExtP   = ^Extension;
      ExtSortP = ^SortedExt;
      ExtCountP = ^ExtCount;

      TheFiles =   Record
        Prev,           // only used if double-linked list is used
        Next:   FilesP;
        FileCount,   // files I have
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
            Exten:  unicodeString;  // subdirectories if this is one
        end ;

        SortedExt = record
            Prev,
            Next:   ExtSortP;
            Count: Integer;
            Groups: ExtCountP;
            GroupCount: Integer;
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

      MasterRslt: TUnicodeSearchRec;


      Function Comma(K:Longint):string;
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


    Procedure ScanDir(Const Prefix: UnicodeString;
                      Const Recurse,
                            Dirs,
                            Files: Boolean);
    var
       Rslt: TUnicodeSearchRec;
       E: UnicodeString;

    Function isDirectory: boolean;
    begin
         result := (rslt.Attr And faDirectory) = faDirectory;
    end;

    // unsorted collection - simple one-way (downward)
    // linked list
    procedure CollectFile(Const prefix:  UnicodeString);
    BEGIN
        GetFileItem;
        with FileChainLast^ do
        begin
            Name := rslt.name;
            Attr := rslt.attr;
            Date:= rslt.TimeStamp;
            fileChainLast^.rpath := prefix;
            FQFN :=  Currentdir + SlashChar  + prefix +  Rslt.Name;
            Date := rslt.TimeStamp;

            if isDirectory then
            begin  // only count directoriies
                FQFN := FQFN+SlashChar;
                Inc(SubDirCount);
                Inc(TotalDirCount)
            end
            else
            begin  // only count files
                inc(FileCount);
                inc(GlobalFileCount);
                end;   // count total
                Inc(TotalFileCount);

        end;
    end;

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
          WRITE(GLOBALFILECOUNT:6,#8#8#8#8#8#8#8#8#8);
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
               begin
                   ScanDir(prefix+rslt.Name+SlashChar,Recurse,Dirs,Files);

               end;
            end
            else
               if files then
               begin
                   CollectFile(Prefix);
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

{$include   FreeFiles.inc}

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
       Write('For Analysis, the ',
             'RSLT record size is ',
             SizeOf(MasterRslt),' bytes. ');
       WriteLn('The File record is ',SizeOf(TheFiles),
             ' bytes, Extension record is ',
             Sizeof(Extension));
       Writeln('Sort record is ',SizeOf(SortedExt),
              ' bytes, and Count record is',
               SizeOf(ExtCount),' bytes.');
{$ENDIF}
        Writeln(Banner);
        repeat
            GlobalFileCount := 0;
            TotalDirCount :=0;
            Writeln('Current Directory is ',CurrentDir);

            scandir('', false,true,false);

            WRITELN;
            Writeln('Available subdirectories ',TotalDirCount,':');
            PrintChain(true,ShowName);
            Writeln;
            FreeFilesNext ;
            Write('Enter new path, : to exit, or Enter for here: ');
            readln(NewPath);
            if newpath=':' then halt;
            if newpath <> '' then
            begin
                Chdir(newPath);
                Currentdir   := utf8dECODE(GetCurrentDir);
            end;
        until newpath = '';

        writeln('Scan of ',CurrentDir);
        GlobalFileCount := 0;
{$IFDEF Extensions}  
        scandir( Currentdir+SlashChar, true,false,true);
{$ENDIF}          
{$IFDEF Files}
        scandir('' , true,false,true);
        Writeln(Comma(GlobalFileCount),' files');
{$ENDIF}       
{$IFDEF Extensions}        
        Write(' ',Comma(GlobalFileCount),' files');
        SortExt;
 //       DoubleCheck;
         printext;
{$ENDIF}
{$IFDEF Files}
       printChain(False,ShowMedium);
{$ENDIF}
{$IFDEF Extensions}  
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
