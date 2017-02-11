//{$DEFINE DEV}

unit FormAutoShut;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan, Spin, Balloon
  , shellapi;

type
  TFautoshutdown = class(TForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    GroupBox2: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Image1: TImage;
    CheckBox1: TCheckBox;
    temp: TTimer;
    Edit2: TEdit;
    Edit3: TEdit;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure tempTimer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    function LoadLang: boolean; stdcall;
    function TraduciForm(lingua: integer): boolean; stdcall;
    procedure azione;
  public
    { Public declarations }
  end;

var
  Fautoshutdown: TFautoshutdown;
  _QUANDO: integer;
  _RESTANTE: integer;
  _CHE: string;

const
//  giorno  :  Integer = 1000 * 60 * 60 * 24;
  ora: Integer = 60 * 60;
  minuto: Integer = 60;
  secondo: Integer = 1;

implementation

{$R *.dfm}
uses evutilsLanguages
  , evutilsBaloon
//,Dutils
  , WinShutty
  , FormAlert;

function TFautoshutdown.TraduciForm(lingua: integer): boolean; stdcall;
var
  Buff: array[0..255] of Char;
  Base: integer;
begin
  result := true;
  base := (lingua + 1) * 1000;
  LoadString(HInstance, base + 001, Buff, SizeOf(Buff));
  GroupBox1.Caption := Buff; GroupBox1.Refresh;
  LoadString(HInstance, base + 002, Buff, SizeOf(Buff));
  RadioButton1.Caption := Buff; RadioButton1.Refresh;
  LoadString(HInstance, base + 003, Buff, SizeOf(Buff));
  RadioButton2.Caption := Buff; RadioButton2.Refresh;
  LoadString(HInstance, base + 004, Buff, SizeOf(Buff));
  GroupBox2.Caption := Buff; GroupBox2.Refresh;
  LoadString(HInstance, base + 005, Buff, SizeOf(Buff));
  RadioButton3.Caption := Buff; RadioButton3.Refresh;
  LoadString(HInstance, base + 006, Buff, SizeOf(Buff));
  RadioButton4.Caption := Buff; RadioButton4.Refresh;
  LoadString(HInstance, base + 007, Buff, SizeOf(Buff));
  RadioButton5.Caption := Buff; RadioButton5.Refresh;
  LoadString(HInstance, base + 008, Buff, SizeOf(Buff));
  RadioButton6.Caption := Buff; RadioButton6.Refresh;
  LoadString(HInstance, base + 009, Buff, SizeOf(Buff));
  CheckBox1.Caption := Buff; CheckBox1.Refresh;
  LoadString(HInstance, base + 010, Buff, SizeOf(Buff));
  Button1.Caption := Buff; Button1.Refresh;
  LoadString(HInstance, base + 011, Buff, SizeOf(Buff));
  Button2.Caption := Buff; Button2.Refresh;
  LoadString(HInstance, base + 012, Buff, SizeOf(Buff));
  CheckBox2.Caption := Buff; CheckBox2.Refresh;
end;

procedure TFautoshutdown.Button1Click(Sender: TObject);
begin
  if (Edit1.Text = '') or (strtoint(Edit1.Text) < 0) (* or (Edit1.Text = '0')*) then begin Edit1.Text := '0'; end;
  if (Edit2.Text = '') or (strtoint(Edit2.Text) < 0) or (Edit2.Text = '0') then begin Edit2.Text := '00'; end;
  if (Edit3.Text = '') or (strtoint(Edit3.Text) < 0) or (Edit3.Text = '0') then begin Edit3.Text := '00'; end;
  if (RadioButton1.Checked) then
  begin
    if (Edit1.Text = '00') and (Edit2.Text = '00') and (Edit3.Text = '00') then exit;
    if (Edit1.Text = '0') and (Edit2.Text = '00') and (Edit3.Text = '00') then exit;
  end
  else begin
    if (Edit1.Text = '00') then Edit1.Text := '0';
    if (strtoint(Edit2.Text) < 10) then Edit2.Text := '0' + Edit2.Text;
    if (strtoint(Edit3.Text) < 10) then Edit3.Text := '0' + Edit3.Text;
(*    if (Edit2.Text = '00') then Edit2.Text := '0';
    if (Edit3.Text = '00') then Edit3.Text := '0';  *)
  end;

  if (RadioButton1.Checked) then
  begin
    _QUANDO := strtoint(Edit1.Text) * 60 * 60
      + strtoint(Edit2.Text) * 60
      + strtoint(Edit3.Text);
  end;
  if RadioButton3.Checked then
    _CHE := 'Shutdown';
  if RadioButton4.Checked then
    _CHE := 'Reboot';
  if RadioButton5.Checked then
    _CHE := 'Logoff';
  if RadioButton6.Checked then
    _CHE := 'Standby';

  FAlert.Button1.Caption := 'NO ' + Uppercase(_CHE) + '!';
  if (RadioButton1.Checked) then
  begin
    Notifica('AutoShutdownX', PAnsiChar(_CHE + ' in ' +
      Edit1.Text + 'H, ' + Edit2.Text + 'm, ' + Edit3.Text + 'sec...'
      ));
  end;
  if (RadioButton2.Checked) then
  begin
    Notifica('AutoShutdownX', PAnsiChar(_CHE + ' @ ' +
      Edit1.Text + '.' + Edit2.Text + '.' + Edit3.Text + '.'
      ));
  end;
  temp.Enabled := true;
  button1.Enabled := false; checkbox1.Enabled := false; checkbox2.Enabled := false;
  GroupBox1.Enabled := false; GroupBox2.Enabled := false;
{$IFNDEF DEV}
  Fautoshutdown.Close;
{$ENDIF}
end;

procedure TFautoshutdown.Button2Click(Sender: TObject);
begin
  if not (temp.Enabled) then Fautoshutdown.Close;
  temp.Enabled := false; button1.Enabled := true; //Fautoshutdown.Close;
  checkbox1.Enabled := true; checkbox2.Enabled := true;
  GroupBox1.Enabled := true; GroupBox2.Enabled := true;
end;

procedure TFautoshutdown.FormCreate(Sender: TObject);
begin
  LoadLang;
end;

procedure TFautoshutdown.FormShow(Sender: TObject);
begin
  setforegroundwindow(self.Handle);
end;

function TFautoshutdown.LoadLang: boolean; stdcall;
begin
  result := true;
  case language of
    0: TraduciForm(0);
    1: TraduciForm(1);
  else TraduciForm(0); //altrimenti metto default
  end;
end;

procedure TFautoshutdown.azione;
begin
{$IFDEF DEV}
  showmessage('azione');
{$ELSE}
  if RadioButton3.Checked then
    MyExitWindows(EWX_POWEROFF or EWX_FORCE);
  if RadioButton4.Checked then
    MyExitWindows(EWX_REBOOT or EWX_FORCE);
  if RadioButton5.Checked then
    MyExitWindows(EWX_LOGOFF or EWX_FORCE);
  if RadioButton6.Checked then
    ShellExecute(Handle, 'open', 'rundll32.exe', PChar('Powrprof.dll,SetSuspendState'), nil, SW_SHOWNORMAL);
{$ENDIF}
end;

procedure TFautoshutdown.tempTimer(Sender: TObject);
begin
//cosa deve fare temp ogni secondo
  if (_QUANDO = 10 + 1) and (not (CheckBox1.Checked)) then FAlert.Show;
  if (_QUANDO <= 11) and (not (CheckBox1.Checked)) and (not (RadioButton2.Checked)) then
  begin
    FAlert.Caption := inttostr(_QUANDO - 1) + 'sec...';
    FAlert.Caption := _CHE + ' in ' + FAlert.Caption;
    Notifica('AutoShutdownX', PAnsiChar(_CHE + ' in ' + inttostr(_QUANDO - 1) + 'sec...'));
  end;

  if RadioButton2.Checked then
  begin
    if TimeToStr(Now) = Edit1.Text + '.' + Edit2.Text + '.' + Edit3.Text then
    begin
      temp.Enabled := false; button1.Enabled := true; checkbox1.Enabled := true; checkbox2.Enabled := true;
      GroupBox1.Enabled := true; GroupBox2.Enabled := true;
      if (CheckBox1.Checked) (* and (not (CheckBox2.Checked))*) then
      begin
        if MessageBox(0, 'Shutdown?', 'AutoshutdownX', +mb_YesNo + mb_ICONWARNING) = 6 then azione;
      end else azione;
    end;
    exit;
  end;

  if _QUANDO > 0 then
  begin
    _QUANDO := _QUANDO - 1;
    _RESTANTE := _QUANDO;
    Edit1.Text := inttostr(_RESTANTE div ora);
    Dec(_RESTANTE, strtoint(Edit1.Text) * ora);
    Edit2.Text := inttostr(_RESTANTE div minuto);
    Dec(_RESTANTE, strtoint(Edit2.Text) * minuto);
    Edit3.Text := inttostr(_RESTANTE div secondo);
    Dec(_RESTANTE, strtoint(Edit3.Text) * secondo);
  end;


  if _QUANDO = 0 then
  begin
    temp.Enabled := false; button1.Enabled := true; checkbox1.Enabled := true; checkbox2.Enabled := true;
    GroupBox1.Enabled := true; GroupBox2.Enabled := true;

    if RadioButton1.Checked then
    begin
      if CheckBox1.Checked then
      begin
        if MessageBox(0, 'Shutdown?', 'AutoshutdownX', +mb_YesNo + mb_ICONWARNING) = 6 then azione;
      end else azione;
    end;

  end;
end;

procedure TFautoshutdown.RadioButton1Click(Sender: TObject);
begin
  CheckBox2.Enabled := true;
end;

procedure TFautoshutdown.RadioButton2Click(Sender: TObject);
begin
  CheckBox2.Enabled := false;
end;

end.

