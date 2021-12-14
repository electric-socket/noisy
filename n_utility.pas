// Misc Utility routines
unit N_utility;
{$mode ObjFPC}{$H+}

interface
uses
  Classes,  windows,sysutils;



const
    Version = 'Ver. 0.1.45';
    Quote ='"';
    Buffercount = 10; // Maximum numder of input and output files
                      // that can be opened simultameously

    RadixString: Array[0..36] of char=('0','1','2','3','4','5','6','7','8','9',
                          'A','B','C','D','E','F','G','H','I','J',
                          'K','L','M','N','O','P','Q','R','S','T',
                          'U','V','W','X','Y','Z',
                          'A');    // extra is to trap 'fall-offs'

    Months: array[1..12] of string[9]=
            ('January','February','March',   'April',   'May','     June',
             'July',    'August', 'September','October','November', 'December');
    Days: Array[0..6] of string[9]=
            ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

    SlashChar = '\'; // Your system's directory separator,
                     // \ on windows; / on unix, linux, etc
    NoisyPrefix = '{';  // so noisy doesn't trip on iyself

type

     TBuffer = record
         InFile,                  //<the input file
         OutFile: File;           //<output file
         InName,                  //<name of the input file
         OutName: UnicodeString;  //<name of output file
         LineNumber,              //<Line number in input file
         LinePosition: integer;   //<poition on line
      // as file size and positioning
      // these might be larger than integer
         InSize,                  // size of input file
         OutSize,                 //  and output file
         inPos,                   // current position on in file
         OutPos: Int64;           //  and on out file
     end;

     TSystemTime = record
        Year,
        Month,
        DayOfWeek,
        Day : word;
        Hour,
        Minute,
        Second,
        MilliSecond: word;
     end;

     SettingPlacement = (Prefix, Overwrite, PassComment, None); // How the
                                             // Noisy comment is to be added
     TypeUsed = (Brace, StarComma, SlashSlash); // what type comment
     MarkPlace = (before, after, NoMark);    // where mark of insertion is put
     MainInsert = (triggerANDBothFlags, bothflags, triggerANDstartflag,
                   startflag, triggerANDEndflag, Endflag, noflag); // what gors
                                             // into main program
     FillStrings = Array[1..6] of UnicodeString;  // lines to insert
     SettingsRec = Record
          TopAddMode,                        // how first comment is added
          BottomAddMode: SettingPlacement;   // how end comment is added
          TopType,                           // what form of comment at top
          BottomType: TypeUsed;              // what form at bottom
          FillTop,                           // lines to insert at top
          FillBottom: FillStrings;           // lines to insert at bottom
          Activator,                         // string in main program used
                                             // to activate display
          Flag: UnicodeString;               // string to flag inserted lines
          MaxLength: Byte;                   // maximum lemgth of lines
          Main: MainInsert;                  // what to put in main program
     end;


var
    Buffer: Array[1..Buffercount] of TBuffer;
  Settings: SettingsRec =(
               TopAddMode: Prefix;
               BottomAddMode: Prefix;
               TopType: Brace;
               BottomType: Brace;
               FillTop: ('File &Path&FN marked &date.&time',
                         '$IFDEF Noisy',
                         '$INFO &Path&FN entered',
                         '$ENDIF',
                         '',
                         '');
              FillBottom: ('$IFDEF Noisy',
                          '$INFO &Path&FN left',
                          '$ENDIF',
                          'File &Path&FN marked &date.&time',
                          '',
                          '');
              Activator: '$DEFINE Noisy';
                   Flag:  NoisyPrefix+'.Noisy'; // so it doesn't
                                                // see it in itself
             MaxLength: 71;
             Main: triggerANDBothFlags;
            );


  StartTime,               // for elapsed time
  EndTime: SystemTime;

  Param1,    // used to read command linme parameters
  Param2,
  CommandFile,  // file to read commands
  TextPrefix,   // to balance help stmts
  LineContinuation,  // separate explanation from command
  TimeString: String; // To display date and time
  H,M,S,MS,           // timing values
  FM,                 // saved filemode
  IR,                 // saved IOResult
  LineCount:Integer;  // number of lines


  Dot: char ='.';  // your systwm's separator for extension

  Type
     ExtP   = ^Extension;
     Extension =   Record
            Prev,
            Next:   ExtP;
            Exten:  unicodeString;
     end ;

var
// Extensions


  E: UnicodeString;
  totalext: integer = 0;




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
    Rslt: TUnicodeSearchRec;   //< Directory search
    Attr,                      //< file attributes
    TotalFileCount,            //< all files found
    GlobalFileCount: Integer;  //< all files kept
    MaxSize: Int64;            //< largest file found

    // Directories
    CurrentDir,                 //< Directory we started in
    Path:   UnicodeString;      //< Path to file

    TopLines,                   //< Lines to insert at top
    BottomLines: array[1..6] of  UnicodeString; //< Lines to insert at bottom

const

        // Date/Time display format
    DateFormatChars = 'yyyy"-"mm"-"dd hh":"nn":"ss';


Function CTS(Const CTime:SystemTime): AnsiString;  //< Create Time String
Function Radix( N:Int64; theRadix:Int64):string; //< convert numbers
function I2(N:Word):string;               //< insert leading 0 if N<10
// select correct tense when number is single or plural
Function Plural(N:Int64; Plu:String; Sng: String): string;
// convert a file name to its component parts
procedure SplitPath(const Path: UnicodeString; var Folder, Name, Ext: UnicodeString);
Procedure GetExt(const Path: UnicodeString; var Ext: UnicodeString);

implementation

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



 // procedure GetLocalTime(var SystemTime: TSYSTEMTIME) ;
 //           external 'kernel32.dll'; // name 'GetLocalTime';

  // Paul Robinson 2020-11-08 - My own version of
  // InttoStr, but works for any radix, e.g. 2, 8, 10, 16,
  // or any others up to 36. This only works for
  // non-negative numbers.
  Function Radix( N:Int64; theRadix:Int64):string;
  VAR
     S: String;
     rem, Num:integer;
  begin
      S :='';
      Num := N;
    if num = 0 then
       S := '0';
     while(num>0)  DO
     begin
        rem := num mod theRadix;
        S := RadixString[ rem ]+S;
        num := num DIV theRadix;
      end;
     Result := S;
 end;


  function I2(N:Word):string;
  var
     T1:String[3];
   begin
      T1 :=Radix(N,10);
      If Length(T1)<2 then
         T1 := '0'+T1;
      Result := T1;
  end;


  Function Plural(N:Int64; Plu:String; Sng: String): string;
  Var
     s:String;
  Begin
      S := Radix(N,10);
      S := ' '+S+' ';
      If n<>1 Then
          Result:= S+ Plu
       Else
          Result := S + Sng;
  End;

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



end.

