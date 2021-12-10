{$DEFINE BITS64}{ This is compiled for 64-bit machines}
{$UNDEF BITS32}
// All included files start with N_ so
// they won't conflict with files I use
// for other purposes.

// Author:  Paul Robinson
// Version: 0.1
// Date:    2021-12-03

program noisy;
uses windows,sysutils;
const
    Version = 'Ver. 0.1';
    Quote ='"';
    Buffercount = 10; // Maximum numder of input and output files
                      // that can be opened simultameously
    MaxBufSize = 100000; // maximum amount of memory buffer can use

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
{$IFDEF BITS64}
     LargeInt = Int64;  // files we work with wonm't br this big,
                      // but the compiler is using the new values,
                      // because some files (like videos, especially
                      // with 2.7K or 4K video, they can be bigger
                      // than 2**32 bits, about 4GB, so the file system
                      // has to support them.
{$ELSE}
{$IFDEF BITS32}
     LargeInt = LongInt; // It is for 32 bit operating systems }
{$ELSE}
   {$FATAL Machine size must be 32 or 64 Bits}
{$ENDIF}
{$ENDIF}




     TBuffer = record
         InFile,                  // the input
         OutFile: File;           //  and output files
         InName,                  // name of the input
         OutName: UnicodeString;  //  and output files
         Ch, Ch2,                 // the characters being read
         OutCh: Char;             //  and written
         LineNumber,              // Line number in input file
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
         OutPos: LargeInt;        //  and on out file
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

     ExtP   = ^Extension;
     Extension =   Record
            Prev,
            Next:   ExtP;
            Exten:  unicodeString;
     end ;

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
  F: Text;

  Buffer: Array[1..Buffercount] of TBuffer;
//  StartTime,
//  EndTime: TSystemTime;
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
                         '$INFO &Path&FN entered',
                         '$ENDIF',
                         'File &Path&FN marked &date.&time',
                         '',
                         '');
             Activator: '$DEFINE Noisy';
                  Flag:  NoisyPrefix+'.noisy}'; // so it doesn't
                                              // see it in itself
             MaxLength: 71;
             Main: triggerANDBothFlags;
            );

  Fold: boolean = FALSE;

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
  LineCount,          // number of lines
  TotalData: Integer;
  CompCount:Double;
  Dot: char ='.';  // your systwm's separator for extension

// Extensions

  TakeExt,
  Exclude: ExtP;
  E: UnicodeString;
  totalext: integer = 0;



// Converts a file name into direcvtory, name, extension.

procedure SplitPath(const Path: UnicodeString; var Folder, Name, Ext: UnicodeString);
{}var
  DotPos, SlashPos, i: Integer;
(**)begin
Folder := '';
Name := Path;
Ext := '';

DotPos := 0;
SlashPos := 0;

for i := Length(Path) downto 1 do
  if (Path[i] = Dot) and (DotPos = 0) then
    DotPos := i
  else if (Path[i] = SlashChar) and (SlashPos = 0) then
    SlashPos := i;

if DotPos > 0 then
  begin
  Name := Copy(Path, 1, DotPos - 1);
  Ext  := Copy(Path, DotPos, Length(Path) - DotPos + 1);
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



 // procedure GetLocalTime(var SystemTime: TSYSTEMTIME) ;
 //           external 'kernel32.dll'; // name 'GetLocalTime';

  // Paul Robinson 2020-11-08 - My own version of
  // InttoStr, but works for any radix, e.g. 2, 8, 10, 16,
  // or any others up to 36. This only works for
  // non-negative numbers.
  Function Radix( N:LargeInt; theRadix:LargeInt):string;
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


  Function Plural(N:LargeInt; Plu:String; Sng: String): string;
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




begin

    Writeln('Noisy: Program to tag (or remove said tags from) source code, ',
                    Version);
    Writeln('Copyright 2021 Paul Robinson - Released under GPL ver. 2');
    Starttime.Year:=0; EndTime.Year:=0;    // eliminate uninitialized warning
    GetLocalTime(StartTime);
    Write('Good ');
    If StartTime.Hour <12 then
        Write('morning')
    else  if StartTime.Hour <18 then
        Write('afternoon')
    else
        Write('evening');
    writeln(', it is now ', CTS(StartTime));
    Writeln('Current directory ',GetCurrentDir);
    Writeln;
    Param1 := UPPERCase(Paramstr(1));

    LineContinuation := Space(10);
    TextPrefix := Space(20);

    if ( paramcount <1) or
       (Param1='/H') or
       (Param1='-H') or (Param1='--HELP') then
    begin
        writeln('Usage: ',paramstr(0),' ');
        writeln;
        writeln(LineContinuation,'Then on the command line specify any one of:');
        writeln;
        Writeln(TextPrefix,'@NAME  ',
               '[process directory (and subdirs) according to ',
               'instructions in file NAME]');
        Writeln(TextPrefix,'/G | /GO | -g | --go  ',
                  '[equivalent to @noisy.cfg ]');
        Writeln(TextPrefix,'/A | -a | /ADD | --add  ',
                ' [insert noisy marks in files in this directory');
        Writeln(TextPrefix,LineContinuation,'(and subdirs) according ',
                                            'to ADD settings in noisy.cfg]');
        Writeln(TextPrefix,'/H | -h | /HELP | --help | --HELP  ',
                '[show this message and exit]');
        Writeln(TextPrefix,'/R | -r | /REMOVE | --remove  ',
                      '[Remove noisy marks from files in this directory ');
        Writeln(TextPrefix,LineContinuation,'(and subdirs) according to ',
                      'REMOVE settings in noisy.cfg]');
        Writeln(TextPrefix,'/W | /WRITE | -w | --write  ',
                      '[write internal settings to noisy.cfg]');
        writeln;
        writeln(LineContinuation,'Options which may be used as ',
                       'second argument:');
        writeln;
        Writeln(TextPrefix,'/T | -t | /TEST | --dryrun  [Display settings, ',
                       'names of files to process, and exit]');
        writeln;
        Writeln('Note: If noisy.cfg is not present, internal settings ',
                'will be used');
        Writeln('A process file name containing spaces must be ',quote,
                '@quoted like.this',quote);
        writeln('Command switches starting with / , - , or -- are ',
                'not case sensitive');
    end;

    writeln;


    // Check command lines and any options






     FM := filemode;
     FileMode := 0; // force read-only in case file is read only
 (*    repeat
         write('Enter file name: ');
         readln(CommandFile);
         assign(F,fn);
         {$I-} reset(F); {$I+}
         IR := IOResult;
         if IR = 0 then break;
         writeln('Error ',IR);
     until false;    *)

     GetLocalTime(StartTime);
      TimeString := Days[StartTime.dayOfWeek]+' '+Months[StartTime.month]+
                  ' '+IntToStr(StartTime.day)+', '+IntToStr(StartTime.year)+
                  ' '+IntToStr(StartTime.Hour)+':'+I2(StartTime.Minute)+
                  ':'+I2(StartTime.Second);
       writeln('Started: ',TimeString);

       // This is where the program starts performing










       GetLocalTime(EndTime);
       TimeString :=  Days[EndTime.dayOfWeek]+' '+Months[EndTime.month]+
                  ' '+IntToStr(EndTime.day)+', '+IntToStr(EndTime.year)+
                  ' '+IntToStr(EndTime.Hour)+':'+I2(EndTime.Minute)+
                  ':'+I2(EndTime.Second);


        Writeln('Process completed: ',TimeString);


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
        Timestring := Timestring +' and';
    Timestring := TimeString + Radix(S,10)+'.' + Radix(MS,10)+' seconds.';
    Writeln( 'Process took '+TimeString);

    writeln;
    write('Press Enter: ');
    readln;



end.

