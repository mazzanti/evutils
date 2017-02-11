 //====== Copyright 2001-2006, evilstev3n ===========
 //
 // Purpose:
 //
 //==================================================
//{$DEFINE EXE}
{$IFDEF EXE}
program evPKilla;
{$ELSE}
library evPKilla;
{$ENDIF}

{$R 'lang.res' 'lang.rc'}
{$R 'icona.res' 'icona.rc'}

uses
  Forms, SysUtils, TLHelp32, Windows,
  Definizioni in '..\Shared\Definizioni.pas',
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  evutilsLanguages in '..\Shared\evutilsLanguages.pas',
  PKillaFunc in 'PKillaFunc.pas' {FPKilla};

{$R *.res}

const versioneprogramma: string = '2';
const nomeprogramma: string = 'Process Killer';
const descrizioneprogramma:string = 'Termina una lista di processi definiti dall''utente';
const idprogramma:string='PKILL';
const nfunzioni=4;

function killa(Parametri: PParametriFunzioneGenerica): integer; stdcall;
var
  wnd: cardinal;
  pid: cardinal;
  ph: thandle;
  txt1: array[0..255] of char;
begin
  result := 0;
  if not parametri.FromHotkey then
    sleep(3000);
  wnd := GetForegroundWindow; // get active window
  GetWindowText(wnd, @txt1, sizeof(txt1)); // get it's caption
  if (uppercase(txt1) = '') or (uppercase(txt1) = 'FEVUTILS') then exit;
  GetWindowThreadProcessId(wnd, pid); // get process id
  ph := OpenProcess(1, BOOL(0), pid);
  TerminateProcess(Ph, 0);
  sleep(1000);
  result := 1;
end;

function mostrapk(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  FPKilla.Show;
  result := 1;
end;

function killaquesti(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  FPKilla.beginkillthis;
  result := 1;
end;

function killaescquesti(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  FPKilla.beginkillexcludethis;
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

    FPKilla := TFPKilla.Create(nil);
    inizializza(FPKilla);

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
          strcopy(nome, 'Main');
          strcopy(id, 'evpkill');
          address^ := @mostrapk;
          result := 1;
        end;
      2: begin
          strcopy(nome, 'Killa elencati');
          strcopy(id, 'evpkillthis');
          address^ := @killaquesti;
          result := 1;
        end;
      3: begin
          strcopy(nome, 'Killa tranne elencati');
          strcopy(id, 'evpkillescthis');
          address^ := @killaescquesti;
          result := 1;
        end;
      4: begin
          strcopy(nome, 'Killa applicazione corrente');
          strcopy(id, 'killcurrentapp');
          address^ := @killa;
          result := 1;
        end;
    else exit;
    end;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
begin
  FPKilla.Close;
  FPKilla.Free;
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
  Application.CreateForm(TFPKilla, FPKilla);
  Application.Run;
{$ENDIF}
end.

