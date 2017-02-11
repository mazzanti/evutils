unit FormSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, ImgList, XPMan, kutils, definizioni,
  plugin, inifiles, evupengl, MiniFMOD;

type
  Tfsettings = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ImageList1: TImageList;
    Label4: TLabel;
    Shape1: TShape;
    CKAutostart: TCheckBox;
    Label5: TLabel;
    Shape2: TShape;
    CBLingua: TComboBox;
    ListaSettings: TTreeView;
    TabSheet4: TTabSheet;
    PanelSotto: TPanel;
    Applica: TButton;
    Annulla: TButton;
    TabSheet5: TTabSheet;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Shape3: TShape;
    RadioPopup: TRadioButton;
    RadioListaEsterna: TRadioButton;
    Label9: TLabel;
    Shape4: TShape;
    TRTrasparenza: TTrackBar;
    Label10: TLabel;
    Label11: TLabel;
    ComboBox2: TComboBox;
    ScrPlugins: TScrollBox;
    Shape5: TShape;
    TabSheet6: TTabSheet;
    Label12: TLabel;
    ScrollBox1: TScrollBox;
    Shape6: TShape;
    SCRHotkeys: TScrollBox;
    PanelAbout: TPanel;
    Timer1: TTimer;
    CKsemprevisibile: TCheckBox;
    Wizard: TButton;
    procedure WizardClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure AnnullaClick(Sender: TObject);
    procedure ListaSettingsChange(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure ApplicaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure QueryPlugin(name: string);
    procedure SalvaSettaggi;
    procedure MostraSettaggi;
    procedure PulisciPlugins;
    procedure SalvaPlugins;
    procedure MostraHotkeys;
    procedure SalvaHotkeys;
    procedure MostraAbout;
    procedure PulisciAbout;
    procedure iniziamusica;
    procedure fermamusica;
  public
    { Public declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  fsettings: Tfsettings;

implementation

{$R resources/music.res}
{$R resources/textures.res}

uses MainCore, FormWizard;


type hotkeyfunzione = record
    id: string;
    nome: string;
    labelnome: TLabel;
    HotKey: THotKey;
  end;

type photkeyfunzione = ^hotkeyfunzione;

type tpluginenabler = record
    icona: timage;
    id: string;
    nome: TLabel;
    descrizione: TLabel;
    abilitato: TCheckBox;
    shape: TShape;
    nodo: TTreeNode;
    funzioni: tlist;
  end;

type ppluginenabler = ^tpluginenabler;

var
  pluginenabler: tlist;
  inihotkeys: tinifile;
  closing: boolean = false;

{$R *.dfm}

//per l'effetto ombreggiatura

procedure Tfsettings.CreateParams(var Params: TCreateParams);
const
  CS_DROPSHADOW = $00020000;
begin
  inherited;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;
end;

procedure Tfsettings.SalvaSettaggi;
begin
  iniSettings.WriteBool('EVUTILS', 'AUTOSTART', CKAutostart.Checked);
  iniSettings.WriteInteger('EVUTILS', 'LANGUAGE', CBLingua.ItemIndex);
  iniSettings.WriteInteger('EVUTILS', 'TRANSPARENCE', TRTrasparenza.Position);
  iniSettings.WriteInteger('EVUTILS', 'VISUAL', integer(RadioPopup.Checked));
  iniSettings.WriteBool('EVUTILS', 'ALWAYSVIS', CKsemprevisibile.Checked);
  if not (CKsemprevisibile.Checked) then
//   fevutils.show else
    fevutils.hide;

  iniSettings.UpdateFile;
end;

procedure Tfsettings.Timer1Timer(Sender: TObject);
begin
  gldraw;
end;

procedure Tfsettings.WizardClick(Sender: TObject);
begin
  fwizard.show; close;
end;

procedure Tfsettings.MostraSettaggi;
var
  listadll: tstringlist;
  i: integer;
begin
  if not assigned(inihotkeys) then
    inihotkeys := tinifile.Create(_PATHSETTINGS + '\hotkeys.ini');

  pluginenabler := tlist.Create;
  listadll := tstringlist.Create;
  Search(extractfilepath(paramstr(0)) + _PATHPLUGINS, '.dll', faanyfile, listadll);
  for i := 0 to listadll.Count - 1 do
    QueryPlugin(listadll[i]);
  listadll.Free;

  CKAutostart.Checked := settings.autostart;
  CBLingua.ItemIndex := settings.lang;
  CKsemprevisibile.Checked := settings.semprevisibile;
  TRTrasparenza.Position := settings.trasparenza;
  case settings.visualizzazione of
    0: RadioListaEsterna.Checked := true;
    1: RadioPopup.Checked := true;
  end;
end;


procedure Tfsettings.SalvaPlugins;
var
  i: integer;
  p: ppluginenabler;
begin
  i := 0;
  while i < pluginenabler.Count do
  begin
    p := ppluginenabler(pluginenabler.items[i]);
    iniSettings.WriteBool('PLUGINS', p.id, p.abilitato.Checked);
    inc(i);
  end;
end;

procedure Tfsettings.SalvaHotkeys;
var
  i, j: integer;
  p: ppluginenabler;
  f: photkeyfunzione;
begin
  i := 0;
  while i < pluginenabler.Count do
  begin
    p := ppluginenabler(pluginenabler.items[i]);
    j := 0;
    while (j < p.funzioni.Count) do
    begin
      f := p.funzioni.items[j];
      inihotkeys.WriteInteger(p.id, f.id, f.HotKey.HotKey);
      inc(j);
    end;
    inc(i);
  end;
  inihotkeys.UpdateFile;
end;


procedure Tfsettings.MostraHotkeys;
var
  i, j: integer;
  p: ppluginenabler;
  f: photkeyfunzione;
  vis: boolean;
begin
  i := 0;
  while i < pluginenabler.Count do
  begin
    p := ppluginenabler(pluginenabler.items[i]);
    vis := p.nome.Caption = ListaSettings.Selected.Text;
    j := 0;
    while (j < p.funzioni.Count) do
    begin
      f := p.funzioni.items[j];
      f.HotKey.Visible := vis;
      f.labelnome.Visible := vis;
      inc(j);
    end;
    inc(i);
  end;
end;

procedure Tfsettings.PulisciPlugins;
var
  i, j: integer;
  p: ppluginenabler;
begin
  i := 0;
  while i < pluginenabler.Count do
  begin
    p := ppluginenabler(pluginenabler.items[i]);
    p.icona.Free;
    p.nome.Free;
    p.descrizione.Free;
    p.abilitato.Free;
    p.shape.Free;
    p.nodo.Delete;

    j := 0;
    while (j < p.funzioni.Count) do
    begin
      photkeyfunzione(p.funzioni.items[j]).labelnome.Free;
      photkeyfunzione(p.funzioni.items[j]).HotKey.Free;
      dispose(photkeyfunzione(p.funzioni.items[j]));
      inc(j);
    end;

    p.funzioni.Free;
    dispose(p);
    inc(i);
  end;
  pluginenabler.Free;
end;

procedure Tfsettings.ApplicaClick(Sender: TObject);
begin
  hide;
  SalvaSettaggi;
  SalvaPlugins;
  SalvaHotkeys;
  fevutils.ReloadAll;
  close;
end;

procedure Tfsettings.AnnullaClick(Sender: TObject);
begin
  close;
end;

procedure Tfsettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  closing := true;
  PulisciPlugins;
  fermamusica;
end;

procedure Tfsettings.FormCreate(Sender: TObject);
var regione: hrgn;
begin
 //nascondo i titoli delle pagine..
  TabSheet1.TabVisible := false; TabSheet2.TabVisible := false; TabSheet3.TabVisible := false; TabSheet4.TabVisible := false; TabSheet5.TabVisible := false; TabSheet6.TabVisible := false;
  TabSheet1.Visible := true;
  ListaSettings.Selected := nil;

  with ListaSettings do
  begin
    regione := CreateRoundRectRgn(0, 0, Width, height, 15, 15);
    SetWindowRgn(Handle, regione, true);
  end;
end;

procedure Tfsettings.FormDestroy(Sender: TObject);
begin
  fermamusica;
end;

procedure Tfsettings.FormHide(Sender: TObject);
begin
  fermamusica;
end;

procedure Tfsettings.FormShow(Sender: TObject);
begin
  MostraSettaggi;
  closing := false;
  if Timer1.Enabled then iniziamusica;
end;

procedure Tfsettings.iniziamusica;
begin
  XMStop();
  XMFree();
  XMPlayFromRes('TOILET', 'XMMOD');
  exit;
end;

procedure Tfsettings.fermamusica;
begin
  XMStop();
  XMFree();
end;

procedure Tfsettings.MostraAbout;
var
  i: integer;
  p: pchar;
begin
  listacredits := tstringlist.Create;
  getmem(p, 2000);
  LoadString(hinstance, 1001, p, 2000);
  listacredits.DelimitedText := p;
  freemem(p, 2000);
  glCreateWnd(PanelAbout.Width, PanelAbout.height, 32, PanelAbout.Handle);
  LoadTexture('font1.tga', texFont, true); // Load the Texture
  LoadTexture('BACK.jpg', texBackground, true); // Load the Texture
  for i := 0 to 6 - 1 do
    LoadTexture('TEX' + inttostr(i) + '.jpg', VidTextures[i], true);
  Timer1.Enabled := true;
  iniziamusica;
end;

procedure Tfsettings.PulisciAbout;
begin
  Timer1.Enabled := false;
  if assigned(listacredits) then
    freeandnil(listacredits);
  glKillWnd();
  fermamusica;
end;

procedure Tfsettings.ListaSettingsChange(Sender: TObject; Node: TTreeNode);
var
  hk: boolean;
begin
  hk := true;
  if ListaSettings.Selected.Text = 'Generale' then begin
    TabSheet1.Visible := true; hk := false; end else TabSheet1.Visible := false;
  if ListaSettings.Selected.Text = 'Plugins' then begin
    TabSheet2.Visible := true; hk := false; end else TabSheet2.Visible := false;
  if ListaSettings.Selected.Text = 'Hotkeys' then begin
    TabSheet3.Visible := true; hk := false; end else TabSheet3.Visible := false;
  if ListaSettings.Selected.Text = 'Visualizzazione' then begin
    TabSheet4.Visible := true; hk := false; end else TabSheet4.Visible := false;
  if ListaSettings.Selected.Text = 'About' then begin
    TabSheet5.Visible := true; hk := false; MostraAbout; end else begin TabSheet5.Visible := false; PulisciAbout; end;
  if hk then
  begin
    if not closing then
    begin
      MostraHotkeys;
      TabSheet6.Visible := true;
    end;
  end
  else
  begin
    TabSheet6.Visible := false;
  end;

end;

procedure Tfsettings.QueryPlugin(name: string);
var
  DLLHandle: THandle;
  DllQuery: DLLevutilsQuery;
  QueryParametri: ParametriQuery;
  icona: TIcon;
  pp: ppluginenabler;
  parente: twincontrol;
  nfunzioni: byte;
  nodo: TTreeNode;
  DllFunction: DLLevutilsFunction;
  FunctionParametri: ParametriFunction;
  i: byte;
  idfunzione, nomefunzione: pchar;
  dummy: integer;
  hk: photkeyfunzione;
const
  spaziatura = 50;
begin
  DLLHandle := LoadLibrary(pchar(name));
  if DLLHandle <> 0 then
  begin
    @DllQuery := GetProcAddress(DLLHandle, 'evutilsquery');
    if assigned(DllQuery) then
    begin
      getmem(QueryParametri.nome, _MAXNOMEPLUGIN);
      getmem(QueryParametri.versione, _MAXNOMEPLUGIN);
      getmem(QueryParametri.descrizione, _MAXNOMEPLUGIN);
      getmem(QueryParametri.id, _MAXNOMEPLUGIN);
      QueryParametri.lang := settings.lang;
      QueryParametri.funzioni := @nfunzioni;

      DllQuery(@QueryParametri);

      new(pp);
      pluginenabler.Add(pp);

      parente := ScrPlugins;

      pp.id := QueryParametri.id;

      //SHAPE
      pp.shape := TShape.Create(self);
      pp.shape.Parent := parente;
      pp.shape.Left := 100;
      pp.shape.Width := 240;
      pp.shape.Top := 3 + (pluginenabler.Count - 1) * spaziatura;
      pp.shape.Brush.Color := clActiveBorder;
      pp.shape.Pen.Style := psclear;

      //CHECKBOX
      pp.abilitato := TCheckBox.Create(self);
      pp.abilitato.Parent := parente;
      pp.abilitato.Left := 10;
      pp.abilitato.Top := 13 + (pluginenabler.Count - 1) * spaziatura;
      pp.abilitato.Width := 330;
      pp.abilitato.Caption := '';
      pp.abilitato.Checked := iniSettings.ReadBool('PLUGINS', QueryParametri.id, false);

      //IMMAGINE
      pp.icona := timage.Create(self);
      icona := TIcon.Create;
      icona.LoadFromResourceName(DLLHandle, 'PLUGIN');
      pp.icona.Picture.Assign(icona);
      pp.icona.Parent := parente;
      pp.icona.AutoSize := true;
      pp.icona.Left := 50;
      pp.icona.Top := 5 + (pluginenabler.Count - 1) * spaziatura;
      icona.Free;

      //TITOLO
      pp.nome := TLabel.Create(self);
      pp.nome.Parent := parente;
      pp.nome.AutoSize := true;
      pp.nome.Font.Style := [fsbold];
      pp.nome.Font.Size := 7;
      pp.nome.Left := 110;
      pp.nome.Top := 5 + (pluginenabler.Count - 1) * spaziatura;
      pp.nome.Transparent := true;
      pp.nome.Caption := QueryParametri.nome;

      //DESCRIZIONE
      pp.descrizione := TLabel.Create(self);
      pp.descrizione.Parent := parente;
      pp.descrizione.AutoSize := true;
      pp.descrizione.Font.Style := [fsitalic];
      pp.descrizione.Left := 110;
      pp.descrizione.Top := 15 + (pluginenabler.Count - 1) * spaziatura;
      pp.descrizione.WordWrap := true;
      pp.descrizione.Transparent := true;
      pp.descrizione.Width := 230;
      pp.descrizione.Caption := QueryParametri.descrizione;

      //SHAPE
      pp.shape.height := pp.nome.height + pp.descrizione.height + 4;

      freemem(QueryParametri.nome, _MAXNOMEPLUGIN);
      freemem(QueryParametri.versione, _MAXNOMEPLUGIN);
      freemem(QueryParametri.descrizione, _MAXNOMEPLUGIN);
      freemem(QueryParametri.id, _MAXNOMEPLUGIN);

      //HOTKEYS

      nodo := ListaSettings.items.GetFirstNode;
      while (nodo.Text <> 'Hotkeys') do
      begin
        nodo := nodo.GetNext;
      end;
      pp.nodo := ListaSettings.items.AddChild(nodo, QueryParametri.nome);
      pp.funzioni := tlist.Create;

      getmem(idfunzione, _MAXNOMEPLUGIN);
      getmem(nomefunzione, _MAXNOMEPLUGIN);

      @DllFunction := GetProcAddress(DLLHandle, 'evutilsfunction');
      if assigned(DllFunction) then
      begin
        i := 1;
        while i <= nfunzioni do
        begin
          FunctionParametri.numero := i;
          FunctionParametri.nome := nomefunzione;
          FunctionParametri.id := idfunzione;
          FunctionParametri.address := @dummy;
          if DllFunction(@FunctionParametri) = 0 then
          begin
            continue;
          end
          else
          begin
            new(hk);
            hk.id := idfunzione;
            hk.nome := nomefunzione;
            hk.labelnome := TLabel.Create(self);
            hk.labelnome.Visible := false;
            hk.labelnome.Parent := SCRHotkeys;
            hk.labelnome.AutoSize := true;
            hk.labelnome.Left := 10;
            hk.labelnome.Top := 15 + i * 30;
            hk.labelnome.Caption := hk.nome;

            hk.HotKey := THotKey.Create(self);
            hk.HotKey.Visible := false;
            hk.HotKey.Parent := SCRHotkeys;
            hk.HotKey.Width := 125;
            hk.HotKey.height := 25;
            hk.HotKey.Left := 170;
            hk.HotKey.Top := 10 + i * 30;
            hk.HotKey.HotKey := inihotkeys.ReadInteger(pp.id, hk.id, 0);

            pp.funzioni.Add(hk);
          end;
          inc(i);
        end;
      end;

      freemem(idfunzione, _MAXNOMEPLUGIN);
      freemem(nomefunzione, _MAXNOMEPLUGIN);

      freelibrary(DLLHandle);
    end;
  end;
end;


end.

