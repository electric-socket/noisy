program lc;

uses SysUtils;

var
     Param1: string;
     I: Integer;


Procedure ProcessFile(Const FileName: UnicodeString);
Begin

end;

Procedure Interactive;
begin

end;


begin


    Writeln('Line Count - count lines in a file or files');
    Writeln('Copyright 2020, 2021 Paul Robinson');

    Param1 := UPPERCase(Paramstr(1));
    if (Param1='/H') or
       (Param1='-H') or (Param1='--Help') then
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
       For I := 1 to paramcount do
          ProcessFile(ParamStr(I));

    writeln;
    write('Press Enter to quit: ');
    readln;

end.

