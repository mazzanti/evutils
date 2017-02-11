unit FormFiltri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TFFiltri = class(TForm)
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
  private
  public
    NomeFile: string;
  protected
  end;

var
  FFiltri: TFFiltri;

implementation

{$R *.dfm}

procedure TFFiltri.BitBtn1Click(Sender: TObject);
begin
  Memo1.Lines.SaveToFile(NomeFile);
end;

end.

