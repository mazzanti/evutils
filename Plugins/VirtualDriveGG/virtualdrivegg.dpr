library virtualdrivegg;

{$R 'icona.res' 'icona.rc'}
{$R 'lang.res' 'lang.rc'}

uses
  SysUtils,
  Forms,
  FMainVD in 'FMainVD.pas' {Fvd},
  Subst in 'Subst.pas',
  dutils in '..\Shared\dutils.pas',
  Definizioni in '..\Shared\Definizioni.pas',
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  evutilsLanguages in '..\Shared\evutilsLanguages.pas';

{$R *.res}

const versioneprogramma: string = '1.0';
const nomeprogramma: string = 'VirtualDriveGG';
const descrizioneprogramma:string = 'Gestisce directory come device di sistema virtuali';
const idprogramma:string='VDRIVE';
const nfunzioni=1;

function mostravdgg(Parametri: PParametriFunzioneGenerica):integer; stdcall;
begin
  Fvd.Show;
  result:=1;
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
    
    path := Working_dir;
    language:=lang;

//QUA SI CREANO I FORMS

    Fvd := TFvd.Create(nil);
    inizializza(Fvd);

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
          strcopy(nome, 'VirtualDrives Management');
          strcopy(id, 'virtualdrivegg');
          address^ := @mostravdgg;
          result := 1;
        end;
    else exit;
    end;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
 begin 
   Fvd.Close;
   Fvd.Free;
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
