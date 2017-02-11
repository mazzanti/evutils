//{$DEFINE EXE}
{$IFDEF EXE}
program Poppy;
{$ELSE}
library Poppy;
{$ENDIF}

{$R 'icona.res' 'icona.rc'}

uses
  Forms,
  sysutils,
  MainPoppy in 'MainPoppy.pas' {FPop},
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  evutilsLanguages in '..\Shared\evutilsLanguages.pas',
  Definizioni in '..\Shared\Definizioni.pas',
  OverbyteIcsMailRcv2 in 'OverbyteIcsMailRcv2.pas';

{$R *.res}

const versioneprogramma: string = '1';
const nomeprogramma: string = 'Poppy';

function mostrapoppy(Parametri: PParametriFunzioneGenerica):integer; stdcall;
begin
  FPop.Show;
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

    FPop := TFPop.Create(nil);
    inizializza(FPop);

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
          strcopy(nome, 'Check Mail');
          strcopy(id, 'checkmail');
          address^ := @mostrapoppy;
          result := 1;
        end;
      2: begin
          strcopy(nome, 'Pop Cleaner');
          strcopy(id, 'popclean');
          address^ := @mostrapoppy;
          result := 1;
        end;
    else exit;
    end;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
 begin 
   FPop.Close;
   FPop.Free;
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
