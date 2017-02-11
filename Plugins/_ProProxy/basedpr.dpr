//{$DEFINE EXE}
{$IFDEF EXE}
program CodiceFiscale;
{$ELSE}
library CodiceFiscale;
{$ENDIF}

{$R 'icona.res' 'icona.rc'}

uses
  Forms,
  sysutils,
  FormCodiceFiscale in 'FormCodiceFiscale.pas' {FCodFisc},
  CODFISCIMP in 'CODFISCIMP.pas',
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  evutilsLanguages in '..\Shared\evutilsLanguages.pas',
  Definizioni in '..\Shared\Definizioni.pas';

{$R *.res}

const versioneprogramma: string = '1.2';
const nomeprogramma: string = 'Codice Fiscale';

function mostracodfisc(Parametri: PParametriFunzioneGenerica):integer; stdcall;
begin
  FCodFisc.Show;
  result:=1;
end;

function evutilsquery(Parametri: PParametriQuery): integer; stdcall;
begin
  with Parametri^ do
  begin
    strcopy(nome, pchar(nomeprogramma));
    strcopy(versione, pchar(versioneprogramma));
  end;
  result := 1;
end;

function evutilsinit(Parametri: PParametriInit): integer; stdcall;
begin
  with Parametri^ do
  begin
    notifica := evutilsNotifica(FNotifica);

    funzioni^ := 1;
    language:=lang;

//QUA SI CREANO I FORMS

    FCodFisc := TFCodFisc.Create(nil);
    inizializza(FCodFisc);

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
          strcopy(nome, 'Calcola codice fiscale');
          strcopy(id, 'codfisc');
          address^ := @mostracodfisc;
          result := 1;
        end;
    else exit;
    end;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
 begin 
   FCodFisc.Close;
   FCodFisc.Free;
   result := 1; 
 end;

exports
  evutilsquery
  , evutilsinit
  , evutilsfunction
  , evutilsfree
  ;

begin
{$IFDEF EXE}
  Application.Initialize;
  Application.CreateForm(TFCodFisc, FCodFisc);
  Application.Run;
{$ENDIF}
end.
