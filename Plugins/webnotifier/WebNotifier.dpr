library WebNotifier;

{$R 'icona.res' 'icona.rc'}

uses
  controls,
  windows,
  sysutils,
  Forms,
  Unit1 in 'Unit1.pas' {Main},
  About in 'About.pas' {AboutBox},
  DOMCore in 'moduli\DOMCore.pas',
  Entities in 'moduli\Entities.pas',
  Formatter in 'moduli\Formatter.pas',
  HTMLParser in 'moduli\HTMLParser.pas',
  HtmlReader in 'moduli\HtmlReader.pas',
  HtmlTags in 'moduli\HtmlTags.pas',
  WStrings in 'moduli\WStrings.pas',
  FormFiltri in 'FormFiltri.pas' {FFiltri},
  evutilsBaloon in '..\Shared\evutilsBaloon.pas',
  evutilsFrmInit in '..\Shared\evutilsFrmInit.pas',
  kutils in '..\Shared\kutils.pas',
  Definizioni in '..\Shared\Definizioni.pas';

const versioneprogramma: string = '2.0 beta 7';
const nomeprogramma: string = 'Web Notifier';
const descrizioneprogramma:string = 'Monitora i siti preferiti e avvisa l''utente in caso di modifiche';
const idprogramma:string='WEBNOT';
const nfunzioni=4;

function gestionepagine(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  if not main.Visible then
    main.GestioneClick(nil);
  result := 1;
end;

function frequenza(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  main.Tempo1Click(nil);
  result := 1;
end;

function check(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  main.chtimTimer(nil);
  result := 1;
end;

function About(Parametri: PParametriFunzioneGenerica): integer; stdcall;
begin
  main.About1click(nil);
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
    
    path := working_dir;

    main := TMain.Create(nil);
    inizializza(main);
    FFiltri := TFFiltri.Create(main);
    inizializza(FFiltri);
    AboutBox := TAboutBox.Create(main);
    inizializza(AboutBox);
    result := 1;
  end;
end;

function evutilsfree(Parametri: PParametriFree): integer; stdcall;
begin
  main.Close;
  FFiltri.Close;
  AboutBox.Close;
  FFiltri.Free;
  AboutBox.Free;
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
          strcopy(nome, 'Check');
          strcopy(id, 'webnttrcheck');
          address^ := @check;
        end;
      2: begin
          strcopy(nome, 'Gestione Pagine');
          strcopy(id, 'webntrgestpagine');
          address^ := @gestionepagine;
        end;
      3: begin
          strcopy(nome, 'Frequenza Controllo');
          strcopy(id, 'webnttrfreq');
          address^ := @frequenza;
        end;
      4: begin
          strcopy(nome, 'About');
          strcopy(id, 'webnttrabout');
          address^ := @About;
        end;
    else result := 0;
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

{
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TFFiltri, FFiltri);
  Application.ShowMainForm := false;
  Application.Run;
}

end.

