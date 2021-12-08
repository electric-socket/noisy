program blockread1;

{$mode objfpc}{$H+}
{$UNDEF Debug}

uses
   SysUtils;

Const
    BufferSize=10000;

type
    Pcharacter = ^Char;

Var
    InPtr: PCharacter;
    BB,
    NotStarted,
    EndofFile: Boolean;
    loopcount,
    FM,
    IR,
    Actualsize,
    Size,
    CurrentLineNum,
    inPosition,
    LineSize,
    K,
    I: longint;
    Line,
    fn: unicodestring;
    Ch:Char;
    f:file;

    procedure readline;
        Procedure Get;
        begin
            if actualsize>BufferSize then
            begin
                BlockRead(F, inPtr^, buffersize, ActualSize);
                inposition := 0;
            end;
            if actualsize = 0 then
            begin
                EndOfFile := true;
                exit;
            end;
            ch := PCharacter(Int64(inPtr + inPosition))^;
            Inc(InPosition);
            Inc(LineSize);
        end;

begin
    Line :='';
    LineSize := 0;
    repeat
        ch :=#0;
        while not EndOfFile do
        begin
            Get;
            if (ch=#13)  then continue;
            if (ch=#10) then exit;
            Line := Line+Ch;
        end;
        if actualsize = 0 then   // Out of records
        begin
            EndOfFile := TRUE;
            close(f);
            exit;
        end;
    until true;
end;



begin
    Writeln('Current directory ',GetCurrentDir);

    getmem(inPtr,buffersize);
    FM := filemode;
    FileMode := 0; // force read-only in case file is read only
    repeat
        write('Enter file name: ');
        readln(fn);
        assign(F,fn);
        NotStarted :=true;
        {$I-} reset(F,1); {$I+}
        IR := IOResult;
        if IR = 0 then break;
        writeln('Error ',IR);
    until false;
    FileMode := FM;
    Size := FileSize(F);
//    Writeln('File Size: ',Size);
    if size<>0 then // file is not empty
    begin
        ActualSize := 0;
        CurrentLineNum := 1;
        LoopCount :=1 ;

        BlockRead(F, inPtr^, buffersize, ActualSize); // prime the pump

        inPosition := 0;
        NotStarted := False;
        EndofFile := false;

        repeat
            readline;
            if endoffile then break;

            // process record here

            Writeln(CurrentLineNum:6,' ',Line);
            Inc(CurrentLineNum);
        until EndofFile or (actualsize=0);
    end;
    NotStarted := true;
    freemem(InPtr);
    writeln;
    write('Press return: ');
    readln;

end.

