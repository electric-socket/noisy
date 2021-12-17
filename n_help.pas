unit N_Help;

{$mode ObjFPC}{$H+}

interface

uses
   SysUtils;

   Procedure Help;

implementation

Procedure Help;
const
  var
      LineContinuation := Space(10);
    TextPrefix := Space(20);
  //                 ',,,,,,,,,1.......2'
  TextPrefix       = '                  '; // to balance help stmts
  LineContinuation = '          ';         // separate explanation from command

Begin
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
End;


end.

