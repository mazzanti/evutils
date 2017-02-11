unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, wininet, Shellapi, CoolTrayIcon, ExtCtrls,
  Menus, Buttons, HtmlParser, inifiles, kutils;

type
  TMain = class(TForm)
    tr: TCoolTrayIcon;
    chtim: TTimer;
    PopupMenu1: TPopupMenu;
    Esci1: TMenuItem;
    AggiungiURL1: TMenuItem;
    N1: TMenuItem;
    Gestione: TMenuItem;
    urllist: TListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    N2: TMenuItem;
    Tempo1: TMenuItem;
    About1: TMenuItem;
    N3: TMenuItem;
    Check1: TMenuItem;
    Aggiungi: TBitBtn;
    Filtri: TBitBtn;
    procedure chtimTimer(Sender: TObject);
    procedure FiltriClick(Sender: TObject);
    procedure AggiungiClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Esci1Click(Sender: TObject);
    procedure GestioneClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Tempo1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure urllistDblClick(Sender: TObject);
  private
    procedure MostraPagine;
    procedure CaricaSettings;
  public
  protected
  end;

var
  Main: TMain;
  PATH: string;

const
  FILEINI: string = 'WebNotifier.ini';
const
  PAGESDIR: string = '\WebNotifierPages\';

implementation

uses About, DomCore, Formatter, FormFiltri;

{$R *.dfm}

var
  urls: TStringList;

procedure ReadUrl(hSession: HInternet; const UrlAddr: string; var Dest:
  tmemorystream);
const
  bufferSize = 2048;
var
  buffer: array[0..bufferSize - 1] of char;
//  bytes_read_total: cardinal;
  headers: string;
  NewSession: boolean;
  hFile: HInternet;
  Context, BytesRead: DWORD;
  ReadRes: boolean;
var
  dwBufLen: DWORD;
  ContentSize: DWORD;
  dwIndex: cardinal;
begin
  try
    NewSession := hSession = nil;
    if NewSession then
    begin
      hSession := InternetOpen('SessionName', INTERNET_OPEN_TYPE_PRECONFIG, nil,
        nil, 0);
    end;
    try
      Context := 0;

      hFile := InternetOpenUrl(hSession, pchar(UrlAddr), pchar(headers)
        {NIL/pchar(proxy_auth_header)}, length(headers), INTERNET_FLAG_RELOAD or
        INTERNET_FLAG_KEEP_CONNECTION {INTERNET_FLAG_EXISTING_CONNECT},
        Context);

      dwBufLen := sizeof(ContentSize);
      ContentSize := 0;
      dwIndex := 0;
      HttpQueryInfo(hFile, HTTP_QUERY_CONTENT_LENGTH or HTTP_QUERY_FLAG_NUMBER,
        @ContentSize, dwBufLen, dwIndex);
      if ContentSize = 0 then
        ContentSize := 1; //avoid division by 0

//      bytes_read_total := 0;
      if hFile <> nil then
      try
        repeat
          Fillchar(buffer, length(buffer), 0);
          ReadRes := InternetReadFile(hFile, @buffer, length(buffer),
            BytesRead);
          //dest.Seek(0,0);
          Dest.Write(buffer, BytesRead);
//          Inc(bytes_read_total, BytesRead);
        until (ReadRes) and (BytesRead = 0);
      finally
        //      if not InternetCloseHandle(hFile) then
        //        error := getlasterror;
      end;
    finally
      //    if NewSession then
      //      if not InternetCloseHandle(hSession) then
      //        error := getlasterror;
    end;
  except
  end;
end;


procedure TMain.CaricaSettings;
var
  ini: tinifile;
begin
  ini := tinifile.Create(PATH + '\' + FILEINI);
  chtim.interval := ini.ReadInteger('SETTINGS', 'INTERVAL', 600000);
  ini.free;
end;

procedure CaricaPagine;
var
  ini: tinifile;
  sl: TStringList;
  i: integer;
begin
  sl := TStringList.Create;
  ini := tinifile.Create(PATH + '\' + FILEINI);
  ini.ReadSection('PAGINE', sl);
  urls.Clear;
  for i := 0 to sl.Count - 1 do
  begin
    if pos('URL', sl[i]) = 1 then
      urls.Add(sl[i] + '|' + ini.ReadString('PAGINE', sl[i], ''));
  end;
  ini.free;
end;

procedure TMain.FiltriClick(Sender: TObject);
var
  i: integer;
begin
  if urllist.ItemIndex < 0 then exit;
  i := urllist.ItemIndex;
  FFiltri.NomeFile := PATH + '\' + PAGESDIR + Copy(urls[i], 1, pos('|', urls[i]) - 1) + '.flt';
  FFiltri.Memo1.Clear;
  if fileexists(FFiltri.NomeFile) then
    FFiltri.Memo1.Lines.LoadFromFile(FFiltri.NomeFile);
  FFiltri.showmodal;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  if not fileexists(PATH + '\' + PAGESDIR) then
    createdir(PATH + '\' + PAGESDIR);
  urls := TStringList.Create;
  CaricaPagine;
  CaricaSettings;
  chtim.Enabled := true;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

function ComparePages(var Vecchia: TStringList; var Nuova: TStringList; var Differenze: TStringList; var Filtro: TStringList): boolean;
var
  i, j: integer;
  filtrato: boolean;
begin
  result := false;
  for i := 0 to Nuova.Count - 1 do
  begin
    if Vecchia.IndexOf(Nuova[i]) = -1 then
    begin
      filtrato := false;
      for j := 0 to Filtro.Count - 1 do
        if pos(lowercase(Filtro[j]), lowercase(Nuova[i])) > 0 then
        begin
          filtrato := true;
          break;
        end;
      if not filtrato then
      begin
        result := true;
        Differenze.Add(Nuova[i]);
      end;
    end;
  end;
end;

procedure DumpPage(f: tmemorystream; var L: TStringList);
var
  S: string;
  HtmlDoc: TDocument;
  Formatter: TBaseFormatter;
  n: integer;
  sa, st: string;
  HtmlParser: THtmlParser;
begin
  SetLength(S, f.Size);
  copymemory(@S[1], f.Memory, f.Size);

  HtmlParser := THtmlParser.Create;
  try
    HtmlDoc := HtmlParser.parseString(S)
  finally
    HtmlParser.free
  end;

  Formatter := TTextFormatter.Create;
  try
    st := Formatter.getText(HtmlDoc);
    while pos(#13 + #10, st) > 0 do
    begin
      n := pos(#13 + #10, st);
      sa := Copy(st, 1, n - 1);
      if length(sa) > 0 then
        L.Add(sa);
      Delete(st, 1, n + 1);
    end;
  finally
    Formatter.free
  end;

  HtmlDoc.free;
end;

procedure CheckWebPage(id, link: string);
var
  ms: tmemorystream;
  L, V, D, f: TStringList;
  i: integer;
  S: string;
begin

  ms := tmemorystream.Create;
  ReadUrl(nil, link, ms);
  if ms.Size = 0 then
  begin
    ms.free;
    exit;
  end;
  L := TStringList.Create;
  DumpPage(ms, L);
  ms.free;

  f := TStringList.Create;
  if fileexists(PATH + '\' + PAGESDIR + id + '.flt') then
    f.LoadFromFile(PATH + '\' + PAGESDIR + id + '.flt')
  else
    createdir(PATH + '\' + PAGESDIR);


  if fileexists(PATH + '\' + PAGESDIR + id + '.txt') then
  begin
    V := TStringList.Create;
    V.LoadFromFile(PATH + '\' + PAGESDIR + id + '.txt');
    D := TStringList.Create;
    if ComparePages(V, L, D, f) then
    begin
      for i := 0 to D.Count - 1 do
        S := S + #13 + #10 + D[i];

      case (MessageBox(0, pchar('E'' stato modificato' + #10 + #13 + link +
        #10 + #13 + S + #13 + #10 + 'VISITARE?'), 'ATTENZIONE', MB_YESNOCANCEL or
        MB_ICONWARNING))
        of
        IDYES:
          begin
            L.SaveToFile(PATH + '\' + PAGESDIR + id + '.txt');
            ShellExecute(0, 'open', pchar(link), nil, nil, sw_normal);
          end;
        IDNO:
          begin
            L.SaveToFile(PATH + '\' + PAGESDIR + id + '.txt');
          end;
        IDCANCEL: ;
      end;
    end;
    f.free;
    V.free;
    D.free;
  end
  else
    L.SaveToFile(PATH + '\' + PAGESDIR + id + '.txt');
end;


function ControllaSiti: integer;
var
  i: byte;
  link: string;
begin
  result := 0;
  with Main do
  try
    chtim.Enabled := false;
    i := 0;
    while i < urls.Count do
    begin
      link := Copy(urls[i], pos('|', urls[i]) + 1, length(urls[i]));
      tr.ShowBalloonHint('', 'Controllo ' + link, bitInfo, 10);
      CheckWebPage(Copy(urls[i], 1, pos('|', urls[i]) - 1), link);
      inc(i);
    end;
  finally
    tr.ShowBalloonHint('', 'Fine controllo', bitInfo, 10);
    chtim.Enabled := true;
  end;
end;

procedure TMain.chtimTimer(Sender: TObject);
begin
  StartThread(@ControllaSiti);
end;

procedure TMain.Esci1Click(Sender: TObject);
begin
  Close;
end;

procedure TMain.MostraPagine;
var
  i: integer;
begin
  urllist.items.Clear;
  for i := 0 to urls.Count - 1 do
  begin
    urllist.items.Add(Copy(urls[i], pos('|', urls[i]) + 1, length(urls[i])));
  end;
  urllist.ItemIndex := 0;
end;


procedure TMain.GestioneClick(Sender: TObject);
begin
  chtim.Enabled := false;
  MostraPagine;
  Main.show;
end;

procedure TMain.BitBtn2Click(Sender: TObject);
begin
  chtim.Enabled := true;
  hide;
end;

procedure TMain.AggiungiClick(Sender: TObject);
var
  S: string;
  ini: tinifile;
  V: cardinal;
begin
  S := InputBox('Nuovo URL', 'Inserisci l''URL', '');
  if S <> '' then
  begin
    ini := tinifile.Create(PATH + '\' + FILEINI);
    V := random(high(integer));
    while (ini.ReadString('PAGINE', 'URL' + inttostr(V), '') <> '') do
    begin
      V := random(high(integer));
    end;
    ini.WriteString('PAGINE', 'URL' + inttostr(V), S);
    ini.UpdateFile;
    ini.free;
    CaricaPagine;
    MostraPagine;
  end;
end;

procedure TMain.BitBtn1Click(Sender: TObject);
var
  i: byte;
  ini: tinifile;
begin
  if urllist.ItemIndex < 0 then exit;
  i := urllist.ItemIndex;
  ini := tinifile.Create(PATH + '\' + FILEINI);
  ini.DeleteKey('PAGINE', Copy(urls[i], 1, pos('|', urls[i]) - 1));
  deletefile(PATH + '\' + PAGESDIR + Copy(urls[i], 1, pos('|', urls[i]) - 1) + '.flt');
  ini.UpdateFile;
  ini.free;
  CaricaPagine;
  MostraPagine;
end;

procedure TMain.Tempo1Click(Sender: TObject);
var
  S: string;
  ini: tinifile;
begin
  S := InputBox('Tempo di controllo', 'Inserisci tempo in secondi (corrente: ' +
    inttostr(chtim.interval div 1000) + ')', '');
  if S <> '' then
  begin
    chtim.interval := strtointdef(S, 600) * 1000;
    ini := tinifile.Create(PATH + '\' + FILEINI);
    ini.WriteInteger('SETTINGS', 'INTERVAL', chtim.interval);
    ini.UpdateFile;
    ini.free;
  end;
end;

procedure TMain.About1Click(Sender: TObject);
begin
  AboutBox.show;
end;

procedure TMain.urllistDblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', pchar(urllist.items[urllist.ItemIndex]), nil, nil, sw_normal);
end;

end.

