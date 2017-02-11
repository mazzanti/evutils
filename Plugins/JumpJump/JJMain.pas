unit JJMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TFJumpJump = class(TForm)
    tkey: TTimer;
    keylist: TComboBox;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txtinterval: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    key: TEdit;
    Label7: TLabel;
    keyemu: TEdit;
    keytoemu: TComboBox;
    Label8: TLabel;
    Label9: TLabel;
    Image1: TImage;
    procedure keytoemuChange(Sender: TObject);
    procedure keylistChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure tkeyTimer(Sender: TObject);
  private
    { Private declarations }
  public
    procedure cambiajumpy;
    procedure dammitasto;
    procedure dammitastoemu;
  end;

var
  FJumpJump: TFJumpJump;
  jumpy: boolean = false;
  interval: integer = 0;
  tastoattivazione: integer;
  tastodaemulare: PAnsiChar;

implementation

{$R *.dfm}

uses sndkey32, JJGetChar;

procedure TFJumpJump.cambiajumpy;
begin
  tkey.Enabled := jumpy;
end;

procedure TFJumpJump.dammitasto;
begin
  FJJGetChar.Label1.Caption := 'premi il tasto di attivazione'; FJJGetChar.Show;
end;

procedure TFJumpJump.dammitastoemu;
begin
  FJJGetChar.Label1.Caption := 'premi il tasto da emulare'; FJJGetChar.Show;
end;

procedure TFJumpJump.keylistChange(Sender: TObject);
begin
  if keylist.Text = 'ALTRO...' then dammitasto;
end;                                                            

procedure TFJumpJump.keytoemuChange(Sender: TObject);
begin
  if keytoemu.Text = 'ALTRO...' then
  begin dammitastoemu; keyemu.Enabled := true; end else keyemu.Enabled := false;
end;

procedure TFJumpJump.Button1Click(Sender: TObject);
begin
  if txtinterval.Text = '' then exit;
  interval := strtoint(txtinterval.Text);
  hide;
end;

procedure TFJumpJump.tkeyTimer(Sender: TObject);
begin
  if keylist.Text = 'ALTRO...' then
    tastoattivazione := strtoint(key.text) else tastoattivazione := keylist.ItemIndex + 1;
  if keytoemu.Text = 'ALTRO...' then
    tastodaemulare := PAnsiChar(keyemu.text) else
  begin
    keyemu.Text := ' ';
    tastodaemulare := ' ';
  end;

  if GetAsyncKeyState(tastoattivazione) < 0 then
  begin
    sendkeys(tastodaemulare, true);    sleep(interval);
  end;
end;
(*
VK_LBUTTON (01)Left mouse button
VK_RBUTTON (02)Right mouse button
VK_MBUTTON (04)Middle mouse button (three-button mouse)
VK_XBUTTON1 (05)Windows 2000/XP: X1 mouse button
VK_XBUTTON2 (06)Windows 2000/XP: X2 mouse button
*)

end.

