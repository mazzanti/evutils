unit PKillaFunc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Inifiles, StdCtrls, TLHelp32, ExtCtrls;

type
  TFPKilla = class(TForm)
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    GroupBox2: TGroupBox;
    Button4: TButton;
    ListBox2: TListBox;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    GroupBox3: TGroupBox;
    ListBox3: TListBox;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Image1: TImage;
    procedure Button10Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure listaprocessi;
    procedure killaprocesso(exetokill: string);
    procedure beginkillthis;
    procedure beginkillexcludethis;
  end;

var
  FPKilla: TFPKilla;
  iniopt: Tinifile;
  inilines: byte;
  aSnapshotHandle: THandle;
  aProcessEntry32: TProcessEntry32;

implementation

{$R *.dfm}


procedure TFPKilla.listaprocessi;
var
  bContinue: BOOL;
  temp: string;
begin
  listbox2.clear;
  aSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  aProcessEntry32.dwSize := SizeOf(aProcessEntry32);
  bContinue := Process32First(aSnapshotHandle, aProcessEntry32);
  while Integer(bContinue) <> 0 do
  begin
    temp := ExtractFileName(aProcessEntry32.szExeFile);
    if (lowercase(temp) <> '[system process]') and (lowercase(temp) <> 'system') then
      listbox2.items.append(temp);
    bContinue := Process32Next(aSnapshotHandle, aProcessEntry32);
  end;
  CloseHandle(aSnapshotHandle);
end;

procedure TFPKilla.killaprocesso(exetokill: string);
var
  aSnapshotHandle: THandle;
  aProcessEntry32: TProcessEntry32;
  i: Integer;
  bContinue: BOOL;
  Ret: BOOL;
  PrID: Integer; // processidentifier
  Ph: THandle; // processhandle

begin
  if uppercase(exetokill) = 'EVUTILS.EXE' then exit;

  aSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  aProcessEntry32.dwSize := SizeOf(aProcessEntry32);
  bContinue := Process32First(aSnapshotHandle, aProcessEntry32);
  //scansione..
  while Integer(bContinue) <> 0 do
  begin
    //inizio confronto con exetokill
    if lowercase(ExtractFileName(aProcessEntry32.szExeFile)) = lowercase(exetokill) then
    begin
      PrID := StrToInt('$' + IntToHex(aProcessEntry32.th32ProcessID, 4));
      Ph := OpenProcess(1, BOOL(0), PrID);
      Ret := TerminateProcess(Ph, 0);
      if Integer(Ret) = 0 then MessageDlg('Cannot terminate "' + exetokill + '".', mtInformation, [mbOK], 0);
    end;
    bContinue := Process32Next(aSnapshotHandle, aProcessEntry32);
  end;
  CloseHandle(aSnapshotHandle);
end;

procedure TFPKilla.beginkillthis;
var c: byte;
begin
  if listbox1.Count = 0 then exit;

  for c := 0 to listbox1.Count - 1 do
  begin
    killaprocesso(listbox1.Items.Strings[c]);
  end;
end;

procedure TFPKilla.beginkillexcludethis;
var c, j: byte;
  presente: boolean;
  temp, temp2: string;
begin
  if listbox3.Count = 0 then exit;

  for c := 0 to listbox2.Count - 1 do
  begin
    temp := listbox2.Items.Strings[c];
    for j := 0 to ListBox3.Count - 1 do
    begin
      temp2 := listbox3.Items.Strings[j];
      if lowercase(temp) = lowercase(temp2) then begin presente := true; break; end else presente := false;
    end;
    if not presente then killaprocesso(temp);
  end;
end;

procedure TFPKilla.Button10Click(Sender: TObject);
begin
  beginkillexcludethis;
end;

procedure TFPKilla.Button1Click(Sender: TObject);
var tmp: string;
  keynum: string;
begin
// tmp:=inputbox('new process','insert the process name','');
  if not inputquery('new process', 'insert the process name', tmp) then exit;
  if tmp = '' then exit;
  tmp := lowercase(tmp);
  if copy(tmp, length(tmp) - 3, 4) <> '.exe' then tmp := tmp + '.exe';
  listbox1.Items.Add(tmp);
  if listbox1.Count <= 10 then keynum := '0' + inttostr(listbox1.Count - 1)
  else keynum := inttostr(listbox1.Count - 1);
  iniopt.WriteString('processes', 'P' + keynum, tmp);
end;

procedure TFPKilla.Button2Click(Sender: TObject);
var c: byte;
  keynum: string;
  tmp: string;
begin
// listbox1.DeleteSelected;
  if listbox1.ItemIndex = -1 then exit;
  listbox1.Items.Delete(listbox1.ItemIndex);

  iniopt.EraseSection('processes');
  if listbox1.Count <= 0 then exit;

  for c := 0 to listbox1.Count - 1 do
  begin
    if c < 10 then keynum := '0' + inttostr(c) else keynum := inttostr(c);
    tmp := listbox1.Items.Strings[c];
    tmp := lowercase(tmp);
    iniopt.WriteString('processes', 'P' + keynum, tmp);
  end;
// iniopt.DeleteKey('processes','P'+inttostr(listbox1.ItemIndex));
end;

procedure TFPKilla.Button3Click(Sender: TObject);
begin
  beginkillthis;
end;

procedure TFPKilla.Button4Click(Sender: TObject);
begin
  listaprocessi;
end;

procedure TFPKilla.Button5Click(Sender: TObject);
var indice: byte;
  nomep: string;
  keynum: string;
begin
  if listbox2.itemindex < 0 then exit;
  indice := listbox2.itemindex;
  nomep := listbox2.Items.Strings[indice];
  if (nomep = '[System Process]') or (nomep = 'System') then exit;
  listbox1.Items.Append(nomep);

  if listbox1.Count <= 10 then keynum := '0' + inttostr(listbox1.Count - 1)
  else keynum := inttostr(listbox1.Count - 1);
  iniopt.WriteString('processes', 'P' + keynum, nomep);
end;

procedure TFPKilla.Button6Click(Sender: TObject);
var indice: byte;
  nomep: string;
  keynum: string;
begin
  if listbox2.itemindex < 0 then exit;
  indice := listbox2.itemindex;
  nomep := listbox2.Items.Strings[indice];
  if (nomep = '[System Process]') or (nomep = 'System') then exit;
  listbox3.Items.Append(nomep);

  if listbox3.Count <= 10 then keynum := '0' + inttostr(listbox3.Count - 1)
  else keynum := inttostr(listbox3.Count - 1);
  iniopt.WriteString('processes2', 'P' + keynum, nomep);
end;

procedure TFPKilla.Button7Click(Sender: TObject);
begin
  hide;
end;

procedure TFPKilla.Button8Click(Sender: TObject);
var tmp: string;
  keynum: string;
begin
// tmp:=inputbox('new process','insert the process name','');
  if not inputquery('new process', 'insert the process name', tmp) then exit;
  if tmp = '' then exit;
  tmp := lowercase(tmp);
  if copy(tmp, length(tmp) - 3, 4) <> '.exe' then tmp := tmp + '.exe';
  listbox3.Items.Add(tmp);
  if listbox3.Count <= 10 then keynum := '0' + inttostr(listbox3.Count - 1)
  else keynum := inttostr(listbox3.Count - 1);
  iniopt.WriteString('processes2', 'P' + keynum, tmp);
end;

procedure TFPKilla.Button9Click(Sender: TObject);
var c: byte;
  keynum: string;
  tmp: string;
begin
// listbox1.DeleteSelected;
  if listbox3.ItemIndex = -1 then exit;
  listbox3.Items.Delete(listbox3.ItemIndex);

  iniopt.EraseSection('processes2');
  if listbox3.Count <= 0 then exit;

  for c := 0 to listbox3.Count - 1 do
  begin
    if c < 10 then keynum := '0' + inttostr(c) else keynum := inttostr(c);
    tmp := listbox3.Items.Strings[c];
    tmp := lowercase(tmp);
    iniopt.WriteString('processes2', 'P' + keynum, tmp);
  end;
end;

procedure TFPKilla.FormCreate(Sender: TObject);
var c: byte;
  tmp, tmp2: string;
  keynum: string;
begin
  iniopt := TIniFile.Create(ExtractFilepath(paramstr(0)) + '\plugins\' + 'pkilla.ini');
//  if not (iniopt.SectionExists('processes')) then iniopt.WriteString('processes', 'P01', '');
// iniopt.WriteString('processes','P01','explorer.exe');
  for c := 0 to 99 do
  begin
    keynum := inttostr(c);
    if c < 10 then keynum := '0' + inttostr(c);
    tmp := iniopt.ReadString('processes', 'P' + keynum, '');
    tmp := lowercase(tmp);
    tmp2 := iniopt.ReadString('processes2', 'P' + keynum, '');
    tmp2 := lowercase(tmp2);
    if tmp <> '' then
    begin
//   lowercase(tmp);
      if copy(tmp, length(tmp) - 3, 4) <> '.exe' then tmp := tmp + '.exe';
      listbox1.Items.Add(tmp);
    end;
    if tmp2 <> '' then
    begin
      if copy(tmp2, length(tmp2) - 3, 4) <> '.exe' then tmp2 := tmp2 + '.exe';
      listbox3.Items.Add(tmp2);
    end;
  end;
 //iniopt.Free;
// top:=(screen.Height div 2) - (height div 2); left:=2;
  listaprocessi;
end;

procedure TFPKilla.FormDestroy(Sender: TObject);
begin
  iniopt.free;
end;

procedure TFPKilla.FormShow(Sender: TObject);
begin
  listaprocessi;
end;

end.

