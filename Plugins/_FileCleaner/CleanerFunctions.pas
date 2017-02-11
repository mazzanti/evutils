unit CleanerFunctions;

interface

Function DelTree(DirName : string): Boolean;
procedure DelWithMask(StartDir: string);

implementation

uses ShellAPI, sysutils;
Function DelTree(DirName : string): Boolean;
var
  SHFileOpStruct : TSHFileOpStruct;
  DirBuf : array [0..255] of char;
begin
  try
   Fillchar(SHFileOpStruct,Sizeof(SHFileOpStruct),0) ;
   FillChar(DirBuf, Sizeof(DirBuf), 0 ) ;
   StrPCopy(DirBuf, DirName) ;
   with SHFileOpStruct do begin
    Wnd := 0;
    pFrom := @DirBuf;
    wFunc := FO_DELETE;
    fFlags := FOF_ALLOWUNDO;
    fFlags := fFlags or FOF_NOCONFIRMATION;
    fFlags := fFlags or FOF_SILENT;
   end; 
    Result := (SHFileOperation(SHFileOpStruct) = 0) ;
   except
    Result := False;
  end;
end;


procedure DelWithMask(StartDir: string);
var
  Search : TSearchRec;
begin
if Startdir[Length(Startdir)] <> '\' then
  startdir := startdir + '\';
  if FindFirst(startdir + '*.*', faAnyFile, Search) = 0 then
  repeat
    if (Search.Name[1] <> '.' ) then
      if ((Search.Attr and faDirectory) > 0) then 
      begin
        RmDir(StartDir + Search.Name);     
//        ChangeFAttrib(StartDir + Search.Name);
      end else 
      begin
        DeleteFile(StartDir + Search.Name);
//        Application.ProcessMessages;
      end;
  until FindNext(Search) <> 0;
  FindClose(Search);
end;



end.
