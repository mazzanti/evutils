//{$DEFINE EXE}
{$IFDEF EXE}
program evJumpJump;
{$ELSE}
library evJumpJump;
{$ENDIF}

{$R 'icona.res' 'icona.rc'}

uses
  Forms,
  SysUtils,
  JJMain in 'JJMain.pas' {FJumpJump},
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  evutilsLanguages in '..\Shared\evutilsLanguages.pas',
  Definizioni in '..\Shared\Definizioni.pas',
  JJGetChar in 'JJGetChar.pas' {FJJGetChar},
  sndkey32 in '..\Shared\sndkey32.pas';

{$R *.res}

const versioneprogramma: string = '1';
const nomeprogramma: string = 'JumpJump';
const descrizioneprogramma:string = 'JumpJump for Half-Life';
const idprogramma:string='JUMPJUMP';
const nfunzioni=2;

function jjonoff(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  if jumpy then
  begin
    parametri.MenuName := 'JumpJump On';
  end
  else
  begin
    parametri.MenuName := 'JumpJump Off';
  end;
  jumpy := not jumpy;
  parametri.ChangeMenuName := true;
  FJumpJump.cambiajumpy();
  result := 1;
end;

function mostrajumpjump(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  FJumpJump.Show;
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

    FJumpJump := TFJumpJump.Create(nil);
    FJJGetChar := TFJJGetChar.Create(nil);
    inizializza(FJumpJump);
    inizializza(FJJGetChar);
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
          strcopy(nome, 'JumpJump On');
          strcopy(id, 'evjumpjumponoff');
          address^ := @jjonoff;
          result := 1;
        end;
      2: begin
          strcopy(nome, 'Settings');
          strcopy(id, 'evjumpjump');
          address^ := @mostrajumpjump;
          result := 1;
        end;
    else exit;
    end;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
begin
  FJumpJump.Close;
  FJumpJump.Free;
  FJJGetChar.Close;
  FJJGetChar.Free;
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
  Application.CreateForm(TFJumpJump, FJumpJump);
  Application.CreateForm(TFJJGetChar, FJJGetChar);
  Application.Run;
{$ENDIF}
end.

