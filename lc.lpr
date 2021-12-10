{$mode objfpc}{$H+}
{$UNDEF Disk}
{$ifdef mswindows}{$apptype console}{$endif}
program lc;

uses {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,sysutils
  // FPC 3.0 fileinfo reads exe resources as long as you register the appropriate units
  , fileinfo
  , winpeimagereader {need this for reading exe info}
  , elfreader {needed for reading ELF executables}
  , machoreader {needed for reading MACH-O executables}
  ;

Const
{$IFNDEF AUTOVersion}
    Version = '0.0.1';
    Copyright = 'Copyright 2021 Paul Robinson';
{$ENDIF}

    Months: array[1..12] of string[9]=
            ('January','February','March',   'April',   'May','     June',
             'July',    'August', 'September','October','November', 'Decenber');
    Days: Array[0..6] of string[9]=
            ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');


var
     CmdLine,
     Param1: ansistring;
     BadCount: integer=0;
     I: Integer;
     StartTime,
     TimeNow,                    // Spare for other time requests
     EndTime: TSystemTime;
     DidSomething: boolean = FALSE;

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
{$ENDIF}


Function Plural(N:Int64; Plu:AnsiString; Sng: AnsiString): AnsiString;
Var
   s:AnsiString;
Begin
    S := IntToStr(N);
    S := ' '+S+' ';
    If n<>1 Then
        Result:= S + Plu
     Else
        Result := S + Sng;
End;


Function Elapsed(const Start,Finish:TSystemTime): String;
var
    H, M, S:Integer;             // Time calculations
begin

// We don't bother trying to determine days

    H := Finish.Hour;
    if Finish.Hour  < Start.Hour  then
        h:=H + 24;
    h := h - Start.Hour;
    M := Finish.Minute ;
    if M < Start.minute then
    begin
        H := H-1;
        M := M+60;
    end;
    M := M - Start.minute;
    S := Finish.second  ;
    if S < Start.second then
    BEGIN
        M := M-1;
        S := S+60;
    END;
    S := S-Start.second;

    Result :='';
    If H >0 then
        Result := Plural(H,'hours','hour')+' ';
    If M >0 then
        Result := Result + Plural(M,'minutes','minute')+' ';
    if Result <> '' then
        Result := Result +' and ';
    Result := Result + IntToStr(S)+Plural(S,' seconds.',' second.');

end;


Function CTS(Const CTime:TSystemTime): AnsiString;
Const
     Space = ' ';

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

FUNCTION ProcessFile(Const FileName: ANSIString):integer;
Begin
     Writeln; Writeln('** Stub procedure ProcessFile'); writeln;

   Result := 0;
end;

Procedure Help;
Begin
     Writeln; Writeln('** Stub procedure Help'); writeln;


end;

Procedure Choose;
Begin
     Writeln; Writeln('** Stub procedure Choose'); writeln;


end;

Procedure ChangeDir;
VAR
     NewPath: AnsiString;
     N,
     Err,
     IR: Integer;

Begin
     N := Pos(' ',CmdLine);
     if N <> 0 then
     begin
         NewPath := RightStr(CmdLine, Length(CmdLine)-N);
         {$I-}
         Chdir(NewPath);
         IR := IOresult;
         {$I+}
         if IR <>0 then
         begin
            if (Ir=3) or (ir=123) then
                if ir=3 then writeln('?Path not found')
                else writeln('?Illegal path nane')
             else
                writeln('?Chdir fails, err ',IR);
         end;

     end;
end;

Procedure ListDir;
Begin
      Writeln; Writeln('** Stub procedure listdir'); writeln;


end;

Procedure ChangeDisk;
Begin
    Writeln; Writeln('** Stub procedure ChangeDisk'); writeln;


end;

procedure Menu;
Begin
    Writeln('  Program Menu');
    Writeln('  To use a command, type the word or the number');
    Writeln('  Then Press Enter');
    Writeln;
    writeln('   DIR (or) LS (or) 2 - list files in this directory,');
    writeln('                        in packed format');
    writeln('   CHOOSE (or) 9 - Display a list of files, allowing');
    writeln('                   any to be selected');
//    writeln('   CHDISK (or) DISK (followed by) LETTER - Change default');
//    writeln('                   diak to that letter (does not change');
//    writeln('                   current directory on that disk)');
    Writeln('   MENU (or) 99 - To see this menu again');
    Writeln('   TIME (or) 98 - See Time and date');
    writeln('   CD (or) CHDIR (or) 3 (followed by) NAME - ',
                        'Move to that directory');
    writeln;

    writeln;
    writeln('   Q (or) QUIT (or) EXIT (or) 0 - End program');
    writeln;
    writeln('If a file you want to count has the same name as a menu');
    writeln('option, press space first');

end;

Procedure Interactive;
Const
    BadMax = 3;
var
    SpacePos: integer;
    done:boolean;

    UC: AnsiString;

begin
   Done := FALSE;
   BadCount := 0;

   writeln('Welcome to Interactive mode.');
   Writeln('Here you will be able to pick specific files to list.');
   writeln('These are the commands you cam use:');
   Menu;
   repeat
       Writeln('You are currently located at: ', UTF8Decode(GetCurrentDir));
       writeln;
       write('File name or menu option: ');
       readln(Cmdline);
       if LeftStr(Cmdline,1)=Space(1) then
       begin
           ProcessFile(CmdLine);
           Badcount := 0;
           continue;
       end;
       spacepos := Pos(' ',Cmdline);
       if spacepos =0 then        UC := Uppercase(Cmdline)
       else  UC := Uppercase(LeftStr(Cmdline,Spacepos-1));

       if  (UC='HELP') then
       begin
           help;
           Badcount :=0;
           continue;
       end ;        if (UC='Q') or (UC='QUIT')  or (UC='EXIT') OR (UC='0') then
       begin
           done := TRUE;
           Badcount :=0;
           continue;
       end ;
       if (UC='DIR') or (UC='LS') or (UC='2') then
       begin
           ListDir;
           badcount := 0;
           continue;
       end;
       if (UC='CHOOSE') or (UC='9') then
       begin
           Choose;
           badcount := 0;
           continue;
       end;
       if (UC='CHDIR') or (UC='CD') then
       begin
           ChangeDir;
           badcount := 0;
           continue;
       end;
       if (UC='XYZZY') then
       begin
           Writeln;
           writeln('Nothing happens.');
           writeln;
           badcount := 0;
           continue;
       end;

  {     if (UC='CHDISK') or (UC='DISK') then
       begin
           ChangeDisk;
           badcount := 0;
           continue;
       end;   }
       if (UC='MENU') or (UC='99') then
       begin
           Menu;
           badcount := 0;
           continue;
       end;
       if (UC='TIME') or (UC='98') then
       begin
           GetLocalTime(TimeNow);
           Writeln(CTS(TimeNow));
           BadCount := 0;
           Continue;
       end;


        if UC<>'' then writeLN(' Huh?');
        Badcount := Badcount+1;
        if BADCount > BadMax then
        begin
            Writeln('If you are having trouble, type HELP or MENU ',
                    'and press ENTER.');
            writeln;
            BadCount := 0
        end;
   Until Done;
   DidSomething := TRUE;
end;


{$R *.res}

begin

{$IFDEF AUTOVersion}
    FileVerInfo:=TFileVersionInfo.Create(nil);
{$ENDIF}
    Starttime.Year:=0; EndTime.Year:=0;    // eliminate uninitialized warning
    GetLocalTime(StartTime);
    Writeln('Line Count - count lines in a file or files');
    Writeln('Version ',Version,' ',Copyright);
    Write('Good ');
    If StartTime.Hour <12 then
        Write('morning')
    else  if StartTime.Hour <18 then
        Write('afternoon')
    else
        Write('evening');
    writeln(', it is now ', CTS(StartTime));
    Writeln;

    Param1 := UPPERCase(Paramstr(1));
    if (Param1='/H') or
       (Param1='-H') or (Param1='--HELP') then
    begin
        Write('Usage: ',paramstr(0),'  filename [, filename...] ');
        Writeln('  -- list content of files ] ');
        Write('Usage: ',paramstr(0),'  /H | -h | -H | --help | --HELP ',
                      '  -- show this message and exit ');
        Write('Usage: ',paramstr(0),'  *no patameters, .i.e. nothing* ',
                      '-- enter interactive mode ');
        writeln;
        Writeln('Note: File names containing spaces must be "quoted like.this" ');
    end
    else
    if paramcount <1 then Interactive
    else
       BEGIN
       For I := 1 to paramcount do
          ProcessFile(ParamStr(I));
          DidSomething := TRUE;
       END;

    writeln;
    if didsomething then
    begin
        GetLocalTime(EndTime);
        writeln;
        writeln('Program ends, ', CTS(EndTime));
        Writeln('Elaspsed Time: ',Elapsed(StartTime,EndTime));
        Writeln;
    end;
    Writeln('Goodbye.');
    write('Press Enter to quit: ');
    readln;

end.

