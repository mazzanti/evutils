program Databaset;

uses
  Forms,
  FormDatabaset in 'FormDatabaset.pas' {FDatabase},
  evutilsDatabase in 'evutilsDatabase.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFDatabase, FDatabase);
  Application.Run;
end.
