library execparams;

{$R 'iconaexecparams.res' 'iconaexecparams.rc'}
{$R 'lang.res' 'lang.rc'}

uses
  Forms,
  Windows,
  Controls,
  SysUtils,
  formexecparams in 'formexecparams.pas' {fexecparams},
  Definizioni in '..\Shared\Definizioni.pas',
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  evutilsLanguages in '..\Shared\evutilsLanguages.pas';

const versioneprogramma: string = '2';
const nomeprogramma: string = 'Execparams';
const descrizioneprogramma:string = 'Esegue applicazioni specificando la linea di comando';
const idprogramma:string='EXCPAR';
const nfunzioni=1;

function paramsex(Parametri: PParametriFunzioneGenerica):integer; stdcall;
begin
  fexecparams.Visible:=true;
  result := 1;
end;

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

function evutilsinit(Parametri:PParametriInit): integer; stdcall;
begin
with Parametri^ do
  begin
    notifica := evutilsNotifica(FNotifica);

  //QUA SI CREANO I FORMS
  fexecparams := tfexecparams.Create(nil);
  inizializza(fexecparams);
  result := 1;
  end;
end;

function evutilsfunction(Parametri:PParametriFunction): integer;stdcall;
begin
  result := 0;
  with Parametri^ do
  begin
    case numero of
    1: begin
        strcopy(nome, 'Params executer');
        strcopy(id, 'evexecparams');
        address^ := @paramsex;
        result := 1;
      end;
  else exit;
  end;
 end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
 begin 
   fexecparams.Close;
   fexecparams.Free;
   result := 1; 
 end;

exports
  evutilsquery
  , evutilsinit
  , evutilsfunction
  , evutilsfree
  ;

begin

end.
