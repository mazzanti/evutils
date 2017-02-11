unit JJGetChar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFJJGetChar = class(TForm)
    Label1: TLabel;
    procedure Label1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FJJGetChar: TFJJGetChar;
  tastotmp: integer;

implementation

uses JJMain;

{$R *.dfm}

procedure TFJJGetChar.FormHide(Sender: TObject);
begin
  if Label1.Caption = 'premi il tasto di attivazione' then
  begin
    FJumpJump.key.Text := inttostr(tastotmp);
  end
  else
  begin
    FJumpJump.keyemu.Text := chr(tastotmp);
  end;

end;

procedure TFJJGetChar.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  tastotmp := (key);
  FJJGetChar.hide;
end;

procedure TFJJGetChar.Label1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not(Label1.Caption = 'premi il tasto di attivazione') then exit;
  case Button of
    mbLeft: tastotmp := 1;
    mbRight: tastotmp := 2;
    mbMiddle: tastotmp := 4;
  end;
  FJJGetChar.hide;
end;

end.

