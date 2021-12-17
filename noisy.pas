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
, N_Perform, N_Utility, N_Static, N_Version, N_Help, unit1;


procedure banner;
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
    CurrentDir := UTF8Decode(GetCurrentDir);
    Writeln('Current directory ',CurrentDir);
    Writeln;

end;

procedure main;
begin
    banner;

    if ( paramcount <1) or
       (Param1='/H') or
       (Param1='-H') or (Param1='--HELP') then
       Help;

     PC := ParamCount;
     if PC >100 then
     Begin
         PC := 100;
         Writeln('Notice: More than 100 parameters found. ',
                 'Only the first 100 are used.');
         Writeln('You might want to consider using a command file');
     end;
     For I := 1 to PC do
        Param[I] := (Paramstr(I));


    // Check command lines and any options






     FM := filemode;
     FileMode := 0; // force read-only in case file is read only

{$IFDEF Console}
     repeat
         write('Enter file name, or empty for no option file: ');
         readln(CommandFile);
         if CommandFile = '' then break;
         assign(F,fn);
         {$I-} reset(F); {$I+}
         IR := IOResult;
         if IR = 0 then break;
         writeln('Error ',IR);
     until false;
{$ENDIF}

// begin timing now
     GetLocalTime(StartTime);
     writeln('Started: ',CTS(StartTime));

     // This is where the program starts performing
     // Initialize everything

       Init;

      // for right now, the program is very simple
      // it will scan a directory (and all subdirectories)
      //for all files having  certain extensions.

{$IFDEF Console}
             Writeln('** CD=',currentdir);
{$ENDIF}
{$IFDEF Testing}
       Writeln('*** WARNING: Test mode using LIB subdir');
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

