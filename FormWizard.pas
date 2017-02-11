unit FormWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  Tfwizard = class(TForm)
    PageControl1: TPageControl;
    Image1: TImage;
    Shape1: TShape;
    TabSheet1: TTabSheet;
    Panel1: TPanel;
    Indietro: TButton;
    Avanti: TButton;
    Salta: TButton;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    Image2: TImage;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    procedure SaltaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AvantiClick(Sender: TObject);
    procedure muovipagina;
    procedure IndietroClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;    
  end;

var
  fwizard: Tfwizard;
  passo: byte = 0;

implementation

{$R *.dfm}

//per l'effetto ombreggiatura

procedure Tfwizard.muovipagina;
begin
 case passo of
  1 : pagecontrol1.ActivePage:=TabSheet1;
  2 : pagecontrol1.ActivePage:=TabSheet2;
  3 : pagecontrol1.ActivePage:=TabSheet3;
  4 : pagecontrol1.ActivePage:=TabSheet4;
  else
  begin
   pagecontrol1.ActivePage:=TabSheet1; passo:=1;
  end;
 end;
end;

procedure Tfwizard.AvantiClick(Sender: TObject);
begin
 inc(passo);
 muovipagina;
end;

procedure Tfwizard.CreateParams(var Params: TCreateParams);
const
  CS_DROPSHADOW = $00020000;
begin
  inherited;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;
end;

procedure Tfwizard.FormShow(Sender: TObject);
begin
 passo:=0;
 pagecontrol1.ActivePage:=TabSheet1;
 passo:=1;
end;

procedure Tfwizard.IndietroClick(Sender: TObject);
begin
 dec(passo);
 muovipagina;
end;

procedure Tfwizard.SaltaClick(Sender: TObject);
begin
 hide;
end;

end.
