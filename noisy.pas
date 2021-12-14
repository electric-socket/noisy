// All included files start with N_ so
// they won't conflict with files I use
// for other purposes.

// Author:  Paul Robinson
// Version: 0.1.45
// Date:    2021-12-03



{$ifdef mswindows}{$apptype console}{$endif}
{$I NoisyPrefixCode.inc}
program noisy;
uses sysutils
// FPC 3.0 fileinfo reads exe resources as long as you register the appropriate units
, fileinfo
, winpeimagereader {need this for reading exe info}
, elfreader {needed for reading ELF executables}
, machoreader {needed for reading MACH-O executables}
, N_Perform, N_Utility, N_Static;

{$IFDEF AUTOVersion}
     {
       Displays file version info for
     - Windows PE executables
     - Linux ELF executables (compiled by Lazarus)
     - macOS MACH-O executables (compiled by Lazarus)
       Runs on Windows, Linux, macOS

       begin
         FileVerInfo:=TFileVersionInfo.Create(nil);
         try
           FileVerInfo.ReadFileInfo;
           writeln('Company: ',FileVerInfo.VersionStrings.Values['CompanyName']);
           writeln('File description: ',FileVerInfo.VersionStrings.Values['FileDescription']);
           writeln('File version: ',FileVerInfo.VersionStrings.Values['FileVersion']);
           writeln('Internal name: ',FileVerInfo.VersionStrings.Values['InternalName']);
           writeln('Legal copyright: ',FileVerInfo.VersionStrings.Values['LegalCopyright']);
           writeln('Original filename: ',FileVerInfo.VersionStrings.Values['OriginalFilename']);
           writeln('Product name: ',FileVerInfo.VersionStrings.Values['ProductName']);
           writeln('Product version: ',FileVerInfo.VersionStrings.Values['ProductVersion']);
         finally
           FileVerInfo.Free;
         end;

     }
     FileVerInfo: TFileVersionInfo;

{$R *.res}


Function Version:AnsiString;
begin
  try
    FileVerInfo.ReadFileInfo;
    Result:= FileVerInfo.VersionStrings.Values['FileVersion'];
  finally
    FileVerInfo.Free;
  end;
end;

Function CopyRight:AnsiString;
begin
  try
    FileVerInfo.ReadFileInfo;
    Result := FileVerInfo.VersionStrings.Values['LegalCopyright'];
  finally
    FileVerInfo.Free;
  end;
end;
{$ELSE}
Const
    Version = 'Ver. 0.1.45';
    CopyRight = 'Copyright 2021 Paul Robinson';
{$ENDIF}



procedure main;
begin

    Writeln('Noisy: Program to tag (or remove said tags from) source code, ',
                    Version);
    Writeln(Copyright,' - Released under GPL ver. 2');
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
{
      TimeString := Days[StartTime.dayOfWeek]+' '+Months[StartTime.month]+
                  ' '+IntToStr(StartTime.day)+', '+IntToStr(StartTime.year)+
                  ' '+IntToStr(StartTime.Hour)+':'+I2(StartTime.Minute)+
                  ':'+I2(StartTime.Second);
}
       writeln('Started: ',CTS(StartTime));

       // This is where the program starts performing
       // Initialize everything

       Init;


       // for right now, the program is very simple
       // it will scan a directory (and all subdirectories)
       //for all files having  certain extensions.

       Currentdir   := UTF8Decode(GetCurrentDir);
       Writeln('** CD=',currentdir);
{$IFDEF Testing}
       ScanFiles('lib\'); // start with alternate directory
{$ELSE}
       ScanFiles(''); // start with our directory
{$ENDIF}
       writeln('** Back');

       // It will then ask whether to add noisy marks,
       // or remove them.

       If GlobalFileCount <1 then
          Writeln('No files found that match your selection.')
       else
       begin
           VerifyRequest;

       // then it will do so, reporting along the way.


           Process;
       end;

       // then report how long it took

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
end;

{$R *.res}

begin
    Main;
    writeln;
    write('Press Enter: ');
    readln;



end.

