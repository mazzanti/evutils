unit About;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.dfm}


procedure TAboutBox.FormShow(Sender: TObject);
begin
  setforegroundwindow(self.Handle);
end;

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
  Close;
end;

end.

