//{$DEFINE EXE}
{$IFDEF EXE}
program WindowSpecialist;
{$ELSE}
library WindowSpecialist;
{$ENDIF}

{$R 'lang.res' 'lang.rc'}
{$R 'icona.res' 'icona.rc'}


uses
  SysUtils,
  Forms,
  MainWS in 'MainWS.pas' {FWindowSpecialist},
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  evutilsLanguages in '..\Shared\evutilsLanguages.pas',
  Definizioni in '..\Shared\Definizioni.pas';

{$R *.res}

const versioneprogramma: string = '1';
const nomeprogramma: string = 'WindowSpecialist';

function mostraws(Parametri: PParametriFunzioneGenerica):integer; stdcall;
begin
  FWindowSpecialist.Show;
  result:=1;
end;

function wssetta(Parametri: PParametriFunzioneGenerica):integer; stdcall;
begin
  FWindowSpecialist.settaposizioni;
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

    funzioni^ := 2;
    language:=lang;

//QUA SI CREANO I FORMS

    FWindowSpecialist := TFWindowSpecialist.Create(nil);
    inizializza(FWindowSpecialist);

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
          strcopy(nome, 'Setta posizioni');
          strcopy(id, 'wssettapos');
          address^ := @wssetta;
          result := 1;
        end;
      2: begin
          strcopy(nome, 'Main');
          strcopy(id, 'wsmain');
          address^ := @mostraws;
          result := 1;
        end;
    else exit;
    end;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
 begin 
   FWindowSpecialist.Close;
   FWindowSpecialist.Free;
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
  Application.CreateForm(TFWindowSpecialist, FWindowSpecialist);
  Application.Run;
{$ENDIF}
end.
