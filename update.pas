// This opens a file, changes part of it, then closes. Not exactly what I nned
// but close. May also want a block move function

Program update;
const
    name      = 'source\common.pas';
    test      = 'VERSION_REV';
    zero      = Ord('0');

    Workdrive = 'X:';  // change this to the drive and
    Workdir   = '\';   // folder you edit in
    StageDrive= 'R:';  // change this to the drive and
    Stagedir  = '\';   // folder your local repository is in
    batchFile = 'bk.bat'; // newly created batch file to update repository

type

var
  F: File;
  buffer: TBuffer;
  ActualSize: Int64;
  I,L,
  OldVersion:Integer;
  CrLf: String[2];
  NewVersion:String[5];


  procedure readch;
  begin
      with Buffer do
      begin
          ch := #0;
          if inPos <= inSize then
          begin
              ch := PCharacter(Integer(inPtr) + inPos)^;
              if ch=#10 then
                 begin
                     Inc(line);
                     InPosition :=0;
                 end;
              Inc(inPos);
              Inc(InPosition);
          end
      else
         EndOfUnit := TRUE;
      end;
  end;

