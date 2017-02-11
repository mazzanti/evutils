unit MainWS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFWindowSpecialist = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    txtleft: TEdit;
    txttop: TEdit;
    txtwidth: TEdit;
    txtheight: TEdit;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button3: TButton;
    GroupBox2: TGroupBox;
    ListBox2: TListBox;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button17: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    CheckBox1: TCheckBox;
    tautopos: TTimer;
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure twinTimer(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private

  public
    { Public declarations }
    procedure settaposizioni;
  end;

var
  FWindowSpecialist: TFWindowSpecialist;
  indice: byte = 0;

implementation

{$R *.dfm}

// Save description of all active windows to listbox

function EnumWindowsProc(Wnd: HWND; lParam: lParam): BOOL; stdcall;
var
  keneso: array[0..200] of Char;
begin
  if (IsWindowVisible(Wnd) or IsIconic(wnd)) and
    ((GetWindowLong(Wnd, GWL_HWNDPARENT) = 0) or
    (GetWindowLong(Wnd, GWL_HWNDPARENT) = GetDesktopWindow)) and
    (GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_TOOLWINDOW = 0) then
  begin
    GetWindowText(Wnd, keneso, 256);
    if keneso <> 'GDI+ Window' then
      FWindowSpecialist.Listbox2.Items.Append(keneso);
  end;
end;

procedure wincentra(HND: integer);
var L, T: integer;
begin
 //getwindowrect(Hwnd);
  setwindowpos(
    HND,
    0,
    L,
    T,
    0,
    0,
    SWP_NOSIZE
    );
end;

procedure winpos(HND, L, T: integer);
begin
//
  setwindowpos(
    HND,
    0,
    L,
    T,
    0,
    0,
    SWP_NOSIZE
    );
end;

function dammihandle(wintitle: string): integer;
begin
  if (findwindow(nil, PAnsiChar(wintitle)) <> 0) then
    result := findwindow(nil, PAnsiChar(wintitle));
end;

procedure TFWindowSpecialist.settaposizioni;
//var
//  finestra: trect; //tpoint;
//  finestra_HWND: integer;
begin
  //settaposizioni
//  getwindowrect(finestra_HWND, finestra);
end;

procedure TFWindowSpecialist.twinTimer(Sender: TObject);
begin
  Listbox2.Clear;
  EnumWindows(@EnumWindowsProc, 1);
end;

procedure TFWindowSpecialist.Button10Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  
  EnableWindow(dammihandle(ListBox1.Items.Strings[indice]), True);
end;

procedure TFWindowSpecialist.Button11Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  ShowWindow(dammihandle(ListBox1.Items.Strings[indice]), SW_HIDE);
end;

procedure TFWindowSpecialist.Button12Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  ShowWindow(dammihandle(ListBox1.Items.Strings[indice]), SW_SHOW);
end;

procedure TFWindowSpecialist.Button13Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  ShowWindow(dammihandle(ListBox1.Items.Strings[indice]), SW_MAXIMIZE);
end;

procedure TFWindowSpecialist.Button14Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  ShowWindow(dammihandle(ListBox1.Items.Strings[indice]), SW_MINIMIZE);
end;

procedure TFWindowSpecialist.Button15Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  ShowWindow(dammihandle(ListBox1.Items.Strings[indice]), SW_RESTORE);
end;

procedure TFWindowSpecialist.Button17Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  CloseWindow(dammihandle(ListBox1.Items.Strings[indice]));
  DestroyWindow(dammihandle(ListBox1.Items.Strings[indice]));
end;

procedure TFWindowSpecialist.Button19Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  SetWindowLong(dammihandle(ListBox1.Items.Strings[indice]), GWL_EXSTYLE, WS_EX_TOOLWINDOW);
end;

procedure TFWindowSpecialist.Button1Click(Sender: TObject);
var finestratext: string;
begin
  finestratext := inputbox('GetHandle', 'Inserisci il titolo finestra', '');
  listbox1.Items.Append(
    inttostr(dammihandle(finestratext))
  // + ' -> ' +
//    finestratext
    );
end;

procedure TFWindowSpecialist.Button20Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  SetWindowLong(dammihandle(ListBox1.Items.Strings[indice]), GWL_EXSTYLE, GWL_EXSTYLE);
end;

procedure TFWindowSpecialist.Button21Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  SetWindowPos(dammihandle(ListBox1.Items.Strings[indice]), HWND_TOPMOST, 0, 0, 0, 0, 1);
end;

procedure TFWindowSpecialist.Button22Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  SetWindowPos(dammihandle(ListBox1.Items.Strings[indice]), HWND_NOTOPMOST, 0, 0, 0, 0, 1);
end;

procedure TFWindowSpecialist.Button3Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;

//    SetWindowPos(dammihandle(ListBox1.Items.Strings[ListBox1.ItemIndex]),HWND_NOTOPMOST,strtoint(txtleft.text),strtoint(txttop.text),                 0,0,0{SWP_NOSIZE});
  winpos(dammihandle(ListBox1.Items.Strings[indice]), strtoint(txtleft.text), strtoint(txttop.text));
end;

procedure TFWindowSpecialist.Button4Click(Sender: TObject);
var
  wnd: cardinal;
  wndtxt: array[0..255] of char;
  txtstr: string;
  wndhwnd: integer;
begin
  hide;
  sleep(3000);
  wnd := GetForegroundWindow; // ottengo la finestra attiva
  GetWindowText(wnd, @wndtxt, sizeof(wndtxt)); // ottengo il suo caption
  txtstr := wndtxt;
  wndhwnd := findwindow(nil, PAnsiChar(txtstr)); // ottengo il suo handle
 //---
  listbox1.Items.Append(
//    inttostr(wndhwnd) + ' -> ' +
    wndtxt
    );
  show;
end;

procedure TFWindowSpecialist.Button5Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
//  if ListBox1.Items.Strings[indice]='' then exit;

  listbox1.Items.Delete(indice);
end;

procedure TFWindowSpecialist.Button6Click(Sender: TObject);
begin
  hide;
end;

procedure TFWindowSpecialist.Button7Click(Sender: TObject);
begin
  Listbox2.Clear;
  EnumWindows(@EnumWindowsProc, 1);
end;

procedure TFWindowSpecialist.Button8Click(Sender: TObject);
begin
  if ListBox2.ItemIndex < 0 then exit;
  listbox1.Items.Append(ListBox2.Items.Strings[ListBox2.ItemIndex]);
end;

procedure TFWindowSpecialist.Button9Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then indice := ListBox1.ItemIndex;
  if ListBox1.Items.Count = 0 then exit;
  if ListBox1.Items.Strings[indice]='' then exit;
  EnableWindow(dammihandle(ListBox1.Items.Strings[indice]), False);
end;

procedure TFWindowSpecialist.FormShow(Sender: TObject);
begin
  Listbox2.Clear;
  EnumWindows(@EnumWindowsProc, 1);
end;

end.

