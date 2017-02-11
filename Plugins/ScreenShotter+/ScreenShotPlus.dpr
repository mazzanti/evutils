library ScreenShotPlus;

{$R 'icona.res' 'icona.rc'}
{$R 'lang.res' 'lang.rc'}

uses
  Forms,
  extctrls,
  sysutils,
  windows,
  controls,
  FormMain in 'FormMain.pas' {Main},
  FastBmp in 'FastBmp.pas',
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  kutils in '..\Shared\kutils.pas',
  Definizioni in '..\Shared\Definizioni.pas',
  pngextra in 'lib\pngextra.pas',
  pngimage in 'lib\pngimage.pas',
  pnglang in 'lib\pnglang.pas',
  zlibpas in 'lib\zlibpas.pas',
  dutils in '..\Shared\dutils.pas',
  evutilslanguages in '..\Shared\evutilslanguages.pas',
  Plugin in '..\..\Plugin.pas';

{$R *.res}


const versioneprogramma: string = '1.2';
const nomeprogramma: string = 'ScreenShotter+';
const descrizioneprogramma:string = 'Cattura lo schermo o una singola finestra e salva il file nel formato scelto dall''utente';
const idprogramma:string='SCRPLUS';
const nfunzioni=3;

function screencompleto(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  main.DoScreenShot(completo);
  result := 1;
end;

function screenfinestra(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  if not Parametri.FromHotkey then
    sleep(3000);
  main.DoScreenShot(finestra);
  result := 1;
end;

function settings(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  if not main.Visible then
    main.Visible := true;
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

    path := Working_dir;
    language:=lang;

    main := TMain.Create(nil);
    inizializza(main);
  end;
  result := 1;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
begin
  main.Close;
  main.Free;
  result := 1;
end;

function evutilsfunction(Parametri: PParametriFunction): integer; stdcall;
begin
  result := 1;
  with Parametri^ do
  begin
    case numero of
      1: begin
          strcopy(nome, 'Screen Completo');
          strcopy(id, 'scrplusfull');
          address^ := @screencompleto;
        end;
      2: begin
          strcopy(nome, 'Screen Finestra');
          strcopy(id, 'scrplusparz');
          address^ := @screenfinestra;
        end;
      3: begin
          strcopy(nome, 'Impostazioni');
          strcopy(id, 'scrplusimp');
          address^ := @settings;
        end;
    else
      result := 0;
    end;
  end;
end;


exports
  evutilsquery
  , evutilsinit
  , evutilsfunction
  , evutilsfree
  ;

begin

end.

