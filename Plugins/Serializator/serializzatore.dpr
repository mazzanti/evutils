//{$DEFINE EXE}
{$IFDEF EXE}
program serializzatore;
{$ELSE}
library serializzatore;
{$ENDIF}

{$R 'iconaserializzatore.res' 'iconaserializzatore.rc'}
{$R 'lang.res' 'lang.rc'}

uses
  SysUtils,
  dialogs,
  Windows,
  Forms,
  Controls,
  Messages,
  sndkey32,
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  kutils in '..\Shared\kutils.pas',
  Definizioni in '..\Shared\Definizioni.pas',
  formserializator in 'formserializator.pas' {fserializator},
  formagreement in 'formagreement.pas' {FSAgreement};

const versioneprogramma: string = '3';
const nomeprogramma: string = 'Serializator';
const descrizioneprogramma:string = 'Autocompila i form di seriali delle applicazioni';
const idprogramma:string='SERIALIZER';
const nfunzioni=1;


function serializza(Parametri: PParametriFunzioneGenerica):integer;stdcall;
begin
  fsagreement.Visible:=true;
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

function evutilsinit(Parametri: PParametriInit): integer; stdcall;
begin
  with Parametri^ do
  begin
    notifica := evutilsNotifica(FNotifica);
    
  //QUA SI CREANO I FORMS
  fserializator := tfserializator.Create(nil);
  inizializza(fserializator);
  fsagreement := tfsagreement.Create(nil);
  inizializza(fsagreement);
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
        strcopy(nome, 'Serialize');
        strcopy(id, 'evserializator');
        address^ := @serializza;
        result := 1;
      end;
  else exit;
  end;
 end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
 begin 
   fsagreement.Close;
   fsagreement.Free;
   fserializator.Close;
   fserializator.Free;   
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
  Application.CreateForm(Tfsagreement, fsagreement);
  Application.CreateForm(Tfserializator, fserializator);
  Application.Run;
{$ENDIF}
end.
