unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, BoxList, Balloon, shlobj, shellapi;

type tposizioni = (bassodx, bassosx, altodx, altosx);

type
  TFMain = class(TForm)
    BoxList1: TBoxList;
    Balloon1: TBalloonControl;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BoxList1Click(Sender: TObject);
    procedure BoxList1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BoxList1MouseLeave(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    saltaprossimo: boolean;
    procedure WMChangeCBChain(var Msg: TMessage); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard(var Msg: TMessage); message WM_DRAWCLIPBOARD;
    procedure visualizza;
    procedure nascondi;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    posizione: tposizioni;
  end;

var
  FMain: TFMain;
  NextInChain: THandle;
  PATH: string;

var
  ListaClip: tlist;
var
  ultimoballoon: TBalloon = nil;

type tipoclip = (clipdummy, cliptesto, clipbmp, clipfiles);

type oggettoclip = record
    tipo: tipoclip;
  end;
type poggettoclip = ^oggettoclip;

type oggettocliptesto = record
    tipo: tipoclip;
    visualizzato: string;
    testo: string;
  end;
type poggettocliptesto = ^oggettocliptesto;

type oggettoclipbmp = record
    tipo: tipoclip;
    visualizzato: string;
    bmp: tbitmap;
  end;
type poggettoclipbmp = ^oggettoclipbmp;

type oggettoclipfiles = record
    tipo: tipoclip;
    visualizzato: string;
    files: tstringlist;
  end;
type poggettoclipfiles = ^oggettoclipfiles;


implementation

uses ClipBrd, Immagine;

{$R *.dfm}


procedure TFMain.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do begin
    ExStyle := ExStyle or WS_EX_TOPMOST;
    ExStyle := ExStyle and not WS_EX_APPWINDOW;
    ExStyle := ExStyle or WS_EX_TOOLWINDOW;
    WndParent := GetDesktopwindow;
  end;
end;

procedure TFMain.nascondi;
begin
  if assigned(ultimoballoon) then
  begin
    ultimoballoon.CloseBalloon;
    ultimoballoon := nil;
  end;

  hide;
end;

procedure CopyFilesToClipboard(FileList: string);
var
  DropFiles: PDropFiles;
  hGlobal: THandle;
  iLen: Integer;
begin
  iLen := Length(FileList) + 2;
  FileList := FileList + #0#0;
  hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT,
    SizeOf(TDropFiles) + iLen);
  if (hGlobal = 0) then raise Exception.Create('Could not allocate memory.');
  begin
    DropFiles := GlobalLock(hGlobal);
    DropFiles^.pFiles := SizeOf(TDropFiles);
    Move(FileList[1], (PChar(DropFiles) + SizeOf(TDropFiles))^, iLen);
    GlobalUnlock(hGlobal);
    Clipboard.SetAsHandle(CF_HDROP, hGlobal);
  end;
end;

procedure TFMain.BoxList1Click(Sender: TObject);
var
  octesto: poggettocliptesto;
  ocbmp: poggettoclipbmp;
  ocfiles: poggettoclipfiles;
  files: string;
  i: Integer;
begin
  if BoxList1.CurentItem = 0 then exit;

  case (poggettoclip(BoxList1.Items.Objects[BoxList1.CurentItem - 1]).tipo) of
    cliptesto:
      begin
        octesto := poggettocliptesto(BoxList1.Items.Objects[BoxList1.CurentItem - 1]);
        saltaprossimo := true;
        clipboard.SetTextBuf(pchar(octesto.testo));
        nascondi;
      end;
    clipbmp:
      begin
        ocbmp := poggettoclipbmp(BoxList1.Items.Objects[BoxList1.CurentItem - 1]);
        saltaprossimo := true;
        clipboard.Assign(ocbmp.bmp);
        nascondi;
      end;
    clipfiles:
      begin
        ocfiles := poggettoclipfiles(BoxList1.Items.Objects[BoxList1.CurentItem - 1]);
        saltaprossimo := true;
        for i := 0 to ocfiles.files.count - 1 do
          files := ocfiles.files[i] + #0;
        CopyFilesToClipboard(files);
        nascondi;
      end;
  end;
end;

procedure TFMain.visualizza;
var
  i: Integer;
begin
  BoxList1.Items.Clear;

  i := 0;
  while (i < ListaClip.Count) do
  begin
    case oggettoclip((ListaClip.Items[i])^).tipo of
      clipfiles:
        begin
          BoxList1.Items.AddObject(oggettoclipfiles((ListaClip.Items[i])^).visualizzato, ListaClip.Items[i]);
        end;
      cliptesto:
        begin
          BoxList1.Items.AddObject(oggettocliptesto((ListaClip.Items[i])^).visualizzato, ListaClip.Items[i]);
        end;
      clipbmp:
        begin
          BoxList1.Items.AddObject(oggettoclipbmp((ListaClip.Items[i])^).visualizzato, ListaClip.Items[i]);
        end;
      clipdummy:
        begin
          BoxList1.Items.AddObject('', ListaClip.Items[i]);
        end;
    end;

    inc(i);
  end;
  BoxList1.Repaint;
end;


procedure TFMain.BoxList1MouseLeave(Sender: TObject);
begin
  nascondi;
end;

procedure TFMain.BoxList1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  sel: byte;
  p: tpoint;
  ocbmp: poggettoclipbmp;
  octesto: poggettocliptesto;
  ocfiles: poggettoclipfiles;
begin
  p.X := X;
  p.Y := Y;
  sel := BoxList1.itematpos(p, false);
  if (BoxList1.CurentItem <> sel) and (sel > 0) then
  begin
    BoxList1.CurentItem := sel;

    getcursorpos(p);
    case posizione of
      bassodx:
        begin
          Balloon1.PixelCoordinateX := FMain.Left;
          Balloon1.Position := blnArrowTopLeft;
        end;
      bassosx:
        begin
          Balloon1.PixelCoordinateX := FMain.Left + FMain.Width;
          Balloon1.Position := blnArrowTopRight;
        end;
      altodx:
        begin
          Balloon1.PixelCoordinateX := FMain.Left;
          Balloon1.Position := blnArrowBottomLeft;
        end;
      altosx:
        begin
          Balloon1.PixelCoordinateX := FMain.Left + FMain.Width;
          Balloon1.Position := blnArrowBottomRight;
        end;
    end;

    Balloon1.PixelCoordinateY := FMain.Top - 5 + sel * 20;

    case poggettoclip(BoxList1.Items.Objects[BoxList1.CurentItem - 1]).tipo of
      clipbmp:
        begin
          ocbmp := poggettoclipbmp(BoxList1.Items.Objects[BoxList1.CurentItem - 1]);
          if assigned(ultimoballoon) then
            ultimoballoon.CloseBalloon;
          Balloon1.Text.Clear;
          ultimoballoon := Balloon1.ShowPixelBalloon(250, 300, ocbmp.bmp);
        end;
      cliptesto:
        begin
          octesto := poggettocliptesto(BoxList1.Items.Objects[BoxList1.CurentItem - 1]);
          Balloon1.Text.Clear;
          Balloon1.Text.add(octesto.testo);
          if assigned(ultimoballoon) then
            ultimoballoon.CloseBalloon;
          ultimoballoon := Balloon1.ShowPixelBalloon(0, 0, nil);
        end;
      clipfiles:
        begin
          ocfiles := poggettoclipfiles(BoxList1.Items.Objects[BoxList1.CurentItem - 1]);
          if assigned(ultimoballoon) then
            ultimoballoon.CloseBalloon;
          Balloon1.Text.Clear;
          Balloon1.Text.Assign(ocfiles.files);
          ultimoballoon := Balloon1.ShowPixelBalloon(0, 0, nil);
        end;
    else
      if assigned(ultimoballoon) then
      begin
        ultimoballoon.CloseBalloon;
        ultimoballoon := nil;
      end;
    end;
    BoxList1.Repaint;
  end;
end;

procedure TFMain.FormCreate(Sender: TObject);
var
  i: byte;
  dummy: poggettoclip;
begin
  saltaprossimo := false;
  ListaClip := tlist.Create;
  i := 0;
  while (i < 10) do
  begin
    new(dummy);
    dummy.tipo := clipdummy;
    ListaClip.add(dummy);
    inc(i);
  end;
  BoxList1.MargineIniziale := 10;
  visualizza;
  NextInChain := SetClipboardViewer(Handle);
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  ChangeClipboardChain(Handle, NextInChain);
end;

procedure TFMain.FormShow(Sender: TObject);
begin
boxlist1.CurentItem:=0;
end;

function abbrevia(testo: string; caratteri: byte): string;
var
  i, j: Integer;
begin
  i := 1;
  j := 1;
  while ((i <= caratteri) and (j <= length(testo))) do
  begin
    if testo[j] >= #20 then
    begin
      Result := Result + testo[j];
      inc(i);
    end;
    inc(j);
  end;
  if j <= length(testo) then Result := Result + '...';

end;

procedure inserisci(p: pointer; check: boolean);
var
  i: Integer;
  ultimo: Integer;
  s: string;
begin
  ListaClip.insert(0, p);
  if check then
  begin
    s := poggettocliptesto(p).testo;
    i := 1;
    while (i < ListaClip.Count) do
    begin
      if poggettoclip(ListaClip.Items[i]).tipo = cliptesto then
        if s = poggettocliptesto(ListaClip.Items[i]).testo then
          ListaClip.Delete(i);
      inc(i);
    end;
  end;

  if ListaClip.Count > 10 then
  begin
    ultimo := ListaClip.Count - 1;
    case oggettoclip((ListaClip.Items[ultimo])^).tipo of
      clipfiles:
        begin
          oggettoclipfiles((ListaClip.Items[ultimo])^).files.Free;
          dispose(poggettoclipfiles((ListaClip.Items[ultimo])));
        end;
      clipbmp:
        begin
          oggettoclipbmp((ListaClip.Items[ultimo])^).bmp.Free;
          dispose(poggettoclipbmp((ListaClip.Items[ultimo])));
        end;
      cliptesto:
        begin
          dispose(poggettocliptesto((ListaClip.Items[ultimo])));
        end;
      clipdummy:
        begin
          dispose(poggettoclip((ListaClip.Items[ultimo])));
        end;
    end;
    ListaClip.Delete(ultimo);
  end;
end;


procedure leggifiles(ocfiles: poggettoclipfiles);
var
  f: THandle;
  buffer: array[0..MAX_PATH] of Char;
  i, numFiles: Integer;
begin
  ocfiles.files := tstringlist.Create;
  try
    f := Clipboard.GetAsHandle(CF_HDROP);
    if f <> 0 then begin
      numFiles := DragQueryFile(f, $FFFFFFFF, nil, 0);
      for i := 0 to numfiles - 1 do begin
        buffer[0] := #0;
        DragQueryFile(f, i, buffer, sizeof(buffer));
        ocfiles.files.add(buffer);
        if ocfiles.visualizzato <> '' then
          ocfiles.visualizzato := ocfiles.visualizzato + '; ' + extractfilename(buffer)
        else
          ocfiles.visualizzato := 'FILES: ' + extractfilename(buffer);
      end;
    end;
  finally
  end;
  ocfiles.visualizzato := abbrevia(ocfiles.visualizzato, 50);

end;

procedure TFMain.WMDrawClipboard(var Msg: TMessage);
var
  octesto: poggettocliptesto;
  ocbmp: poggettoclipbmp;
  ocfiles: poggettoclipfiles;
begin
  if not saltaprossimo then
  begin
    if clipboard.HasFormat(cf_text) then
    begin
      new(octesto);
      octesto.tipo := cliptesto;
      octesto.testo := clipboard.AsText;
      octesto.visualizzato := abbrevia(octesto.testo, 50);
      inserisci(octesto, true);
    end
    else
      if clipboard.HasFormat(CF_BITMAP) then
      begin
        new(ocbmp);
        ocbmp.visualizzato := 'Immagine' + inttostr(random(100)); ;
        ocbmp.tipo := clipbmp;
        ocbmp.bmp := tbitmap.Create;
        ocbmp.bmp.Assign(clipboard);
        inserisci(ocbmp, false);
      end
      else
        if clipboard.HasFormat(CF_HDROP) then
        begin
          new(ocfiles);
          ocfiles.tipo := clipfiles;
          leggifiles(ocfiles);
          inserisci(ocfiles, false);
        end;

    if NextInChain <> 0 then
      SendMessage(NextInChain, WM_DRAWCLIPBOARD, 0, 0);

    visualizza();
  end
  else
    saltaprossimo := false;
end;

procedure TFMain.WMChangeCBChain(var Msg: TMessage);
var
  Remove, Next: THandle;
begin
  Remove := Msg.WParam;
  Next := Msg.LParam;
  with Msg do
    if NextInChain = Remove then
      NextInChain := Next
    else if NextInChain <> 0 then
      SendMessage(NextInChain, WM_CHANGECBCHAIN, Remove, Next)
end;

end.

