unit formagreement;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFSAgreement = class(TForm)
    Label1: TLabel;
    btnokay: TButton;
    procedure btnokayClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSAgreement: TFSAgreement;

implementation

{$R *.dfm}

uses formserializator;

procedure TFSAgreement.btnokayClick(Sender: TObject);
begin
 fserializator.show;
 fsagreement.Hide;
end;

procedure TFSAgreement.FormShow(Sender: TObject);
begin
 setforegroundwindow(self.Handle); 
end;

end.
