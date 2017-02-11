unit Subst;

{ 
  API for work with substitution device (see dos command "subst"). 
  Win 9x/NT/2000/XP compatible
  ver. 1.2 Last rev. 25 Feb 2002

  Freware with source.

  Copyright (c) 2000-2002, SoftLab MIL-TEC Ltd
  Web:   http://www.softcomplete.com
  Email: support@softcomplete.com

  THIS SOFTWARE AND THE ACCOMPANYING FILES ARE DISTRIBUTED
  "AS IS" AND WITHOUT WARRANTIES AS TO PERFORMANCE OF MERCHANTABILITY OR
  ANY OTHER WARRANTIES WHETHER EXPRESSED OR IMPLIED.
  NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS OFFERED.
  THE USER MUST ASSUME THE ENTIRE RISK OF USING THE ACCOMPANYING CODE.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented, you must
     not claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation
     would be appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. Original copyright may not be removed or altered from any source
     distribution.
}

interface

uses Windows, SysUtils;

function SubstCreate(DriveLetter: Char; const Path: string): Boolean;
// create subst device. Path must be a real folder.

function SubstRemove(DriveLetter: Char): Boolean;
// destroy subst device.

function SubstQuery(DriveLetter: Char): string;
// get Path for subst device.
// return empty string if DriveLetter is not subst-device

implementation

procedure VxDCall; external kernel32 index 1;

function SubstCreate(DriveLetter: Char; const Path: string): Boolean;
var drvno: byte;
    buff: array[0..256] of char;
    FPath: string;

  function AddSlash(const Path: string): string; {добавляем \ если надо}
  begin
    if (Path = '') or (Path[Length(Path)] <> '\') then Result:=Path+'\'
    else Result:=Path;
  end;

begin
  if Path[Length(Path)] = '\' then
    FPath:=Copy(Path,1,Length(Path)-1)
  else
    FPath:=Path;
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    buff[0]:=DriveLetter;
    buff[1]:=':';
    buff[2]:=#0;
    Result:=DefineDosDevice(0,buff,PChar(Path));
  end else begin
    FPath:=ExtractShortPathName(FPath);
    if FPath <> '' then begin
      drvno:=Ord(UpperCase(DriveLetter)[1])-64;
      StrPCopy(buff,FPath);
      asm
         pushad
         push    es
         xor     ebx, ebx
         mov     bh,0
         mov     bl,drvno
         lea     edx,buff
         push    0       //ECX (unused)
         push    71AAh
         push    2A0010h
         call    VxDCall
         pop     es
         popad
      end;
    end;
    Result:=ANSIUpperCase(AddSlash(SubstQuery(DriveLetter))) = ANSIUpperCase(AddSlash(Path));
  end;
end;

function SubstRemove(DriveLetter: Char): Boolean;
var drvno: byte;
    Drive,Path: string;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    SetLength(Drive,3);
    Drive[1]:=DriveLetter;
    Drive[2]:=':';
    Drive[3]:=#0;
    Path:=SubstQuery(DriveLetter);
    Result:=DefineDosDevice(DDD_REMOVE_DEFINITION,PChar(Drive),PChar(Path));
  end else begin
    drvno:=Ord(UpperCase(DriveLetter)[1])-64;
    asm
       pushad
       push    es
       xor     ebx, ebx
       mov     bh,1
       mov     bl,drvno
       push    0       //ECX (unused)
       push    71AAh
       push    2A0010h
       call    VxDCall
       pop     es
       popad
    end;
    Result:=SubstQuery(DriveLetter) = '';
  end;
end;

function SubstQuery(DriveLetter: Char): string;
var drvno: byte;
    buff: array[0..256] of char;
    lbuff: array[0..256] of char;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    lbuff[0]:=DriveLetter;
    lbuff[1]:=':';
    lbuff[2]:=#0;
    buff[0]:=#0;
    QueryDosDevice(lbuff,buff,256);
    Result:=StrPas(buff);
    if Copy(Result,1,4) = '\??\' then
      Result:=Copy(Result,5,Length(Result))
    else
      Result:='';
  end else begin
    drvno:=Ord(UpperCase(DriveLetter)[1])-64;
    buff[0]:=#0;
    asm
       pushad
       push    es
       xor     ebx, ebx
       mov     bh,2
       mov     bl,drvno
       lea     edx,buff
       push    0       //ECX (unused)
       push    71AAh
       push    2A0010h
       call    VxDCall
       pop     es
       popad
    end;
    Result:=StrPas(buff);
    if Result = '' then Exit;
    // convert to longfilename
    asm
       // expand long path
       pushad
       push    ds
       push    es
       xor     ebx, ebx
       lea     esi, buff
       lea     edi, lbuff
       mov     ecx,0
       mov     cl, 2
       mov     ch, 0
       push    ECX
       push    7160h
       push    2A0010h
       call    VxDCall
       pop     es
       pop     ds
       popad
    end;
    Result:=StrPas(lbuff);
  end;
end;

end.
