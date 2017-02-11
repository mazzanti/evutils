unit FMainVD;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs
  ,Subst, StdCtrls, ExtCtrls
  ,dutils, XPMan
  ,inifiles
  ;

type
  TFvd = class(TForm)
    GroupBox1: TGroupBox;
    STATIC_REMOVEDRIVE: TGroupBox;
    bcreatevd: TButton;
    Folder: TLabeledEdit;
    folderselect: TButton;
    bremovevd: TButton;
    vdggauto: TCheckBox;
    STATIC_ISTRUCTION: TLabel;
    Image1: TImage;
    Image2: TImage;
    letter: TComboBox;
    STATIC_LETTERA: TLabel;
    rletter: TComboBox;
    STATIC_RLETTERA: TLabel;
    hackletters: TCheckBox;
    Label4: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure bcreatevdClick(Sender: TObject);
    procedure bremovevdClick(Sender: TObject);
    procedure folderselectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure hacklettersClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    function LoadLang:boolean;stdcall;
    function TraduciForm(lingua:integer):boolean;stdcall;
  public
    { Public declarations }
  end;

var
  Fvd: TFvd;
  PATH: string;
  vdggsettings:Tinifile;

implementation

{$R *.dfm}

uses evutilsLanguages;

procedure scanVDrives;
var c:char;
begin
Fvd.letter.Clear;
Fvd.rletter.Clear;
 for c:='A' to 'Z' do
 begin
  if SubstQuery(c)='' then Fvd.letter.items.add(c+':') else Fvd.rletter.items.add(c+':');
 end;
end;

procedure TFvd.bcreatevdClick(Sender: TObject);
begin
if letter.Text='' then exit;
if SubstCreate(letter.Text[1],folder.Text) then
begin
 showmessage('VirtualDrive Created');
 if vdggauto.Checked then begin vdggsettings.WriteString('driveletters',copy(letter.text,1,1),folder.text); showmessage('This VirtualDrive will be mounted automatically');end;
end else showmessage('VirtualDrive Error');
Fvd.Close;
end;

procedure TFvd.bremovevdClick(Sender: TObject);
begin
if rletter.Text='' then exit;
if SubstRemove(rletter.Text[1]) then
begin
 showmessage('VirtualDrive Removed');
 vdggsettings.WriteString('driveletters',copy(rletter.text,1,1),'');
end else showmessage('VirtualDrive Error');
scanVDrives;
end;

procedure TFvd.Button1Click(Sender: TObject);
begin
 hide;
end;

procedure TFvd.folderselectClick(Sender: TObject);
var s:string;
begin
s := '';
if GetFolderDialog(Application.Handle, 'Select a folder', s) then
  folder.text:=s;
end;

procedure TFvd.FormCreate(Sender: TObject);
var g:char;
    tempdir:string;
begin
 loadlang;
 //legge o crea i settaggi
 vdggsettings:=Tinifile.Create(ExtractFilepath(paramstr(0))+'\plugins\'+'vdgg.ini');
 if not(vdggsettings.SectionExists('driveletters')) then
  begin
    for g := 'A' to 'Z' do
     vdggsettings.WriteString('driveletters',g,'');
     // vdggsettings.Free;  
   exit;
  end;
  
  //verifico l'integrità del file ini
 for g := 'A' to 'Z' do
   begin
    if not(vdggsettings.ValueExists('driveletters',g)) then
     vdggsettings.WriteString('driveletters',g,'');
   end;

 //cerco gli autostart
 for g := 'A' to 'Z' do
   begin
     tempdir := vdggsettings.ReadString('driveletters',g,'');
     if tempdir <> '' then SubstCreate(g,tempdir);
   end;
// vdggsettings.Free;
end;

procedure TFvd.FormDestroy(Sender: TObject);
begin
 vdggsettings.Free;
end;

procedure TFvd.FormShow(Sender: TObject);
begin
 scanVDrives;
 setforegroundwindow(self.Handle);
end;

procedure TFvd.hacklettersClick(Sender: TObject);
var j:char;
begin
 if hackletters.checked then
 begin
  Fvd.letter.Clear;
  Fvd.rletter.Clear;
  for j := 'A' to 'Z' do
   begin
    letter.Items.Add(j+':');rletter.Items.Add(j+':');
   end;
 end
  else scanVDrives;
end;

function TFvd.TraduciForm(lingua:integer):boolean;stdcall;
var
 Buff    : array [0..255] of Char;
begin
result := true;
case lingua of
  0 : begin //lingua inglese, da 1000 a 2000 ho messo inglese
       LoadString(HInstance, 1001, Buff, SizeOf(Buff));
       STATIC_LETTERA.Caption := Buff; STATIC_LETTERA.Refresh;
       LoadString(HInstance, 1003, Buff, SizeOf(Buff));
       STATIC_ISTRUCTION.Caption := Buff; STATIC_ISTRUCTION.Refresh;
       LoadString(HInstance, 1004, Buff, SizeOf(Buff));
       GROUPBOX1.Caption := Buff; GROUPBOX1.Refresh;
       LoadString(HInstance, 1006, Buff, SizeOf(Buff));
       FOLDER.EditLabel.Caption := Buff; FOLDER.EditLabel.Refresh;
       LoadString(HInstance, 1008, Buff, SizeOf(Buff));
       bcreatevd.Caption := Buff; bcreatevd.Refresh;
       LoadString(HInstance, 1007, Buff, SizeOf(Buff));
       vdggauto.Caption := Buff; vdggauto.Refresh;
       LoadString(HInstance, 1009, Buff, SizeOf(Buff));
       STATIC_REMOVEDRIVE.Caption := Buff; STATIC_REMOVEDRIVE.Refresh;
       LoadString(HInstance, 1002, Buff, SizeOf(Buff));
       STATIC_RLETTERA.Caption := Buff; STATIC_RLETTERA.Refresh;
       LoadString(HInstance, 1005, Buff, SizeOf(Buff));
       bremovevd.Caption := Buff; bremovevd.Refresh;
       LoadString(HInstance, 1010, Buff, SizeOf(Buff));
       hackletters.Caption := Buff; hackletters.Refresh;
      end;
  1 : begin //lingua italiano, da 2000 a 3000 ho messo italiano
       LoadString(HInstance, 2001, Buff, SizeOf(Buff));
       STATIC_LETTERA.Caption := Buff; STATIC_LETTERA.Refresh;
       LoadString(HInstance, 2003, Buff, SizeOf(Buff));
       STATIC_ISTRUCTION.Caption := Buff; STATIC_ISTRUCTION.Refresh;
       LoadString(HInstance, 2004, Buff, SizeOf(Buff));
       GROUPBOX1.Caption := Buff; GROUPBOX1.Refresh;
       LoadString(HInstance, 2006, Buff, SizeOf(Buff));
       FOLDER.EditLabel.Caption := Buff; FOLDER.EditLabel.Refresh;
       LoadString(HInstance, 2008, Buff, SizeOf(Buff));
       bcreatevd.Caption := Buff; bcreatevd.Refresh;
       LoadString(HInstance, 2007, Buff, SizeOf(Buff));
       vdggauto.Caption := Buff; vdggauto.Refresh;
       LoadString(HInstance, 2009, Buff, SizeOf(Buff));
       STATIC_REMOVEDRIVE.Caption := Buff; STATIC_REMOVEDRIVE.Refresh;
       LoadString(HInstance, 2002, Buff, SizeOf(Buff));
       STATIC_RLETTERA.Caption := Buff; STATIC_RLETTERA.Refresh;
       LoadString(HInstance, 2005, Buff, SizeOf(Buff));
       bremovevd.Caption := Buff; bremovevd.Refresh;
       LoadString(HInstance, 2010, Buff, SizeOf(Buff));
       hackletters.Caption := Buff; hackletters.Refresh;
      end;
 end;
end;

function TFvd.loadlang:boolean;stdcall;
begin
 result := true;
 
 case language of
  0 : TraduciForm(0);
  1 : TraduciForm(1);
  else TraduciForm(0);
 end;
end;

end.
