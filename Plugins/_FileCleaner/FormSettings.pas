unit FormSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
uses CleanerFunctions;

procedure TForm1.Button1Click(Sender: TObject);
begin
if DelTree('c:\pino') then
ShowMessage('Directory deleted!')
else
ShowMessage('Errors occured!') ;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 listbox1.Items.Add(inputbox('Mask +','',''));
 listbox1.Items.SaveToFile(ExtractFilePath(paramstr(0)+'\masks.txt'));
end;

end.
