unit FormCodiceFiscale;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls
  , codfiscimp
  ;

type
  TFCodFisc = class(TForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    Comune: TComboBox;
    cognome: TEdit;
    nome: TEdit;
    sesso: TComboBox;
    mese: TComboBox;
    giorno: TComboBox;
    Label1: TLabel;
    codicillo: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Image1: TImage;
    Button2: TButton;
    Label10: TLabel;
    anno: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure codicilloChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    procedure noerr(Sender: Tobject; E: Exception);
  end;

var
  FCodFisc: TFCodFisc;
  x , i   : integer  ;

implementation

{$R *.dfm}


procedure TFCodFisc.Button1Click(Sender: TObject);
begin            { passaggio dati globali }
//fai un check
if (cognome.Text='')OR(nome.Text='')OR(sesso.Text='')OR(anno.Text='')OR(mese.Text='')
OR(giorno.Text='')OR(comune.Text='') then
 begin showmessage('Non posso calcolare, ci sono dei campi mancanti!'); exit; end;
//controllo comune


 codicillo.Text:='';

 codfiscimp.cognome:=Cognome.Text;     { cognome }
 codfiscimp.nome:=nome.Text;           { nome }
 codfiscimp.anno:=Anno.Text;           { anno }
 val(mese.Text,codfiscimp.g,x);        { mese }
 val(giorno.Text,codfiscimp.gio,x);    { giorno }
 if Sesso.Text='Maschio' then codfiscimp.maschio:=true   { sesso }
 else codfiscimp.maschio:=false;
 codfiscimp.comu:=comune.text;

 Main_control();
 for i:=1 to 16 do
  codicillo.Text:=codicillo.text+codfiscimp.codice[i];
end;

procedure TFCodFisc.Button2Click(Sender: TObject);
begin
 FCodFisc.Close;
end;

procedure TFCodFisc.codicilloChange(Sender: TObject);
begin
UPPERCASE(codicillo.Text);
end;

procedure TFCodFisc.noerr(Sender: Tobject; E: Exception);
begin
//
end;

procedure TFCodFisc.FormCreate(Sender: TObject);
begin
 Application.OnException:=noerr;
end;

procedure TFCodFisc.FormShow(Sender: TObject);
var annoattuale,annomax,j:integer;
    tempo:TSystemTime;
const _DIFF = 100;
begin
 setforegroundwindow(self.Handle);
 anno.Clear;
 GetLocalTime(tempo);
 annoattuale:=tempo.wYear;
 if annoattuale>_DIFF then
  annomax:=annoattuale - 100 else annomax:=1;
 for j := annoattuale downto annomax do
  anno.Items.add(inttostr(j)); 
end;

end.
