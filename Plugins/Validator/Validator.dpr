//{$DEFINE EXE}
{$IFDEF EXE}
program Validator;
{$ELSE}
library Validator;
{$ENDIF}

{$R 'lang.res' 'lang.rc'}
{$R 'icona.res' 'icona.rc'}

uses
  SysUtils,
  Forms,
  FormValidator in 'FormValidator.pas' {FValidator},
  Definizioni in '..\Shared\Definizioni.pas',
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas';

{$R *.res}

const versioneprogramma: string = '1.0';
const nomeprogramma: string = 'Validator';
const descrizioneprogramma:string = 'Contiene funzioni per verificare l''autenticità di partite iva e codici fiscali';
const idprogramma:string='VALIDATOR';
const nfunzioni=1;


function evutilsquery(Parametri: PParametriQuery): integer; stdcall;
begin
  with Parametri^ do
  begin
    strcopy(id, pchar(idprogramma));
    strcopy(nome, pchar(nomeprogramma));
    strcopy(versione, pchar(versioneprogramma));
    //if lang = 0 then
    strcopy(descrizione, pchar(descrizioneprogramma));
	funzioni^:=nfunzioni;
  end;
  result := 1;
end;

function mostravalidator(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  FValidator.Show;
  result := 1;
end;

function evutilsinit(Parametri: PParametriInit): integer; stdcall;
begin
  with Parametri^ do
  begin
    notifica := evutilsNotifica(FNotifica);
    
//QUA SI CREANO I FORMS
    FValidator := TFValidator.Create(nil);
    inizializza(FValidator);

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
          strcopy(nome, 'Controlla P.IVA e C.F.');
          strcopy(id, 'validator');
          address^ := @mostravalidator;
          result := 1;
        end;
    else exit;
    end;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
begin
  FValidator.Close;
  FValidator.Free;
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
  Application.CreateForm(TFValidator, FValidator);
  Application.Run;
{$ENDIF}

end.

