unit formserializator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  sndkey32, ExtCtrls
  , ClipBrd, jpeg, XPMan, ComCtrls;

type
  Tfserializator = class(TForm)
    Image1: TImage;
    Button1: TButton;
    Image2: TImage;
    Label3: TLabel;
    Label5: TLabel;
    fullserial1: TEdit;
    fullserial2: TEdit;
    Label6: TLabel;
    Button2: TButton;
    statusbar: TStatusBar;
    GroupBox1: TGroupBox;
    lstSerials: TListBox;
    btnAddSerial: TButton;
    btnRemoveSerial: TButton;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    cektab: TCheckBox;
    cboTimer: TComboBox;
    btnSerialize: TButton;
    directserial: TEdit;
    chkLower: TCheckBox;
    tint: TTimer;
    btnslist: TButton;
    Label1: TLabel;
    procedure btnslistClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure tintTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSerializeClick(Sender: TObject);

    function sostituisci(culo: string; tabbiz: boolean): string;
    function scrivi(cio: string): boolean;
  private
    { Private declarations }
    hwHint: THintWindow;
    procedure CreateHint;
    procedure ShowHint({pt : TPoint; }sText: string);
    procedure DestroyHint;
  public
    { Public declarations }
  end;

var
  fserializator: Tfserializator;

implementation

{$R *.dfm}

const
  EXPANDED = 400;
  SIZEDIFF = 200;

var
 // SERIAL:string;
  titolofinestra: string;
  //per la finestra corrente
//  CharArrayPen,
  CharArray: array[0..MAX_PATH] of Char;
  dwResult: DWORD;
  sex: byte;
  cti: byte = 0;

function _titolofinestracorrente: string;
begin
  if SendMessageTimeout(GetForegroundWindow, WM_GETTEXT, Sizeof(CharArray),
    integer(@CharArray), SMTO_ABORTIFHUNG or SMTO_BLOCK, 1000, dwResult) <> 0
    then
  begin
    result := CharArray;
  end;
end;

function Tfserializator.sostituisci(culo: string; tabbiz: boolean): string;
var
  c: byte;
  tmp, str: string;
begin
  c := 0;
// if copy(culo,1,1)=' ' then culo:=copy(culo,2,length(culo)-1);
  repeat
    if c >= length(culo) then break;
    c := c + 1;
    tmp := copy(culo, c, 1);
    if (tmp = '-') or (tmp = ' ') then
    begin
      if tabbiz then str := str + '{TAB}'
        ;
    end else str := str + tmp;

  until c = length(culo);
  result := str;
end;

procedure Tfserializator.tintTimer(Sender: TObject);
begin
  if sex <> 1 then
    ShowHint({punto, }inttostr(sex) + ^j + 'seconds left for autocompile')
  else
    ShowHint({punto, }inttostr(sex) + ^j + 'second left for autocompile')
      ;
  if sex = 0 then
  begin
    tint.Enabled := false;
    DestroyHint;
    if cektab.checked then
      scrivi(sostituisci(fullserial1.text + '{TAB}' + fullserial2.Text, true))
    else
      scrivi(sostituisci(fullserial1.text + fullserial2.Text, false));
    fullserial1.Enabled := true; fullserial2.Enabled := true;
    fullserial1.clear; fullserial2.clear;
    exit;
  end;
  sex := sex - 1;
end;

procedure Tfserializator.btnSerializeClick(Sender: TObject);
var c: byte;
begin
//controllo che nei serial inseriti non vi siano dei caratteri
//strani tipo carriage return...
  for c := 1 to length(directserial.Text) do
  begin
    if (directserial.Text[c] = #13) or (directserial.Text[c] = #10) then
    begin directserial.Clear; exit; end;
  end;


  for c := 1 to length(fullserial1.Text) do
  begin
    if (fullserial1.Text[c] = #13) or (fullserial1.Text[c] = #10) then
    begin fullserial1.Clear; exit; end;
  end;

  for c := 1 to length(fullserial2.Text) do
  begin
    if (fullserial2.Text[c] = #13) or (fullserial2.Text[c] = #10) then
    begin fullserial2.Clear; exit; end;
  end;

  if fullserial1.Text = '' then exit;
  if fullserial1.Text[1] = ' ' then exit;

  if not (chkLower.Checked) then
  begin
    fullserial1.Text := uppercase(fullserial1.Text);
    fullserial2.Text := uppercase(fullserial2.Text);
  end;

  CreateHint;
  sex := strtoint(formserializator.fserializator.cbotimer.text);
  fserializator.Visible := false; //nasconde il serializator
  fullserial1.Enabled := false; fullserial2.Enabled := false;
//  tclip.Enabled:=false;
  tint.Enabled := true;
//  sleep(strtoint(formserializator.fserializator.cbotimer.text)*1000);
end;

procedure Tfserializator.btnslistClick(Sender: TObject);
begin
  if fserializator.Height > EXPANDED then
  begin
    fserializator.Height := fserializator.Height - SIZEDIFF;
    btnslist.Caption := 'Manage serials';
  end else
  begin
    fserializator.Height := fserializator.Height + SIZEDIFF;
    btnslist.Caption := 'Hide list';
  end;
end;

procedure Tfserializator.Button1Click(Sender: TObject);
begin
  hide;
end;

procedure Tfserializator.Button2Click(Sender: TObject);
begin
  fullserial1.Clear; fullserial2.Clear; cti := 1;
end;

procedure Tfserializator.FormShow(Sender: TObject);
begin
// tclip.Enabled:=true;
  setforegroundwindow(self.Handle);
end;

function tfserializator.scrivi(cio: string): boolean;
begin
  titolofinestra := _titolofinestracorrente;
  AppActivate(PChar(titolofinestra));
  SendKeys(PChar(cio), True);
// fserializator.Visible:=true;
  result := true;
end;

procedure tfserializator.CreateHint;
begin
  hwHint := THintWindow.Create(fserializator);
end;

procedure tfserializator.ShowHint({pt : TPoint;}sText: string);
var pt: tpoint;
begin
  GetCursorPos(pt);
  pt.Y := pt.Y + 30;
  hwHint.ActivateHint(Rect(pt.x, pt.y, pt.x + hwHint.Canvas.TextWidth(sText) + 10,
    pt.y + (hwHint.Canvas.TextHeight(sText)) * 2), sText);
end;

procedure tfserializator.DestroyHint;
begin
  hwHint.ReleaseHandle;
  hwHint.Destroy;
end;

procedure tfserializator.FormCreate(Sender: TObject);
begin
//  clipboard.Clear;
//  CreateHint;
end;

procedure Tfserializator.FormDestroy(Sender: TObject);
begin
//  DestroyHint;
end;

end.

