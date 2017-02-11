program eVutils;





{$R 'resources\lang.res' 'resources\lang.rc'}

uses
  Forms,
  MainCore in 'MainCore.pas' {fevutils},
  evutilsBaloon in 'Plugins\Shared\evutilsBaloon.pas',
  Definizioni in 'Plugins\Shared\Definizioni.pas',
  PopupFunzioni in 'PopupFunzioni.pas' {FPopoupFunzioni},
  FormSettings in 'FormSettings.pas' {FSettings},
  MiniFMOD in 'Plugins\Shared\MiniFMOD.pas',
  eVupengl in 'eVupengl.pas',
  FormWizard in 'FormWizard.pas' {fwizard},
  kutils in 'Plugins\Shared\kutils.pas',
  Plugin in 'Plugin.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'eVutils';
  Application.CreateForm(Tfevutils, fevutils);
  Application.CreateForm(Tfwizard, fwizard);
  Application.CreateForm(TFPopoupFunzioni, FPopoupFunzioni);
  Application.CreateForm(TFSettings, FSettings);
  //  Application.ShowMainForm:=false;
  Application.Run;
end.
