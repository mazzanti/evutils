unit FormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, fastbmp, Spin, ComCtrls, Buttons, inifiles,
  jpeg, pngimage, dutils, evutilslanguages, Definizioni, IdContext, evutilsBaloon,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer;


type ttiposcreen = (completo, finestra);
type tformato = (fbitmap, fjpeg, fpng);

var indexpage: string;

type
  TMain = class(TForm)
    RFormato: TRadioGroup;
    QualitaBmp: TRadioGroup;
    QualitaJpeg: TGroupBox;
    Qualitajpegvalore: TEdit;
    SpinButton1: TSpinButton;
    Lqualita: TLabel;
    GBScale: TGroupBox;
    scalavalore: TEdit;
    SpinButton2: TSpinButton;
    scalack: TCheckBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    GBFiltro: TGroupBox;
    Label2: TLabel;
    FiltroCB: TComboBox;
    SaveDialog1: TSaveDialog;
    Image1: TImage;
    GBPubbl: TGroupBox;
    signck: TCheckBox;
    GBDefaultDir: TGroupBox;
    CKDir: TCheckBox;
    DefDir: TEdit;
    SelectFolder: TButton;
    Server: TIdHTTPServer;
    ListBox1: TListBox;
    procedure RFormatoClick(Sender: TObject);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpinButton2DownClick(Sender: TObject);
    procedure SpinButton2UpClick(Sender: TObject);
    procedure scalackClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SelectFolderClick(Sender: TObject);
    procedure ServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    function TraduciForm(lingua: integer): boolean; stdcall;
    procedure salvasettaggi;
    procedure assegnasettaggi;
    procedure prendisettaggi;
    procedure caricasettaggi;
  public
    function salva(tb: tbitmap; filename: string; formato: tformato; sign: boolean = true): tmemorystream;
    procedure DoScreenShot(tipo: ttiposcreen);
  end;

type timpostazioni = record
    formato: tformato;
    QualitaJpeg: byte;
    QualitaBmp: tpixelformat;
    scala: boolean;
    scalap: integer;
    filtro: byte;
    sign: boolean;
    usedefdir: boolean;
    DefDir: string;
  end;

var
  Main: TMain;
var
  Path: string;
  imp: timpostazioni;

implementation

{$R *.dfm}

const
  firma: string = 'http://evutils.altervista.org';

var
  capcompleto: string;
  capwindow: string;

function TMain.TraduciForm(lingua: integer): boolean; stdcall;
var
  Buff: array[0..255] of Char;
  Base: integer;
begin
  result := true;
  Base := (lingua + 1) * 1000;
  LoadString(HInstance, Base + 001, Buff, SizeOf(Buff));
  GBScale.Caption := Buff;
  LoadString(HInstance, Base + 002, Buff, SizeOf(Buff));
  scalack.Caption := Buff;
  LoadString(HInstance, Base + 003, Buff, SizeOf(Buff));
  GBFiltro.Caption := Buff;
  LoadString(HInstance, Base + 004, Buff, SizeOf(Buff));
  FiltroCB.items[2] := Buff;
  LoadString(HInstance, Base + 005, Buff, SizeOf(Buff));
  GBDefaultDir.Caption := Buff;
  LoadString(HInstance, Base + 006, Buff, SizeOf(Buff));
  QualitaJpeg.Caption := Buff;
  LoadString(HInstance, Base + 007, Buff, SizeOf(Buff));
  QualitaBmp.Caption := Buff;
  LoadString(HInstance, Base + 008, Buff, SizeOf(Buff));
  Lqualita.Caption := Buff;
  LoadString(HInstance, Base + 009, Buff, SizeOf(Buff));
  RFormato.Caption := Buff;
  LoadString(HInstance, Base + 010, Buff, SizeOf(Buff));
  BitBtn1.Caption := Buff;
  LoadString(HInstance, Base + 011, Buff, SizeOf(Buff));
  BitBtn2.Caption := Buff;
  LoadString(HInstance, Base + 012, Buff, SizeOf(Buff));
  GBPubbl.Caption := Buff;
  LoadString(HInstance, Base + 013, Buff, SizeOf(Buff));
  signck.Caption := Buff;
  LoadString(HInstance, Base + 014, Buff, SizeOf(Buff));
  capcompleto := Buff;
  LoadString(HInstance, Base + 015, Buff, SizeOf(Buff));
  capwindow := Buff;
end;

procedure TMain.BitBtn1Click(Sender: TObject);
begin
  salvasettaggi;
  caricasettaggi;
  close;
end;

procedure TMain.BitBtn2Click(Sender: TObject);
begin
  close;
  caricasettaggi;
end;

procedure TMain.assegnasettaggi;
var
  tmp: integer;
begin
  tmp := 0;
  case imp.formato of
    fbitmap: RFormato.ItemIndex := 0;
    fjpeg: RFormato.ItemIndex := 1;
    fpng: RFormato.ItemIndex := 2;
  end;

  case imp.QualitaBmp of
    pf1bit: tmp := 1;
    pf4bit: tmp := 2;
    pf8bit: tmp := 3;
    pf16bit: tmp := 4;
    pf24bit: tmp := 5;
  end;
  QualitaBmp.ItemIndex := tmp - 1;
  Qualitajpegvalore.Text := inttostr(imp.QualitaJpeg);

  scalack.checked := imp.scala;
  scalavalore.Text := inttostr(imp.scalap);
  FiltroCB.ItemIndex := imp.filtro;
  signck.checked := imp.sign;

  CKDir.checked := imp.usedefdir;
  DefDir.Text := imp.DefDir;

  RFormatoClick(nil);
  scalackClick(nil);
end;

procedure TMain.prendisettaggi;
begin
  case RFormato.ItemIndex of
    0: imp.formato := fbitmap;
    1: imp.formato := fjpeg;
    2: imp.formato := fpng;
  end;

  case QualitaBmp.ItemIndex + 1 of
    1: imp.QualitaBmp := pf1bit;
    2: imp.QualitaBmp := pf4bit;
    3: imp.QualitaBmp := pf8bit;
    4: imp.QualitaBmp := pf16bit;
    5: imp.QualitaBmp := pf24bit;
  end;

  imp.QualitaJpeg := strtoint(Qualitajpegvalore.Text);

  imp.scala := scalack.checked;
  imp.scalap := strtoint(scalavalore.Text);
  imp.filtro := FiltroCB.ItemIndex;
  imp.sign := signck.checked;

  imp.usedefdir := CKDir.checked;
  imp.DefDir := DefDir.Text;
end;

procedure TMain.salvasettaggi;
var
  ini: tinifile;
  tmp: integer;
begin
  prendisettaggi;

  tmp := 1;
  ini := tinifile.Create(Path + '\screenshotter.ini');
  case imp.formato of
    fbitmap: tmp := 1;
    fjpeg: tmp := 2;
    fpng: tmp := 3;
  end;
  ini.WriteInteger('SETTINGS', 'FORMATO', tmp);

  case imp.QualitaBmp of
    pf1bit: tmp := 1;
    pf4bit: tmp := 2;
    pf8bit: tmp := 3;
    pf16bit: tmp := 4;
    pf24bit: tmp := 5;
  end;
  ini.WriteInteger('SETTINGS', 'QUALITABMP', tmp);

  ini.WriteInteger('SETTINGS', 'QUALITAJPEG', imp.QualitaJpeg);

  ini.WriteBool('SETTINGS', 'SCALA', imp.scala);
  ini.WriteInteger('SETTINGS', 'SCALAP', imp.scalap);
  ini.WriteInteger('SETTINGS', 'FILTRO', imp.filtro);
  ini.WriteBool('SETTINGS', 'SIGN', imp.sign);

  ini.WriteBool('SETTINGS', 'USEDEFDIR', imp.usedefdir);
  ini.WriteString('SETTINGS', 'DEFDIR', imp.DefDir);

  ini.UpdateFile;
  ini.Free;
end;

procedure TMain.caricasettaggi;
var
  ini: tinifile;
  tmp: integer;
begin
  ini := tinifile.Create(Path + '\screenshotter.ini');
  tmp := ini.ReadInteger('SETTINGS', 'FORMATO', 2);
  if (tmp <> 1) and (tmp <> 2) and (tmp <> 3) then
    tmp := 2;

  case tmp of
    1: imp.formato := fbitmap;
    2: imp.formato := fjpeg;
    3: imp.formato := fpng;
  end;

  tmp := ini.ReadInteger('SETTINGS', 'QUALITABMP', 5);
  if (tmp < 1) or (tmp > 5) then
    tmp := 5;
  case tmp of
    1: imp.QualitaBmp := pf1bit;
    2: imp.QualitaBmp := pf4bit;
    3: imp.QualitaBmp := pf8bit;
    4: imp.QualitaBmp := pf16bit;
    5: imp.QualitaBmp := pf24bit;
  end;

  tmp := ini.ReadInteger('SETTINGS', 'QUALITAJPEG', 75);
  if (tmp < 10) or (tmp > 100) then
    tmp := 75;
  imp.QualitaJpeg := tmp;

  imp.scala := ini.ReadBool('SETTINGS', 'SCALA', false);
  tmp := ini.ReadInteger('SETTINGS', 'SCALAP', 100);
  if (tmp < 1) or (tmp > 1000) then
    tmp := 100;
  imp.scalap := tmp;

  tmp := ini.ReadInteger('SETTINGS', 'FILTRO', 0);
  if (tmp < 0) or (tmp > 2) then
    tmp := 0;
  imp.filtro := tmp;
  imp.sign := ini.ReadBool('SETTINGS', 'SIGN', true);
  imp.usedefdir := ini.ReadBool('SETTINGS', 'USEDEFDIR', false);
  imp.DefDir := ini.ReadString('SETTINGS', 'DEFDIR', '');

  ini.Free;

  assegnasettaggi;
end;


procedure TMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  case language of
    0, 1: TraduciForm(language);
  else TraduciForm(0);
  end;
  caricasettaggi;
  for i := 0 to ListBox1.items.count - 1 do
    indexpage := indexpage + #13 + #10 + ListBox1.items[i];
end;

procedure TMain.FormShow(Sender: TObject);
begin
  setforegroundwindow(self.Handle);
end;

procedure TMain.RFormatoClick(Sender: TObject);
begin
  case RFormato.ItemIndex of
    0:
      begin
        QualitaBmp.Visible := true;
        QualitaJpeg.Visible := false;
      end;
    1:
      begin
        QualitaJpeg.Visible := true;
        QualitaBmp.Visible := false;
      end;
    2:
      begin
        QualitaJpeg.Visible := false;
        QualitaBmp.Visible := false;
      end;
  end;
end;


function PrendiSchermo(tipo: ttiposcreen): tbitmap;
var
  hd: hdc;
  wi, he: integer;
  hwnd: THandle;
  r: trect;
begin
  result := tbitmap.Create;

  if tipo = completo then
    hwnd := getdesktopwindow
  else
    hwnd := getforegroundwindow;

  getwindowrect(hwnd, r);

  wi := r.Right - r.Left;
  he := r.Bottom - r.Top;

  if wi <> 0 then
  begin
    result.Width := wi;
    result.Height := he;
    hd := getdc(getdesktopwindow);
    bitblt(result.Canvas.Handle, 0, 0, wi, he, hd, r.Left, r.Top, SRCCOPY);
    ReleaseDC(getdesktopwindow, hd)
  end;
end;

procedure TMain.DoScreenShot(tipo: ttiposcreen);
var
  bmp: tbitmap;
  filename: string;
  tempo: tsystemtime;
begin
  bmp := PrendiSchermo(tipo);

  getsystemtime(tempo);
  filename := inttostr(tempo.wDay) + '-' + inttostr(tempo.wMonth) + '-' + inttostr(tempo.wYear)
    + ' - ' + inttostr(tempo.wHour) + '.' + inttostr(tempo.wMinute);

  case imp.formato of
    fjpeg:
      begin
        filename := filename + '.jpg';
        SaveDialog1.Filter := 'Jpeg Format|*.jpg';
      end;
    fbitmap:
      begin
        filename := filename + '.bmp';
        SaveDialog1.Filter := 'Bitmap Format|*.bmp';
      end;
    fpng:
      begin
        filename := filename + '.png';
        SaveDialog1.Filter := 'Portable Network Graphic Format|*.png';
      end;
  end;

  case tipo of
    completo:
      begin
        filename := 'Full ' + filename;
        SaveDialog1.Title := capcompleto;
      end;
    finestra:
      begin
        filename := 'Window ' + filename;
        SaveDialog1.Title := capcompleto;
      end;
  end;

  if (imp.DefDir <> '') and (imp.usedefdir) then
  begin
    filename := imp.DefDir + '\' + filename;
  end
  else
  begin
    SaveDialog1.filename := filename;
    if SaveDialog1.Execute then
      filename := SaveDialog1.filename
    else
    begin
      bmp.Free;
      exit;
    end;
  end;
  salva(bmp, filename, imp.formato, imp.sign);
  bmp.Free;
end;


function TMain.salva(tb: tbitmap; filename: string; formato: tformato; sign: boolean = true): tmemorystream;
var
  c: TJpegImage;
  bit, bmp: tfastbmp;
  PNG: TPNGObject;
  wi, he: integer;
begin
  result := nil;

  if imp.scala then
  begin
    wi := tb.Width * imp.scalap div 100;
    he := tb.Height * imp.scalap div 100;
  end
  else
  begin
    wi := tb.Width;
    he := tb.Height;
  end;

  bmp := tfastbmp.CreateFromhWnd(tb.Handle);
  bit := tfastbmp.Create(wi, he);

  case imp.filtro of
    0: bmp.Resample(bit, SplineFilter, 2);
    1: bmp.Resample(bit, TriangleFilter, 1);
    2: bmp.resize(bit);
  end;

  bmp.Free;
  bmp := tfastbmp.CreateCopy(bit);
  bit.Free;
  tb.Height := he;
  tb.Width := wi;

  if formato = fbitmap then
    tb.PixelFormat := imp.QualitaBmp;

  bmp.Draw(tb.Canvas.Handle, 0, 0);
  bmp.Free;

  if sign then
  begin
    tb.Canvas.Font.Style := [fsbold];
    tb.Canvas.TextOut(5, he - (tb.Canvas.TextHeight(firma)) - 5, firma);
  end;

  case formato of
    fbitmap: tb.SaveToFile(filename);
    fjpeg:
      begin
        tb.PixelFormat := pf24bit;
        c := TJpegImage.Create;
        c.Assign(tb);
        c.CompressionQuality := imp.QualitaJpeg;
        result := tmemorystream.Create;
        c.savetostream(result);
//        c.SaveToFile(filename);
        c.Free;
      end;
    fpng:
      begin
        PNG := TPNGObject.Create;
        PNG.Assign(tb);
        result := tmemorystream.Create();
        PNG.savetostream(result);
        //PNG.SaveToFile(filename);
        PNG.Free;
      end;
  end;
end;

procedure TMain.scalackClick(Sender: TObject);
var
  e: boolean;
begin
  e := scalack.checked;
  scalavalore.Enabled := e;
  SpinButton2.Enabled := e;
end;

procedure TMain.SelectFolderClick(Sender: TObject);
var
  s: string;
begin
  if GetFolderDialog(Application.Handle, 'Select a folder', s) then
    DefDir.Text := s;
end;

procedure TMain.ServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  stream: tmemorystream;
  bmp: tbitmap;
  function login: boolean;
  begin
    result := false;
    if (ARequestInfo.AuthUsername = 'marco') and (ARequestInfo.AuthPassword = 'marco') then
    begin
      result := true;
    end
    else
    begin
      aresponseinfo.WriteContent;
      aresponseinfo.CloseSession;
    end;
  end;

begin
//  AResponseInfo.AuthRealm := 'WebScreenshot Login';
  if ARequestInfo.Document = '/screen.png' then
  begin
//    if not login then exit;
    bmp := PrendiSchermo(finestra);
    stream := salva(bmp, '', fpng, true);
    bmp.Free;
    AResponseInfo.ContentType := 'image/png';
    AResponseInfo.ContentStream := stream;
    AResponseInfo.WriteContent;
//  stream.Free; FATTO DA WRITECONTENT DIOBONO!
  end
  else
    if ARequestInfo.Document = '/index.htm' then
    begin
//      if not login then exit;
      AResponseInfo.ContentText := indexpage;
      AResponseInfo.ContentType := 'text/html';
      AResponseInfo.WriteContent;
    end else
    begin
      AResponseInfo.ContentText := 'NOT FOUND (e non troverai nient''altro, inutile che provi.)';
      AResponseInfo.WriteContent;
    end;

end;

procedure TMain.SpinButton1DownClick(Sender: TObject);
var
  valore: integer;
begin
  valore := strtointdef(Qualitajpegvalore.Text, 75);
  if valore > 10 then
    Qualitajpegvalore.Text := inttostr(valore - 1);
end;

procedure TMain.SpinButton1UpClick(Sender: TObject);
var
  valore: integer;
begin
  valore := strtointdef(Qualitajpegvalore.Text, 75);
  if valore < 100 then
    Qualitajpegvalore.Text := inttostr(valore + 1);
end;

procedure TMain.SpinButton2DownClick(Sender: TObject);
var
  valore: integer;
begin
  valore := strtointdef(scalavalore.Text, 75);
  if valore > 1 then
    scalavalore.Text := inttostr(valore - 1);
end;

procedure TMain.SpinButton2UpClick(Sender: TObject);
var
  valore: integer;
begin
  valore := strtointdef(scalavalore.Text, 75);
  if valore < 1000 then
    scalavalore.Text := inttostr(valore + 1);
end;

end.

