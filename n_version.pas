{$I NoisyPrefixCode.inc}

// Provide version and copyright, either extracting it from the
// executable file or from our own values

// Version 0.0.1

unit N_Version;

{$mode ObjFPC}{$H+}

interface

{$IFDEF AUTOVersion}
uses

   // FPC 3.0 fileinfo reads exe resources as long as you register the appropriate units
     fileinfo
   , winpeimagereader {need this for reading exe info}
   , elfreader {needed for reading ELF executables}
   , machoreader {needed for reading MACH-O executables}
   ,
   SysUtils;

Function Copyright:AnsiString;
{$ELSE}
Const

    CopyRight = 'Copyright 2021 Paul Robinson';

    VERSION_MAJOR             = 0;
    VERSION_RELEASE           = 0;
    VERSION_PATCH             = 1;


// note, the folowing is auto changed when
// PROGRAM UPD does an auto-upddate
// and it Is be passed as a string on start.
    VERSION_REV               = 0;

    VERSION_FULL              = VERSION_MAJOR*100000+
                                VERSION_RELEASE *10000+
                                VERSION_PATCH*100+
                                VERSION_REV;
{$ENDIF}

Function Version:AnsiString;



implementation




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

Function Version:AnsiString;
begin
  {$IFDEF AUTOVersion}
  try
    FileVerInfo.ReadFileInfo;
    Result:= FileVerInfo.VersionStrings.Values['FileVersion'];
  finally
    FileVerInfo.Free;
  end;
  {$ELSE}
    Result := IntToStr(VERSION_MAJOR)+'.'+
              IntToStr(VERSION_RELEASE)+'.'+
              IntToStr(VERSION_PATCH)+'.'+
              IntToStr(VERSION_REV);

  {$ENDIF}
end;

end.

