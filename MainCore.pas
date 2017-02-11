unit MainCore;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, inifiles
  , Definizioni, kutils, plugin, ComCtrls, ImgList, XPMan, HotKeyManager,
  FastShellLink, evupengl, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP
  ;


type TeVcoresettings = record
    autostart: boolean;
    lang: byte;
    trasparenza: byte;
    visualizzazione: byte;
    semprevisibile: boolean;
    left, top: integer;
    nesecuzioni: integer;
    ncrashes: integer;
    autoupdatecore: boolean;
    autoupdateplugins: boolean;
  end;

type
  TFevutils = class(TForm)
    trayicon: TTrayIcon;
    ButtonExit: TButton;
    ButtonAbout: TButton;
    ButtonSettings: TButton;
    Image5: TImage;
    Shape1: TShape;
    ListView1: TListView;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    XPManifest1: TXPManifest;
    HotKeyManager1: THotKeyManager;
    FastShellLink: TFastShellLink;
    IdHTTP1: TIdHTTP;
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnDeactivate(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure ButtonAboutClick(Sender: TObject);
    procedure HotKeyManager1HotKeyPressed(HotKey: Cardinal; Index: Word);
    procedure ClickMenuItems(Sender: TObject);
    procedure trayiconMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure ButtonSettingsClick(Sender: TObject);
  private
    procedure RidimensionaForm;
    procedure LoadPlugins;
    function LoadPluginDuo(name: string; lastid: integer): boolean;
    procedure UnloadPlugins;
    procedure SaveHotKeys;
    procedure LoadHotKeys;
    procedure LoadSettings;
    function CercaUpdate: boolean;
    function UpdatePlugin(id, dll, name: string): boolean;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message wm_NCHitTest;
  public
    procedure ReloadAll;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  _PATHSETTINGS: string;
  Fevutils: TFevutils;
  Settings: TeVcoresettings;
  iniSettings: tinifile;
  ready: boolean = false;

function AvviaFunzione(Parametri: PParametroChiamata): integer; stdcall;

const
  _PATHPLUGINS = 'PLUGINS\';
const
  _WEBSITE = 'http://evutils.altervista.org';
  _WEBUPDATEFILE = _WEBSITE + '/update.txt';

implementation

uses PopupFunzioni, FormSettings, FormWizard;

{$R *.dfm}

var
  listaplugin: TList;

//per il trascinamento form

procedure TFevutils.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  if (htClient = Msg.Result) then
    Msg.Result := htCaption;
end;

//per l'effetto ombreggiatura

procedure TFevutils.CreateParams(var Params: TCreateParams);
const
  CS_DROPSHADOW = $00020000;
begin
  inherited;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;
end;

function AvviaFunzione(Parametri: PParametroChiamata): integer; stdcall;
var
  Par: ParametriFunzioneGenerica;
begin
  Par.FromHotkey := Parametri^.FromHotkey;
  Par.ChangeMenuName := false;
  GenericFunction(Parametri.Funzione.address)(@Par);
  if Par.ChangeMenuName then
    strlcopy(Parametri.Funzione.NomeFunzione, Par.MenuName, _MAXNOMEPLUGIN);
  dispose(Parametri);
  Result := 1;
end;


function Notifica(titolo: pchar; testo: pchar): boolean; stdcall;
begin
  Fevutils.trayicon.BalloonTitle := titolo;
  Fevutils.trayicon.BalloonHint := testo;
  Fevutils.trayicon.BalloonTimeout := 5;
  Fevutils.trayicon.ShowBalloonHint;
  Result := true;
end;

var
  updatefile: tstringlist;

procedure TFevutils.LoadPlugins;
var
  listadll: tstringlist;
  i, lastid: integer;
begin
  lastid := 0;
  listadll := tstringlist.Create;
  listaplugin := TList.Create;
  Search(extractfilepath(paramstr(0)) + _PATHPLUGINS, '.dll', faanyfile, listadll);
  for i := 0 to listadll.Count - 1 do
    if LoadPluginDuo(listadll[i], lastid) then
      inc(lastid);
  listadll.Free;
end;

procedure TFevutils.ListView1Click(Sender: TObject);
begin
  PopupMenu1Popup(Sender);
end;

function TFevutils.UpdatePlugin(id, dll, name: string): boolean;
var
  temp: tstream;
  i: integer;
  link: string;
begin
  Result := false;
  Notifica('', pchar('eVutils: aggiornamento di ' + name));
  temp := tmemorystream.Create;
  for i := 0 to updatefile.Count - 1 do
    if leggitra('<', '>', updatefile[i]) = id then
    begin
      link := leggitra('[', ']', updatefile[i]);
      try
        IdHTTP1.Get(link, temp);
        tmemorystream(temp).SaveToFile(dll);
        break;
      except
        begin
          Notifica('', pchar('eVutils: aggiornamento di ' + name + ' fallito'));
          break;
        end;
      end;
    end;
end;


function TFevutils.LoadPluginDuo(name: string; lastid: integer): boolean;
var
  DLLHandle: THandle;
  InitParametri: ParametriInit;
  nuovoplugin: TevPlugin;
  nuovafunzione: TevFunction;
  function lanciainit(update: boolean): integer;
  var
    QueryParametri: ParametriQuery;
    DllQuery: DLLevutilsQuery;
    DllInit: DLLevutilsInit;
    i: integer;
  begin
    Result := 0;
    @DllQuery := GetProcAddress(DLLHandle, 'evutilsquery');
    if Assigned(DllQuery) then
    begin
      nuovoplugin := TevPlugin.Create;
      nuovoplugin.DLLHandle := DLLHandle;
      with nuovoplugin do
      begin
        QueryParametri.nome := nomeplugin;
        QueryParametri.versione := versione;
        QueryParametri.descrizione := descrizione;
        QueryParametri.id := idplugin;

        QueryParametri.lang := Settings.lang;
        QueryParametri.funzioni := @nuovoplugin.nfunzioni;

        DllQuery(@QueryParametri);


        if not iniSettings.ReadBool('PLUGINS', QueryParametri.id, false) then
        begin
          nuovoplugin.Free;
          exit;
        end;

        if Settings.autoupdateplugins and update and Assigned(updatefile) then
        begin
          for i := 0 to updatefile.Count - 1 do
            if leggitra('<', '>', updatefile[i]) = QueryParametri.id then
              if leggitra('(', ')', updatefile[i]) <> QueryParametri.versione then
                //if messagebox(0, pchar('updatare: ' + QueryParametri.nome), 'update', mb_yesno) = idyes then
              begin
                Result := 2;
                nuovoplugin.Free;
                UpdatePlugin(QueryParametri.id, name, QueryParametri.nome);
                break;
              end;
        end;

        @DllInit := GetProcAddress(DLLHandle, 'evutilsinit');
        if Assigned(DllInit) then
        begin
          nuovoplugin.id := lastid;
          Icona.LoadFromResourceName(DLLHandle, 'PLUGIN');
          InitParametri.FNotifica := @Notifica;
          InitParametri.Working_dir := pchar(extractfilepath(paramstr(0)) + _PATHPLUGINS);
          InitParametri.lang := Settings.lang;
          DllInit(@InitParametri);
          if nuovoplugin.nfunzioni > 0 then
            funzioni := TList.Create;
          listaplugin.Add(nuovoplugin);
          Result := 1;
        end;
      end;
    end;
  end;

  function lanciaqueryfunctions: boolean;
  var
    DllFunction: DLLevutilsFunction;
    FunctionParametri: ParametriFunction;
    i: byte;
  begin
    Result := true;
    @DllFunction := GetProcAddress(DLLHandle, 'evutilsfunction');
    if Assigned(DllFunction) then
    begin
      i := 1;
      while i <= nuovoplugin.nfunzioni do
      begin
        nuovafunzione := TevFunction.Create(nuovoplugin);
        FunctionParametri.numero := i;
        FunctionParametri.nome := nuovafunzione.NomeFunzione;
        FunctionParametri.id := nuovafunzione.id;
        FunctionParametri.address := @nuovafunzione.address;
        if DllFunction(@FunctionParametri) = 0 then
        begin
          nuovafunzione.Free;
          inc(i);
          continue;
        end;
        nuovoplugin.funzioni.Add(nuovafunzione);
        inc(i);
      end;
    end;
  end;

  function mostraplugin: boolean;
  var
    l: TListItem;
  begin
    Result := false;
    l := ListView1.Items.Add;
    l.Caption := (nuovoplugin.nomeplugin);
    l.ImageIndex := ImageList1.AddIcon(nuovoplugin.Icona);
    l.Data := nuovoplugin;
  end;

var
  tentativi: byte;
begin
  Result := false;
  tentativi := 0;

  while (tentativi < 3) and (not Result) do
  begin
    inc(tentativi);
    DLLHandle := LoadLibrary(pchar(name));
    if DLLHandle <> 0 then
    begin
      case lanciainit(tentativi < 3) of
        0: exit;
        1: if lanciaqueryfunctions then
          begin
            mostraplugin;
            Result := true;
          end;
        2:
      end;
    end;
  end;
end;


procedure TFevutils.UnloadPlugins;
var
  i: integer;
  KPlugin: TevPlugin;
begin
  if not Assigned(listaplugin) then exit;

  i := ListView1.Items.Count - 1;
  while (i >= 0) do
  begin
    ListView1.Items[0].Free;
    dec(i);
  end;
  ImageList1.Clear;

  i := listaplugin.Count - 1;
  while (i >= 0) do
  begin
    KPlugin := TevPlugin(listaplugin.Items[i]);
    listaplugin.delete(i);
    KPlugin.Free;
    dec(i);
  end;
  freeandnil(listaplugin);
end;

{
function plugincaricato(nome: pchar): boolean;
var
  i: Integer;
  trovato: boolean;
begin
  result := false;
  trovato := false;
  i := 0;
  while (i < listaplugin.Count) do
  begin
    if comparestr(PPlugin(listaplugin.Items[i]).nomeplugin, nome) = 0 then
    begin
      if trovato then
      begin
        result := true;
        break;
      end;
      trovato := true;
    end;
    inc(i);
  end;
end;
}
//-----------------

procedure TFevutils.SaveHotKeys;
var
  i, j: integer;
  KPlugin: TevPlugin;
  KFunzione: TevFunction;
  Sezione: string;
  Funzione: string;
  HotKey: Cardinal;
  ini: tinifile;
begin
  ini := tinifile.Create(_PATHSETTINGS + '\hotkeys.ini');
  for i := 0 to listaplugin.Count - 1 do
  begin
    KPlugin := listaplugin.Items[i];
    for j := 0 to KPlugin.funzioni.Count - 1 do
    begin
      KFunzione := KPlugin.funzioni.Items[j];
      Sezione := KPlugin.nomeplugin;
      Funzione := KFunzione.id;
      HotKey := KFunzione.HotKey;
      ini.WriteInteger(Sezione, Funzione, HotKey);
    end;
  end;
  ini.updatefile;
  ini.Free;
end;

procedure TFevutils.LoadHotKeys;
var
  i, j: integer;
  KPlugin: TevPlugin;
  KFunzione: TevFunction;
  Sezione: string;
  Funzione: string;
  HotKey: Cardinal;
  ini: tinifile;
  errore: boolean;
begin

  errore := false;
  HotKeyManager1.ClearHotKeys;
  ini := tinifile.Create(_PATHSETTINGS + '\hotkeys.ini');
  for i := 0 to listaplugin.Count - 1 do
  begin
    KPlugin := listaplugin.Items[i];
    for j := 0 to KPlugin.funzioni.Count - 1 do
    begin
      KFunzione := KPlugin.funzioni.Items[j];
      Sezione := KPlugin.idplugin;
      Funzione := KFunzione.id;
      HotKey := ini.ReadInteger(Sezione, Funzione, 0);
      KFunzione.HotKey := HotKey;
      if HotKey <> 0 then
        if HotKeyManager1.AddHotKey(HotKey) = 0 then
        begin
          KFunzione.HotKey := 0;
          errore := true;
          Notifica(nil, pchar('eVutils: HotKey Duplicata in' + #13 + #10 + KPlugin.nomeplugin + ' - ' + KFunzione.NomeFunzione + #13 + #10 + 'Rimossa'));
        end;
    end;
  end;
  ini.Free;
  if errore then
    SaveHotKeys;
end;

//-----------------

procedure TFevutils.ButtonExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFevutils.ButtonSettingsClick(Sender: TObject);
begin
  if not (Settings.semprevisibile) then
    Fevutils.hide;
  FPopoupFunzioni.hide;
  HotKeyManager1.ClearHotKeys;
  fsettings.showmodal;
  LoadHotKeys;
end;

procedure TFevutils.ReloadAll;
begin
  ready := false;
  _PATHSETTINGS := extractfilepath(paramstr(0));
  UnloadPlugins;
  CercaUpdate;
  LoadSettings;
  LoadPlugins;
  RidimensionaForm;
  LoadHotKeys;
  ready := true;
end;

procedure TFevutils.ButtonAboutClick(Sender: TObject);
begin
  ReloadAll;
end;

procedure TFevutils.RidimensionaForm;
var
  hregion: hrgn;
begin
  Fevutils.height := 42 + max(2, listaplugin.Count) * 17;
  hregion := CreateRoundRectRgn(0, 0, Width, height, 15, 15);
  SetWindowRgn(Handle, hregion, true);

  //non in taskbar
  //SetWindowLong(Application.Handle, GWL_STYLE, WS_POPUP);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW);
  //metto on top..
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TFevutils.LoadSettings;
begin
  iniSettings := tinifile.Create(_PATHSETTINGS + '\evsettings.ini');
  Settings.nesecuzioni := iniSettings.ReadInteger('EVUTILS', 'NESECUZIONI', 0);
  if (Settings.nesecuzioni = 0) then fwizard.show;
  Settings.autostart := iniSettings.ReadBool('EVUTILS', 'AUTOSTART', false);
  Settings.lang := iniSettings.ReadInteger('EVUTILS', 'LANGUAGE', 0);
  Settings.trasparenza := iniSettings.ReadInteger('EVUTILS', 'TRANSPARENCE', 0);
  Settings.visualizzazione := iniSettings.ReadInteger('EVUTILS', 'VISUAL', 0);
  Settings.semprevisibile := iniSettings.ReadBool('EVUTILS', 'ALWAYSVIS', false);
  Settings.left := iniSettings.ReadInteger('EVUTILS', 'LEFT', 0);
  Settings.top := iniSettings.ReadInteger('EVUTILS', 'TOP', 0);
  Settings.ncrashes := iniSettings.ReadInteger('EVUTILS', 'NCRASH', 0);
  inc(Settings.ncrashes);
  iniSettings.WriteInteger('EVUTILS', 'NCRASH', Settings.ncrashes);

  FastShellLink.LinkName := 'eVutils';
  FastShellLink.LinkTarget := paramstr(0);
  FastShellLink.ParamString := '';
  FastShellLink.WorkingDirectory := extractfilepath(paramstr(0));
  FastShellLink.CreateIn.ShellFolder := sfStartup;

  case Settings.autostart of
    true:
      begin
        FastShellLink.Execute;
      end;
    false:
      begin
        FastShellLink.Canzela;
      end;
  end;

end;

function TFevutils.CercaUpdate: boolean;
var
  st: tstream;
begin
  Result := false;
  Settings.autoupdateplugins := true; //MMMM
  if Settings.autoupdateplugins then
  begin
    Notifica('', 'eVutils: ricerca aggiornamenti...');
    st := tmemorystream.Create;
    if not Assigned(updatefile) then
      updatefile := tstringlist.Create
    else
      updatefile.Clear;
    try
      IdHTTP1.Get(_WEBUPDATEFILE, st);
      st.Seek(0, soBeginning);
      updatefile.LoadFromStream(st);
    except
      Notifica('', 'eVutils: impossibile trovare aggiornamenti');
    end;
    st.Free;
  end;
end;

procedure TFevutils.FormCreate(Sender: TObject);
begin
   //non in taskbar
  //SetWindowLong(Application.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW);
  ReloadAll;
  if Settings.semprevisibile then
  begin
    left := Settings.left; top := Settings.top;
    Application.ShowMainForm := true; Fevutils.show;
  end else Application.ShowMainForm := false;

  Notifica('', 'eVutils: Attivo');
end;

procedure TFevutils.FormDestroy(Sender: TObject);
begin
  iniSettings.WriteInteger('EVUTILS', 'LEFT', left);
  iniSettings.WriteInteger('EVUTILS', 'TOP', top);
  inc(Settings.nesecuzioni);
  iniSettings.WriteInteger('EVUTILS', 'NESECUZIONI', Settings.nesecuzioni);
  dec(Settings.ncrashes);
  iniSettings.WriteInteger('EVUTILS', 'NCRASH', Settings.ncrashes);
  iniSettings.updatefile;
end;

procedure TFevutils.FormPaint(Sender: TObject);
begin
  //per il bordo..
  canvas.pen.Width := 1;
  canvas.pen.Color := clCaptionText;
  canvas.RoundRect(-1, -1, Width - 1, height - 1, 15, 15);
end;

procedure TFevutils.FormShow(Sender: TObject);
begin
  if Settings.semprevisibile then
  begin Fevutils.left := Settings.left; Fevutils.top := Settings.top end;
end;

procedure TFevutils.HotKeyManager1HotKeyPressed(HotKey: Cardinal; Index: Word);
var
  i, j: integer;
  KPlugin: TevPlugin;
  KFunzione: TevFunction;
  Par: PParametroChiamata;
begin
  for i := 0 to listaplugin.Count - 1 do
  begin
    KPlugin := listaplugin.Items[i];
    for j := 0 to KPlugin.funzioni.Count - 1 do
    begin
      KFunzione := KPlugin.funzioni.Items[j];
      if KFunzione.HotKey = HotKey then
      begin
        new(Par);
        Par.FromHotkey := true;
        Par.Funzione := KFunzione;
        StartThread(@AvviaFunzione, Par);
        break;
      end;
    end;
  end;
end;

procedure TFevutils.ClickMenuItems(Sender: TObject);
var
  KFunzione: TevFunction;
  Par: PParametroChiamata;
begin
  KFunzione := pointer(TmenuItem(Sender).Tag);
  new(Par);
  Par.Funzione := KFunzione;
  Par.FromHotkey := false;
  StartThread(@AvviaFunzione, Par);
  if not (Settings.semprevisibile) then
    Fevutils.hide;
end;

procedure TFevutils.OnDeactivate(Sender: TObject);
begin
  if not ready then exit;
  if not (Settings.semprevisibile) then
    Fevutils.hide;
  FPopoupFunzioni.hide;
end;

procedure TFevutils.PopupMenu1Popup(Sender: TObject);
var
  m: TmenuItem;
  KPlugin: TevPlugin;
  KFunction: TevFunction;
  i: integer;
begin
  FPopoupFunzioni.boxlist1.Items.Clear;
  i := 0;
  while i < PopupMenu1.Items.Count do
  begin
    PopupMenu1.Items.delete(0);
  end;
  if ListView1.Items[ListView1.ItemIndex] <> nil then
  begin
    KPlugin := TevPlugin(ListView1.Items[ListView1.ItemIndex].Data);
    if KPlugin <> nil then
    begin
      i := 0;
      while i < KPlugin.nfunzioni do
      begin
        case Settings.visualizzazione of
          0: FPopoupFunzioni.boxlist1.Items.AddObject(TevFunction(KPlugin.funzioni[i]).NomeFunzione, TevFunction(KPlugin.funzioni[i]));
          1:
            begin
              m := TmenuItem.Create(PopupMenu1);
              KFunction := TevFunction(KPlugin.funzioni[i]);
              m.Caption := KFunction.NomeFunzione;
              m.Tag := integer((KFunction));
              m.OnClick := ClickMenuItems;
              m.ShortCut := KFunction.HotKey;
              PopupMenu1.Items.Add(m);
            end;
        end;
        inc(i);
      end;
      if Settings.visualizzazione = 0 then
      begin
        FPopoupFunzioni.height := max(KPlugin.nfunzioni * 15, 20);
        FPopoupFunzioni.top := Fevutils.top - FPopoupFunzioni.height;
        FPopoupFunzioni.left := Fevutils.left + ((Fevutils.Width - FPopoupFunzioni.Width) div 2);
        FPopoupFunzioni.boxlist1.Refresh;
        FPopoupFunzioni.show;
        ListView1.SetFocus;
      end;
    end;
  end
  else
    if Settings.visualizzazione = 0 then
      FPopoupFunzioni.hide;
end;

procedure TFevutils.trayiconMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  p: tpoint;
begin
  if not ready then exit;

  if fsettings.Visible then
  begin
    setforegroundwindow(fsettings.Handle);
    exit;
  end;

  ListView1.ItemIndex := -1;
  if (Settings.semprevisibile) then
  begin
    setforegroundwindow(Handle);
    exit;
  end;
  p.X := X;
  p.Y := Y;
  if p.Y > Fevutils.height then
    Fevutils.top := p.Y - Fevutils.height else Fevutils.top := p.Y;
  if p.X > Fevutils.Width then
    Fevutils.left := p.X - Fevutils.Width else Fevutils.left := p.X;
  if Fevutils.Showing then
  begin
    if not (Settings.semprevisibile) then
      Fevutils.hide;
  end
  else Fevutils.show;
  Windows.setforegroundwindow(Handle);
end;

initialization
  Application.OnDeactivate := Fevutils.OnDeactivate;

finalization
  iniSettings.Free;


end.

