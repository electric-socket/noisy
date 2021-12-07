
uses windows,sysutils;

const
    Months: array[1..12] of string[9]=
         ('January','February','March',   'April',   'May','     June',
          'July',    'August', 'September','October','November', 'Decenber');
    Days: Array[0..6] of string[9]=
          ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
    RadixString: Array[0..36] of char=('0','1','2','3','4','5','6','7','8','9',
                          'A','B','C','D','E','F','G','H','I','J',
                          'K','L','M','N','O','P','Q','R','S','T',
                          'U','V','W','X','Y','Z',
                          'A');    // extra is to trap 'fall-offs'


var
   StartTime,
   EndTime: SystemTime;

  TimeString,
  TimeString1: String;
  H,M,S,MS: integer;



  // Paul Robinson 2020-11-08 - My own version of
  // InttoStr, but works for any radix, e.g. 2, 8, 10, 16,
  // or any others up to 36. This only works for
  // non-negative numbers.
  Function Radix( N:LongInt; theRadix:LongInt):string;
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


  Function Plural(N:LongInt; Plu:String; Sng: String): string;
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
      
GetLocalTime(StartTime);
      TimeString := Days[StartTime.dayOfWeek]+' '+Months[StartTime.month]+
                  ' '+IntToStr(StartTime.day)+', '+IntToStr(StartTime.year)+
                  ' '+IntToStr(StartTime.Hour)+':'+I2(StartTime.Minute)+
                  ':'+I2(StartTime.Second);
       writeln('Started: ',TimeString);
       writeln;
       write('Wait a while, then press Enter: ');
       readln;
       GetLocalTime(EndTime);
       TimeString :=  Days[EndTime.dayOfWeek]+' '+Months[EndTime.month]+
                  ' '+IntToStr(EndTime.day)+', '+IntToStr(EndTime.year)+
                  ' '+IntToStr(EndTime.Hour)+':'+I2(EndTime.Minute)+
                  ':'+I2(EndTime.Second);
        Writeln('Process ended: ',TimeString);

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






