unit WinShutty;

interface

uses
Windows
,  SysUtils
 ;

function MyExitWindows(RebootParam: Longword)                                   : Boolean;

implementation

function MyExitWindows(RebootParam: Longword)                                   : Boolean;
var
  TTokenHd: THandle;
  TTokenPvg: TTokenPrivileges;
  cbtpPrevious: DWORD;
  rTTokenPvg: TTokenPrivileges;
  pcbtpPreviousRequired: DWORD;
  tpResult: Boolean;
const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    tpResult := OpenProcessToken(GetCurrentProcess(),
      TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
      TTokenHd);
    if tpResult then
    begin
      tpResult := LookupPrivilegeValue(nil,
                                       SE_SHUTDOWN_NAME,
                                       TTokenPvg.Privileges[0].Luid);
      TTokenPvg.PrivilegeCount := 1;
      TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      cbtpPrevious := SizeOf(rTTokenPvg);
      pcbtpPreviousRequired := 0;
      if tpResult then
        Windows.AdjustTokenPrivileges(TTokenHd,
                                      False,
                                      TTokenPvg,
                                      cbtpPrevious,
                                      rTTokenPvg,
                                      pcbtpPreviousRequired);
    end;
  end;
  Result := ExitWindowsEx(RebootParam, 0);
end;

function sys_GetRunningTime:string ;
var
//    TimeTheComputerStarted: DWORD;
    CurrentTickValue: DWORD;
//    Difference:       DWORD;
    ComputerHours, ComputerMinutes, ComputerSeconds: DWORD;
//    ComputerTime: AnsiString;
begin
//  TimeTheComputerStarted := GetTickCount();
  CurrentTickValue := GetTickCount();
//	Difference       := CurrentTickValue - TimeTheComputerStarted;
	ComputerHours      := (CurrentTickValue div (3600 * 999)) mod 24;
	ComputerMinutes    := (CurrentTickValue div (60 * 999  )) mod 60;
	ComputerSeconds    := (CurrentTickValue div (999       )) mod 60;

	result:= IntToStr(ComputerHours)   + ' hours, '  +
	         IntToStr(ComputerMinutes) + ' minutes ' +
	         IntToStr(ComputerSeconds) + ' seconds.' ;
end;

end.
