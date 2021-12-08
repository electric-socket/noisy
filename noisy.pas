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
     LargeInt = Integer; // It is for 32 bit operating systems }
{$ELSE}
   {$FATAL Machine size must be 32 or 64 Bits}
{$ENDIF}
{$ENDIF}

    Pcharacter = ^Char;

   { Taking a hint from the XDPascal compiler, I don't
     read or write files one byte at a time. I request
     a block of memory big enough to either:(1) hold the
     entire file, read it all into that, then go through
     the cached memory copy a byte at a time; or
     (2) Create a reasonable sized buffer, and read as much
     of ther file as will fit, then process as much as
     will fit, then advance a block at a time
     *Much* faster. }

     TBuffer = record
         InFile,                  // the input
         OutFile: File;           //  and output files
         InName,                  // name of the input
         OutName: UnicodeString;  //  and output files
         inPtr,                   // where we are in the buffer
         OutPtr: PCharacter;      //  for input and output files
         Ch, Ch2,                 // the characters being read
         OutCh: Char;             //  and written
         LineNumber,               // Line number in input file
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
            Count: Integer;
            Exten:  unicodeString;
     end ;



var
  F: Text;

  Buffer: Array[1..Buffercount] of TBuffer;
//  StartTime,
//  EndTime: TSystemTime;

  StartTime,
  EndTime: SystemTime;

  FN, Line,
  TimeString1,
  TimeString: String;
  H,M,S,MS,
  FM, IR, LineCount,
  ProcFuncCount,
  TotalData: Integer;
  CompCount:Double;
  Dot: char ='.';  // your systwm's separator for extension

// Extensions
  Ext,
  ExtLast: ExtP;
  E: UnicodeString;
  totalext: integer = 0;

{$I N_StoreExt.inc}

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
    Writeln('Noisy: Program to tag source code, ',Version);
    Writeln('Copyright 2021 Paul Robinson - Released under GPL ver. 2');

    // Check command lines and any options


    Writeln('Current directory ',GetCurrentDir);

     FM := filemode;
     FileMode := 0; // force read-only in case file is read only
     repeat
         write('Enter file name: ');
         readln(fn);
         assign(F,fn);
         {$I-} reset(F); {$I+}
         IR := IOResult;
         if IR = 0 then break;
         writeln('Error ',IR);
     until false;

     StartTime.Year :=0;
     Linecount :=0;
     GetLocalTime(StartTime);
      TimeString := Days[StartTime.dayOfWeek]+' '+Months[StartTime.month]+
                  ' '+IntToStr(StartTime.day)+', '+IntToStr(StartTime.year)+
                  ' '+IntToStr(StartTime.Hour)+':'+I2(StartTime.Minute)+
                  ':'+I2(StartTime.Second);
       writeln('Started: ',TimeString);

       // This is where the program starts performing

       While not eof(F) do
       begin
          Readln(F,line);
          inc(linecount);
          // something else

       end;

       close(F);
       writeln(Linecount,' lines');

(*       writeln;
       write('Wait a while, then press Enter: ');
       readln;
*)
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

