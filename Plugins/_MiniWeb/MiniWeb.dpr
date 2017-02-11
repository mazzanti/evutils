program MiniWeb;

uses
  Forms,
  FormMiniWeb in 'FormMiniWeb.pas' {FMiniWeb};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMiniWeb, FMiniWeb);
  Application.Run;
end.
