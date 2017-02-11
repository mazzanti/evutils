program FileCleaner;

uses
  Forms,
  FormSettings in 'FormSettings.pas' {Form1},
  CleanerFunctions in 'CleanerFunctions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
