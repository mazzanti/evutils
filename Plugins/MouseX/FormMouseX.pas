unit FormMouseX;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, inifiles;

type
  TFMouseX = class(TForm)
    timr: TTimer;
    ttremulo: TTimer;
    Button1: TButton;
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    txtfattore: TEdit;
    txtvelocita: TEdit;
    Button2: TButton;
    btnmx: TButton;
    procedure btnmxClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ttremuloTimer(Sender: TObject);
    procedure timrTimer(Sender: TObject);
  private
    { Private declarations }
  public
    procedure cambiatremulo;
    procedure cambiastato;
  end;

var
  FMouseX: TFMouseX;
  abilitato, tremulo: boolean;
  sequenza: byte;
  fattore: integer;
  iniopt: Tinifile;

implementation

{$R *.dfm}

procedure TFMouseX.btnmxClick(Sender: TObject);
begin
  abilitato := not abilitato; cambiastato;
end;

procedure TFMouseX.Button1Click(Sender: TObject);
begin
  ttremulo.Interval := strtoint(txtvelocita.Text);
  fattore := strtoint(txtfattore.Text);
  hide;
end;

procedure TFMouseX.Button2Click(Sender: TObject);
begin
  hide;
end;

procedure TFMouseX.cambiastato;
begin
  timr.Enabled := abilitato;
  if not(timr.Enabled) then
  btnmx.Caption:='MouseX On' else  btnmx.Caption:='MouseX Off';
end;

procedure TFMouseX.cambiatremulo;
begin
  ttremulo.Enabled := tremulo;
end;

procedure TFMouseX.CheckBox1Click(Sender: TObject);
begin
  if checkbox1.Checked then
    iniopt.WriteBool('settaggi', 'mxauto', true)
  else
    iniopt.WriteBool('settaggi', 'mxauto', false);
//  abilitato := not abilitato; cambiastato;
end;

procedure TFMouseX.FormCreate(Sender: TObject);
begin
  iniopt := TIniFile.Create(ExtractFilepath(paramstr(0)) + '\plugins\' + 'mousex.ini');
  if iniopt.ReadBool('settaggi', 'mxauto', false) then begin
    checkbox1.Checked := true; abilitato := true; cambiastato; end else checkbox1.checked := false;
end;

procedure TFMouseX.FormDestroy(Sender: TObject);
begin
  iniopt.Free;
end;

procedure TFMouseX.timrTimer(Sender: TObject);
var
  P: Tpoint;
begin
  getcursorpos(P);
  if P.x = screen.Width - 1 then
  begin
    setcursorpos(1, P.Y);
  end;
  if P.y = screen.Height - 1 then
  begin
    setcursorpos(P.X, 1);
  end;

  if P.x = 0 then
  begin
    setcursorpos(screen.Width - 2, P.Y);
  end;
  if P.y = 0 then
  begin
    setcursorpos(P.X, screen.Height - 2);
  end;
end;

procedure TFMouseX.ttremuloTimer(Sender: TObject);
var oggetto: tpoint;
begin
  getcursorpos(oggetto);
//  GetWindowRect(0, oggetto);
  case sequenza of
    1: begin setcursorpos(oggetto.X - fattore, oggetto.Y); sequenza := 2; end;
    2: begin setcursorpos(oggetto.X, oggetto.Y + fattore); sequenza := 3; end;
    3: begin setcursorpos(oggetto.X + fattore, oggetto.Y); sequenza := 4; end;
    4: begin setcursorpos(oggetto.X, oggetto.Y - fattore); sequenza := 1; end;
  else sequenza := 1;
  end;
end;

end.

