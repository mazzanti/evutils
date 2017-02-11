//{$DEFINE EXE}
{$IFDEF EXE}
program MouseX;
{$ELSE}
library MouseX;
{$ENDIF}

{$R 'lang.res' 'lang.rc'}
{$R 'icona.res' 'icona.rc'}

uses
  SysUtils,
  Forms,
  FormMouseX in 'FormMouseX.pas' {FMouseX},
  Definizioni in '..\Shared\Definizioni.pas',
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  evutilsLanguages in '..\Shared\evutilsLanguages.pas';

{$R *.res}

const versioneprogramma: string = '1.0';
const nomeprogramma: string = 'MouseX';
const descrizioneprogramma:string = 'Fornisce funzionalità avanzate al puntatore del mouse';
const idprogramma:string='MOUSEX';
const nfunzioni=2;

function onoff(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
//non più utilizzata sta funzione..
  if abilitato then
  begin
    parametri.MenuName := 'On';
  end
  else
  begin
    parametri.MenuName := 'Off';
  end;
  abilitato := not abilitato;
  parametri.ChangeMenuName := true;
  FMouseX.cambiastato();
  result := 1;
end;

function tremuloonoff(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  if tremulo then
  begin
    parametri.MenuName := 'Tremulo On';
  end
  else
  begin
    parametri.MenuName := 'Tremulo Off';
  end;
  tremulo := not tremulo;
  parametri.ChangeMenuName := true;
  with FMouseX do
  begin
    ttremulo.Interval := strtoint(txtvelocita.Text);
    fattore := strtoint(txtfattore.Text);
  end;
  FMouseX.cambiatremulo();
  result := 1;
end;

function tremulo(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  FMouseX.Show;
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
    language := lang;

//QUA SI CREANO I FORMS

    FMouseX := TFMouseX.Create(nil);
    inizializza(FMouseX);
    result := 1;
  end;
end;


function evutilsfunction(Parametri: PParametriFunction): integer; stdcall;
begin
  result := 1;
  with Parametri^ do
  begin
    case numero of
//      1: begin
//          strcopy(nome, 'On');
//          strcopy(id, 'mousexonoff');
//          address^ := @onoff;
//        end;
      2: begin
          strcopy(nome, 'Tremulo On');
          strcopy(id, 'mousextremuloonoff');
          address^ := @tremuloonoff;
        end;
      1: begin
          strcopy(nome, 'MouseX...');
          strcopy(id, 'mousexx');
          address^ := @tremulo;
        end;
    else result := 0;
    end;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
begin
  FMouseX.Close;
  FMouseX.Free;
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
  Application.CreateForm(TFMouseX, FMouseX);
  Application.Run;
{$ENDIF}
end.

