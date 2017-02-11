unit formexecparams;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  Tfexecparams = class(TForm)
    lfilename: TLabel;
    Label1: TLabel;
    txtfullpath: TEdit;
    Label2: TLabel;
    txtworkingdir: TEdit;
    txtparams: TEdit;
    Label3: TLabel;
    btnexec: TButton;
    Image1: TImage;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cboModal: TComboBox;
    Image2: TImage;
    Label7: TLabel;
    txtnr: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnexecClick(Sender: TObject);
    procedure txtfullpathChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);


  private
    { Private declarations }
    procedure FileIsDropped(var Msg: TMessage); message WM_DropFiles;
  public
    { Public declarations }
  end;

var
  fexecparams: Tfexecparams;



implementation

{$R *.dfm}

uses ShellAPI;


procedure Tfexecparams.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(handle, True);
end;

procedure Tfexecparams.FormShow(Sender: TObject);
begin
  setforegroundwindow(self.Handle);
  txtfullpath.Clear; txtworkingdir.Clear; txtparams.Clear; txtnr.Text:='1';
  lfilename.Caption:='no file - drag and drop the file here';
end;

procedure Tfexecparams.txtfullpathChange(Sender: TObject);
begin
  lfilename.Caption := extractfilename(txtfullpath.text);
  txtworkingdir.Text := ExtractFilePath(txtfullpath.text);
end;

procedure Tfexecparams.btnexecClick(Sender: TObject);
var
  c: integer;
  nrofexec: integer;
begin
  if txtfullpath.text = '' then exit;
  if txtnr.Text = '' then exit;
  nrofexec := strtoint(txtnr.text);

  for c := 1 to nrofexec do
  begin
    if (cboModal.Text = 'SW_SHOWNORMAL') or (cboModal.Text = '') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_SHOWNORMAL);
    if (cboModal.Text = 'SW_HIDE') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_HIDE);
    if (cboModal.Text = 'SW_MAXIMIZE') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_MAXIMIZE);
    if (cboModal.Text = 'SW_MINIMIZE') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_MINIMIZE);
    if (cboModal.Text = 'SW_RESTORE') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_RESTORE);
    if (cboModal.Text = 'SW_SHOW') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_SHOW);
    if (cboModal.Text = 'SW_SHOWDEFAULT') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_SHOWDEFAULT);
    if (cboModal.Text = 'SW_SHOWMAXIMIZED') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_SHOWMAXIMIZED);
    if (cboModal.Text = 'SW_SHOWMINIMIZED') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_SHOWMINIMIZED);
    if (cboModal.Text = 'SW_SHOWMINNOACTIVE') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_SHOWMINNOACTIVE);
    if (cboModal.Text = 'SW_SHOWNA') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_SHOWNA);
    if (cboModal.Text = 'SW_SHOWNOACTIVATE') then
      ShellExecute(handle, 'open', PChar(txtfullpath.text),
        PChar(txtparams.text), PChar(txtworkingdir.Text), SW_SHOWNOACTIVATE);
  end;

  fexecparams.Close;
end;

procedure Tfexecparams.Button1Click(Sender: TObject);
begin
 hide;
end;

procedure Tfexecparams.FileIsDropped(var Msg: TMessage);
var
  hDrop: THandle;
  fName: array[0..254] of CHAR;
//   NumberOfFiles : INTEGER ;
//   fCounter : INTEGER ;
  Names: string;
begin
  hDrop := Msg.WParam;
   //NumberOfFiles :=
  DragQueryFile(hDrop, 0, fName, 254);
  Names := fName; {
   FOR fCounter := 1 TO NumberOfFiles DO BEGIN
      DragQueryFile(hDrop,fCounter,fName,254);
// Here you have your file name 1 by 1
      Names := Names + #13#10 + fName ;
   END ;            }

  txtfullpath.Text := (Names);
  DragFinish(hDrop);
end;

end.

