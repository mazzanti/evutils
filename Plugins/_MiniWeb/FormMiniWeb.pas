unit FormMiniWeb;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, OleCtrls, SHDocVw;

type
  TFMiniWeb = class(TForm)
    web: TWebBrowser;
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Button1: TButton;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMiniWeb: TFMiniWeb;

implementation

{$R *.dfm}

procedure TFMiniWeb.Button1Click(Sender: TObject);
begin
 web.Navigate(Edit1.Text);
end;

end.
