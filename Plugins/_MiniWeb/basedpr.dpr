//{$DEFINE EXE}
{$IFDEF EXE}
program autoshutdown;
{$ELSE}
library autoshutdown;
{$ENDIF}

{$R 'lang.res' 'lang.rc'}
{$R 'icona.res' 'icona.rc'}

uses
  SysUtils,
  Forms,
  FormAutoShut in 'FormAutoShut.pas' {Fautoshutdown},
  FormAlert in 'FormAlert.pas' {FAlert},
  Definizioni in '..\Shared\Definizioni.pas',
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  evutilsLanguages in '..\Shared\evutilsLanguages.pas',
  dutils in '..\Shared\dutils.pas',
  WinShutty in 'WinShutty.pas';

{$R *.res}

const versioneprogramma: string = '1.0';
const nomeprogramma: string = 'AutoShutdownX';

function mostrashutty(Parametri: PParametriFunzioneGenerica):integer; stdcall;
begin
  Fautoshutdown.Show;
  result:=1;
end;

function evutilsinit(Parametri: PParametriInit): integer; stdcall;
begin
  with Parametri^ do
  begin
    notifica := evutilsNotifica(FNotifica);
    strcopy(nome, pchar(nomeprogramma));
    strcopy(versione, pchar(versioneprogramma));

    funzioni^ := 1;
    language:=lang;

//QUA SI CREANO I FORMS

    Fautoshutdown := TFautoshutdown.Create(nil);
    inizializza(Fautoshutdown);
    FAlert := TFAlert.Create(nil);
    inizializza(FAlert);

    result := 1;
  end;
end;


function evutilsfunction(Parametri: PParametriFunction): integer; stdcall;
begin
  result := 0;
  with Parametri^ do
  begin
    case numero of
      1: begin
          strcopy(nome, 'Autoshutdown');
          strcopy(id, 'autoshutty');
          address^ := @mostrashutty;
          result := 1;
        end;
    else exit;
    end;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
 begin 
   Fautoshutdown.Close;
   Fautoshutdown.Free;
   FAlert.Close;
   FAlert.Free;
   result := 1; 
 end;

exports
  evutilsinit
  , evutilsfunction
  , evutilsfree
  ;

begin
{$IFDEF EXE}
  Application.Initialize;
  Application.CreateForm(TFautoshutdown, Fautoshutdown);
  Application.Run;
{$ENDIF}
end.
