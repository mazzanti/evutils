unit KUtils;

interface

uses SysUtils, Windows;

function tocapital(s: string): string;
function LowCase(ch: CHAR): CHAR;
function StartThread(pFunction: TFNThreadStartRoutine; iPriority: Integer = Thread_Priority_Normal; iStartFlag: Integer = 0): THandle;
function CloseThread(ThreadHandle: THandle): Boolean;
function RoundN(x: Extended; d: Integer): Extended;


implementation

function LowCase(ch: CHAR): CHAR;
begin
  case ch of
    'A'..'Z': LowCase := CHR(ORD(ch) + 31);
  else
    LowCase := ch;
  end;
end;

function RoundN(x: Extended; d: Integer): Extended;
  // RoundN(123.456, 0) = 123.00
  // RoundN(123.456, 2) = 123.46
  // RoundN(123456, -3) = 123000
  const
    t: array [0..12] of int64 = (1, 10, 100, 1000, 10000, 100000,
        1000000, 10000000, 100000000, 1000000000, 10000000000,
        100000000000, 1000000000000);
  begin
    if d = 0 then
      Result := Int(x) + Int(Frac(x) * 2)
    else if d > 0 then begin
      x := x * t[d];
      Result := (Int(x) + Int(Frac(x) * 2)) / t[d];
    end else begin  // d < 0
      x := x / t[-d];
      Result := (Int(x) + Int(Frac(x) * 2)) * t[-d];
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

function StartThread(pFunction: TFNThreadStartRoutine; iPriority: Integer = Thread_Priority_Normal; iStartFlag: Integer = 0): THandle;
var
  ThreadID: DWORD;
begin
  result := CreateThread(nil, 0, pFunction, nil, iStartFlag, ThreadID);
  if result <> 0 then
    SetThreadPriority(result, iPriority);
end;

function CloseThread(ThreadHandle: THandle): Boolean;
begin
  result := TerminateThread(ThreadHandle, 1);
  CloseHandle(ThreadHandle);
end;

end.

