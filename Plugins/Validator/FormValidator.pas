unit FormValidator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TFValidator = class(TForm)
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    StatusBar1: TStatusBar;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Edit2: TEdit;
    Button2: TButton;
    Image1: TImage;
    Button3: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FValidator: TFValidator;

implementation

{$R *.dfm}

Function CheckPIVA(Const Codice:string):boolean;
Var
 c, j, i : integer;
begin
 Result := False;
 if Length(Codice) <> 11 then Exit;
 for i := 1 to Length(Codice) do
  if not (Codice[i] in ['0'..'9']) then Exit;

 j := 0;
 c := 0;
 for i := 1 to 10 do begin
  if Odd(i) then begin
   j := j + Ord(Codice[i]) - 48
  end else begin
   c := 2 * (Ord(Codice[i]) - 48);
   j := j + (c div 10) + (c mod 10);
  end;
 end;

 c := j mod 10;
 if c <> 0 then c := 10 - c;
 if (Codice[11] = Chr(c + 48)) then Result := True;
end; //CheckPIVA

Function CheckCF(Const ToCheck:string):Boolean;
Const
 DatiDiControlloDispari : array['0'..'Z'] of byte = (
  1,0,5,7,9,13,15,17,19,21,
  0,0,0,0,0,0,0,
  1,0,5,7,9,13,15,17,19,21,2,4,18,20,11,
   3,6,8,12,14,16,10,22,25,24,23
 );
 DatiDiControlloPari : array['0'..'Z'] of byte = (
  0,1,2,3,4,5,6,7,8,9,
  0,0,0,0,0,0,0,
  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
   16,17,18,19,20,21,22,23,24,25
 );
Var
 i, k : integer;
begin
 if Length(ToCheck) <> 16 then Abort;
 k := 0;
 for i := 1 to 15 do begin
  if Odd(i) then
   Inc(k, DatiDiControlloDispari[ToCheck[i]])
  else
   Inc(k, DatiDiControlloPari[ToCheck[i]]);
 end;
 Result := (chr(65 + k mod 26) = ToCheck[16]);
end; //CheckCF

procedure TFValidator.Button1Click(Sender: TObject);
begin
 if CheckPIVA(Edit1.Text) then
  statusbar1.Panels[0].Text:='Codice autentico.'
 else
  statusbar1.Panels[0].Text:='Codice falso.';
end;

procedure TFValidator.Button2Click(Sender: TObject);
begin
 if CheckCF(Edit2.Text) then
  statusbar1.Panels[0].Text:='Codice autentico.'
 else
  statusbar1.Panels[0].Text:='Codice falso.';
end;

procedure TFValidator.Button3Click(Sender: TObject);
begin
 FValidator.Close;
end;

procedure TFValidator.FormShow(Sender: TObject);
begin
 setforegroundwindow(self.Handle);
end;

end.
