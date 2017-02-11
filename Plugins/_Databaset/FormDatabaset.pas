unit FormDatabaset;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls
  , evutilsdatabase;

type
  TFDatabase = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    ListView1: TListView;
    procedure Button7Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FDatabase: TFDatabase;

implementation

{$R *.dfm}

procedure TFDatabase.Button1Click(Sender: TObject);
begin
Memo1.Clear;
Memo1.Lines.LoadFromFile(Edit1.Text);
end;

procedure TFDatabase.Button2Click(Sender: TObject);
begin
Memo1.Lines.Append(InputBox('Nuova linea db','scrivi il contenuto della nuova linea','nuovoelemento'));
Memo1.Lines.SaveToFile(Edit1.Text);
end;

procedure TFDatabase.Button3Click(Sender: TObject);
begin
memo1.Lines.Delete(memo1.Lines.Count-1);
end;

procedure TFDatabase.Button4Click(Sender: TObject);
begin
memo1.Lines.Strings[0]:=edit2.text;
end;

procedure TFDatabase.Button6Click(Sender: TObject);
begin
Memo1.Clear;
end;

procedure TFDatabase.Button7Click(Sender: TObject);
begin
riempilista(memo1,listview1);
end;

end.
