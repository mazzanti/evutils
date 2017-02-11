library MultiClipBoard;

{$R 'icona.res' 'icona.rc'}

uses
  Forms,
  windows,
  sysutils,
  Main in 'Main.pas' {FMain},
  Definizioni in '..\Shared\Definizioni.pas',
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  kutils in '..\Shared\kutils.pas';

{$R *.res}

const versioneprogramma: string = '1.1';
const nomeprogramma: string = 'MultiClipBoard';
const descrizioneprogramma:string = 'Consente di richiamare le ultime cose inserite negli appunti.';
const idprogramma:string='MULTICLIP';
const nfunzioni=1;

function MostraAppunti(Parametri: PParametriFunzioneGenerica): integer; stdcall;
const
  scostamento=15;
var
  p: tpoint;
  posizione: tposizioni;
begin
  getcursorpos(p);

  posizione := bassodx;

  if p.X < screen.Width div 2 then inc(posizione);
  if p.Y < screen.Height div 2 then inc(posizione, 2);

  FMain.posizione := posizione;

  case posizione of
    bassodx:
      begin
        FMain.Left := p.X - fmain.Width + scostamento;
        FMain.Top := p.Y - fmain.Height + scostamento;
      end;
    bassosx:
      begin
        FMain.Left := p.X - scostamento;
        FMain.Top := p.Y - fmain.Height + scostamento;
      end;
    altodx:
      begin
        FMain.Left := p.X - fmain.Width + scostamento;
        FMain.Top := p.Y - scostamento;
      end;
    altosx:
      begin
        FMain.Left := p.X - scostamento;
        FMain.Top := p.Y - scostamento;
      end;
  end;

  FMain.visible := true;
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
    funzioni^ := nfunzioni;
  end;
  result := 1;
end;

function evutilsinit(Parametri: PParametriInit): integer; stdcall;
begin
  with Parametri^ do
  begin
    notifica := evutilsNotifica(FNotifica);

    path := Working_dir;

//QUA SI CREANO I FORMS

    FMain := TFmain.Create(nil);
    inizializza(FMain);

    result := 1;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
begin
  fmain.Close;
  fmain.Free;
  result:=1;
end;

function evutilsfunction(Parametri: PParametriFunction): integer; stdcall;
begin
  result := 0;
  with Parametri^ do
  begin
    case numero of
      1: begin
          strcopy(nome, 'Mostra Appunti');
          strcopy(id, 'multiclipappunti');
          address^ := @MostraAppunti;
          result := 1;
        end;
    else exit;
    end;
  end;
end;

exports
  evutilsquery
  , evutilsinit
  , evutilsfunction
  ,evutilsfree
  ;




begin
{
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
}
end.

