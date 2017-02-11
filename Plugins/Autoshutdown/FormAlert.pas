unit FormAlert;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFAlert = class(TForm)
    Button1: TButton;
    blend: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure blendTimer(Sender: TObject);
//    procedure CreateParams(var Params: TCreateParams);
  private
    procedure OnTop;
  public
    { Public declarations }
  end;

var
  FAlert: TFAlert;
  j: Byte;

implementation

uses FormAutoShut;

{$R *.dfm}

procedure TFAlert.blendTimer(Sender: TObject);
begin
  if j >= 255 then
  begin blend.Enabled := false; FAlert.AlphaBlendValue := 220; exit; end;

  j := j + 15;
  if j > (15 * 3) then blend.Interval := 100;

  FAlert.AlphaBlendValue := j;
end;

procedure TFAlert.Button1Click(Sender: TObject);
begin
  with Fautoshutdown do
  begin
    if not (temp.Enabled) then Fautoshutdown.Close;
    temp.Enabled := false; button1.Enabled := true; //Fautoshutdown.Close;
    checkbox1.Enabled := true; checkbox2.Enabled := true;
    GroupBox1.Enabled := true; GroupBox2.Enabled := true;
    show;
  end;
  FAlert.Close;
end;

//procedure TFAlert.CreateParams(var Params: TCreateParams);
//begin
//  inherited CreateParams(Params);
//  with Params do begin
//    ExStyle := ExStyle or WS_EX_TOPMOST;
//    WndParent := GetDesktopwindow;
//  end;
//end;

procedure TFAlert.OnTop;
begin
  SetWindowPos(FAlert.handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOSIZE);
end;

procedure TFAlert.FormShow(Sender: TObject);
begin
  onTop;
  blend.Interval := 200;
  FAlert.AlphaBlend := true;
  blend.Enabled := true;
end;

end.

