unit KUtils;

interface

uses Windows, sysutils, classes;

function tocapital(s: string): string;
function LowCase(ch: CHAR): CHAR;
function StartThread(pFunction: TFNThreadStartRoutine; parametri: pointer = nil; iPriority: Integer = Thread_Priority_Normal; iStartFlag: Integer = 0): THandle;
function CloseThread(ThreadHandle: THandle): Boolean;
procedure Search(DirName, filename: string; tipo: byte; var lista: TStringList);
function max(a, b: Integer): Integer;


implementation

function max(a, b: Integer): Integer;
begin
  if a < b then
    result := b
  else result := a;
end;


procedure Search(DirName, filename: string; tipo: byte; var lista: TStringList);
var
  SearchRec: TSearchRec;
  GotOne: Integer;
begin
  GotOne := FindFirst(DirName + '\*', tipo, SearchRec);
  while GotOne = 0 do
  begin
    if ((SearchRec.Attr and faDirectory) <> 0) or ((tipo = faanyfile) and
      ((SearchRec.Attr and faDirectory) = 0)) then
    begin
      if ((pos(lowercase(filename), lowercase(SearchRec.name)) > 0) or (filename
        = '')) and ((SearchRec.name <> '.') and (SearchRec.name <> '..')) then
        lista.Add(DirName + '\' + SearchRec.name)
    end;
    if ((SearchRec.Attr and faDirectory) <> 0) then
      if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
        Search(DirName + '\' + SearchRec.name, filename, tipo, lista);
    GotOne := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

function LowCase(ch: CHAR): CHAR;
begin
  case ch of
    'A'..'Z': LowCase := CHR(ORD(ch) + 31);
  else
    LowCase := ch;
  end;
end;

function tocapital(s: string): string;
var t: string;
  i: Integer;
  newWord: Boolean;
begin
  if s = '' then exit;
  s := lowercase(s);
  t := uppercase(s);
  newWord := true;
  for i := 1 to length(s) do
  begin
    if newWord and (s[i] in ['a'..'z']) then
    begin s[i] := t[i]; newWord := false; continue; end;
    if s[i] in ['a'..'z', ''''] then continue;
    newWord := true;
  end;
  result := s;
end;

function StartThread(pFunction: TFNThreadStartRoutine; parametri: pointer = nil; iPriority: Integer = Thread_Priority_Normal; iStartFlag: Integer = 0): THandle;
var
  ThreadID: DWORD;
begin
  result := CreateThread(nil, 0, pFunction, parametri, iStartFlag, ThreadID);
  if result <> 0 then
    SetThreadPriority(result, iPriority);
end;

function CloseThread(ThreadHandle: THandle): Boolean;
begin
  result := TerminateThread(ThreadHandle, 1);
  CloseHandle(ThreadHandle);
end;

end.

