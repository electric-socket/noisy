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



        SizeTable = Record
             Prev,
             Next:   SizeP;
             Size: Int64;
             Count: Int64;
        end;


      showtype = (ShowInvalid, ShowName, ShowMedium, ShowFQFN);

var
      f: text;                     // if writing to file
      totalext: integer = 0;       // number of extensions found
      CurrentDir,                  // Current directory searching
      OriginalDir,                 // original directory when started
      Path:   UnicodeString;       // path to search
      Attr,                        // file attributes
      TotalDirCount,               // number of files or directories found
      GlobalFileCount,             // no. files and directories
      TotalFileCount:Integer;
      D: TDatetime;                // for date/time
      FileChain,                   // Linked list of files,
                                   //  " lowest entry if sorted
      FileChainLast: FilesP;       //  " highest entry if sorted

      Ext,                         // Extensions list, most to least used
      ExtLast: ExtP;               //       "           least to most used
      SortMoveP,                   // Extension Sort temp
      SortTop,                     //   " most ised to least used
      SortBottom: ExtSortP;        //   " least used to most used

      Rslt: TUnicodeSearchRec;     // collect dir search info one file


      Maxsize: Int64 = 0;           // largest file found
      SizeOnly: boolean = FALSE;    // sort by and show file sizes
      SizeDown: boolean = FALSE;    // true to sort descending,
                                    // false for ascending if sorting
      ShowDate: boolean = FALSE;    // show file dates



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



Procedure newScanDir(Const Prefix: UnicodeString;    // from where
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
        begin  // only count directoriies
            FQFN := FQFN+SlashChar;
            Inc(SubDirCount);
            Inc(TotalDirCount)
        end
    end;
end;


{$I CollectSize.inc}





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
               If SizeOnly then
                  CollectSize(Prefix)
               else
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


{$i FreeFiles.inc}

{$I printchain.inc}


     Procedure One;
     var
        newpath:UnicodeString;

     begin
// initialization
       path := '*';
       attr := faAnyFile;


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
            Write('::+ to list by sizes, low to high, ');
            Write('::- to list by sizes, high to low, ');
            Write('> to show files from here with date and time, ');
{$ENDIF}
            writeln;
            write('or Enter for files from here: ');
            readln(NewPath);
            if newpath=':' then halt;
{$IFDEF Files}
            if newpath='>'  then
            begin
                ShowDate := TRUE;
                newpath :='';
            END;
            if newpath='::+' then
            begin
                SizeOnly := TRUE;
                SizeDown := TRUE;
                newpath :='';
            END;
            if newpath='::-' then
            begin
                SizeOnly := TRUE;
                SizeDown := FALSE;
                newpath :='';
            END;

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

           // list the table

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
