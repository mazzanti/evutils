unit FastBmp;

//  FastBmp v0.05
//  Gordon Alex Cowie III (aka "GoRDy") <gfody@jps.net>
//  www.jps.net/gfody (currently down (jps sucks fat cock))
//
//  This unit is freeware.
//  Improvements, Ideas, Filters, Methods,
//  and Optimizations are welcome.
//  see Readme.txt for documentation.
//
//  Contributors:
//
//  Armindo Da Silva <armindo.da-silva@wanadoo.fr>
//   -Blur, Wave, Spray, Rotate
//   -TFastImage component based on FastBmp
//
//  Andreas Goransson <andreas.goransson@epk.ericsson.se>
//   -Texture filter
//   -Added some optimizations here an there
//
//  Earl F. Glynn <earlglynn@att.net>
//   -Rotation optimizations
//   -Computer lab: www.infomaster.net/external/efg/
//
//  Vit Kovalcik <vkovalcik@iname.com>
//   -Optimized Resize method
//   -Check out UniDib for 4,8,16,24,32 bit dibs!
//   -www.geocities.com/SiliconValley/Hills/1335/
//
//  Anders Melander <anders@melander.dk>
//  David Ullrich <ullrich@hardy.math.okstate.edu>
//  Dale Schumacher
//   -Bitmap Resampler
//
//  P.S. if I don't respond to your email within a few days
//  send it again (jps sucks some horse dick)

interface

uses Windows;

type

TFColor=record
  b,g,r: Byte;
end;
PFColor=^TFColor;

TLine=array[0..0]of TFColor;
PLine=^TLine;
TCalcs=array[0..0]of Integer;
PCalcs=^TCalcs;
TFilterProc=function(Value:Single):Single;

TFastBmp=class
private
  procedure   CalcLines;
  procedure   SetPixel(x,y:Integer;Clr:TFColor);
  function    GetPixel(x,y:Integer):TFColor;
  procedure   SetLine(y:Integer;Line:Pointer);
  function    GetLine(y:Integer):Pointer;
public
  Calcs:      PCalcs;
  Handle,
  Width,
  Height,
  Size:       Integer;
  Bits:       Pointer;
  BmpHeader:  TBITMAPINFOHEADER;
  BmpInfo:    TBITMAPINFO;
  // constructors
  constructor Create(cx,cy:Integer);
  constructor CreateFromFile(lpFile:string);
  constructor CreateFromhWnd(hBmp:Integer);
  constructor CreateCopy(hBmp:TFastBmp);
  destructor  Destroy; override;
  // properties
  property    Pixels[x,y:Integer]:TFColor read GetPixel write SetPixel;
  property    ScanLines[y:Integer]:Pointer read GetLine write SetLine;
  procedure   GetScanLine(y:Integer;Line:Pointer);
  // conversions
  procedure   Resize(Dst:TFastBmp);
  procedure   Resample(Dst:TFastBmp;Filter:TFilterProc;FWidth:Single);
  procedure   Tile(Dst:TFastBmp);
  // screen drawing methods
  procedure   Draw(hDC,x,y:Integer);
  procedure   Stretch(hDC,x,y,cx,cy:Integer);
  procedure   DrawRect(hDC,hx,hy,x,y,cx,cy:Integer);
  procedure   TileDraw(hDC,x,y,cx,cy:Integer);
  // filters
  procedure   Flip;   //Horizontal
  procedure   Flop;   //Vertical
  procedure   TurnCW;
  procedure   TurnCCW;
  procedure   Spray(Amount:Integer);
  procedure   SplitBlur(Amount:Integer);
  procedure   GaussianBlur(Amount:Integer);
  procedure   Sharpen;
  procedure   Wave(XDIV,YDIV,RatioVal:Integer);
  procedure   WaveWrap(XDIV,YDIV,RatioVal:Integer);
  procedure   AddColorNoise(Amount:Integer);
  procedure   AddMonoNoise(Amount:Integer);
  procedure   RGB(ra,ga,ba:Integer);
  procedure   RotateWrap(Dst:TFastBmp;Degree:Extended;iRotationAxis,jRotationAxis:Integer);
  procedure   GrayScale;
  procedure   DiscardColor;
  procedure   VertRoll(Amount:Integer);
  procedure   HorzRoll(Amount:Integer);
end;
PFastBmp=^TFastBmp;

// filter procs to use with TFastBmp.Resample   // suggested Radius
function SplineFilter(Value:Single):Single;     // 2.0
function BellFilter(Value:Single):Single;       // 1.5
function TriangleFilter(Value:Single):Single;   // 1.0
function BoxFilter(Value:Single):Single;        // 0.5
function HermiteFilter(Value:Single):Single;    // 1.0
function Lanczos3Filter(Value:Single):Single;   // 3.0
function MitchellFilter(Value:Single):Single;   // 2.0

// returns a TFColor given rgb values
function FRGB(r,g,b:Byte):TFColor;
procedure Rotate(Bmp,Dst:TFastbmp;cx,cy:Integer;Angle:Double);

implementation

function FRGB(r,g,b:Byte):TFColor;
begin
  Result.r:=r;
  Result.g:=g;
  Result.b:=b;
end;

// Precalculated scanline offsets!
procedure TFastBmp.CalcLines;
var
i: Integer;
begin
  GetMem(Calcs,Height*SizeOf(Integer));
  for i:=0 to Height-1 do
  Calcs^[i]:=Integer(Bits)+(i*(Width mod 4))+((i*Width)*3);
end;

procedure TFastBmp.SetPixel(x,y:Integer;Clr:TFColor);
begin
  //(y*(Width mod 4))+(((y*Width)+x)*3)
  //if(x>-1)and(x<Width)and(y>-1)and(y<Height)then
  PLine(Calcs^[y])^[x]:=Clr;
end;

function TFastBmp.GetPixel(x,y:Integer):TFColor;
begin
  //if(x>-1)and(x<Width)and(y>-1)and(y<Height)then
  Result:=PLine(Calcs^[y])^[x];
end;

procedure TFastBmp.SetLine(y:Integer;Line:Pointer);
begin
  //Pointer(Integer(Bits)+(y*(Width mod 4))+((y*Width)*3)))
  CopyMemory(
    Pointer(Calcs^[y]),
    Line,
    Width*3);
end;

function TFastBmp.GetLine(y:Integer):Pointer;
begin
  Result:=Pointer(Calcs^[y]);
end;

procedure TFastBmp.GetScanLine(y:Integer;Line:Pointer);
begin
  CopyMemory(
    Line,
    Pointer(Calcs^[y]),
    Width*3);
end;

constructor TFastBmp.Create(cx,cy:Integer);
begin
  Width:=cx;
  Height:=cy;
  Size:=((Width*3)+(Width mod 4))*Height;
  with BmpHeader do
  begin
    biSize:=SizeOf(BmpHeader);
    biWidth:=Width;
    biHeight:=-Height;
    biPlanes:=1;
    biBitCount:=24;
    biCompression:=BI_RGB;
  end;
  BmpInfo.bmiHeader:=BmpHeader;
  Handle:=CreateDIBSection(0,
                   BmpInfo,
                   DIB_RGB_COLORS,
                   Bits,
                   0,
                   0);
  CalcLines;
end;

constructor TFastBmp.CreateFromFile(lpFile:string);
var
Bmp:  TBITMAP;
hDC,
hBmp: Integer;
begin
  hBmp:=LoadImage(0,PChar(lpFile),IMAGE_BITMAP,0,0,LR_LOADFROMFILE);
  GetObject(hBmp,SizeOf(Bmp),@Bmp);
  hDC:=CreateDC('DISPLAY',nil,nil,nil);
  SelectObject(hDC,hBmp);

  Width:=Bmp.bmWidth;
  Height:=Bmp.bmHeight;
  Size:=((Width*3)+(Width mod 4))*Height;

  with BmpHeader do
  begin
    biSize:=SizeOf(BmpHeader);
    biWidth:=Width;
    biHeight:=-Height;
    biPlanes:=1;
    biBitCount:=24;
    biCompression:=BI_RGB;
  end;
  BmpInfo.bmiHeader:=BmpHeader;
  Handle:=CreateDIBSection(0,
                 BmpInfo,
                 DIB_RGB_COLORS,
                 Bits,
                 0,
                 0);
  GetDIBits(hDC,hBmp,0,Height,Bits,BmpInfo,DIB_RGB_COLORS);
  DeleteDC(hDC);
  DeleteObject(hBmp);
  CalcLines;
end;

constructor TFastBmp.CreateFromhWnd(hBmp:Integer);
var
Bmp:  TBITMAP;
hDC:  Integer;
begin
  hDC:=CreateDC('DISPLAY',nil,nil,nil);
  SelectObject(hDC,hBmp);
  GetObject(hBmp,SizeOf(Bmp),@Bmp);
  Width:=Bmp.bmWidth;
  Height:=Bmp.bmHeight;
  Size:=((Width*3)+(Width mod 4))*Height;

  with BmpHeader do
  begin
    biSize:=SizeOf(BmpHeader);
    biWidth:=Width;
    biHeight:=-Height;
    biPlanes:=1;
    biBitCount:=24;
    biCompression:=BI_RGB;
  end;
  BmpInfo.bmiHeader:=BmpHeader;
  Handle:=CreateDIBSection(0,
                 BmpInfo,
                 DIB_RGB_COLORS,
                 Bits,
                 0,
                 0);
  GetDIBits(hDC,hBmp,0,Height,Bits,BmpInfo,DIB_RGB_COLORS);
  DeleteDC(hDC);
  CalcLines;
end;

constructor TFastBmp.CreateCopy(hBmp:TFastBmp);
begin
  BmpHeader:=hBmp.BmpHeader;
  BmpInfo:=hBmp.BmpInfo;
  Width:=hBmp.Width;
  Height:=hBmp.Height;
  Size:=hBmp.Size;
  Handle:=CreateDIBSection(0,
                 BmpInfo,
                 DIB_RGB_COLORS,
                 Bits,
                 0,
                 0);
  CopyMemory(Bits,hBmp.Bits,Size);
  CalcLines;
end;

//  ? For some reason this is acting like StretchDiBits        ?
//  ? in 24bit color mode (performs good in 16bit mode though) ?
procedure TFastBmp.Stretch(hDC,x,y,cx,cy:Integer);
var
hBmp,
MemDC: Integer;
begin
  MemDC:=CreateCompatibleDC(hDC);
  hBmp:=CreateCompatibleBitmap(hDC,Width,Height);
  SelectObject(MemDC,hBmp);
  Draw(MemDC,0,0);
  StretchBlt(hDC,x,y,cx,cy,MemDC,0,0,Width,Height,SRCCOPY);
  DeleteDC(MemDC);
  DeleteObject(hBmp);
end;

procedure TFastBmp.Draw(hDC,x,y:Integer);
begin
  SetDIBitsToDevice(hDC,
                    x,y,Width,Height,
                    0,0,0,Height,
                    Bits,
                    BmpInfo,
                    DIB_RGB_COLORS);
end;

procedure TFastBmp.DrawRect(hDC,hx,hy,x,y,cx,cy:Integer);
begin
  StretchDiBits(hDC,
                hx,hy+cy-1,cx,-cy+1,
                x,Height-y,cx,-cy+1,
                Bits,
                BmpInfo,
                DIB_RGB_COLORS,
                SRCCOPY);
end;

//  I call this method of tiling.. 'Progressive Tiling'
procedure TFastBmp.TileDraw(hDC,x,y,cx,cy:Integer);
var
w,h,
hBmp,
MemDC: Integer;
begin
  MemDC:=CreateCompatibleDC(hDC);
  hBmp:=CreateCompatibleBitmap(hDC,cx,cy);
  SelectObject(MemDC,hBmp);
  Draw(MemDC,0,0);
  w:=Width;
  h:=Height;
  while h<cy do
  begin
    BitBlt(MemDC,0,h,w,h*2,MemDC,0,0,SRCCOPY);
    Inc(h,h);
  end;
  while w<cx do
  begin
    BitBlt(MemDC,w,0,w*2,cy,MemDC,0,0,SRCCOPY);
    Inc(w,w);
  end;
  BitBlt(hDC,x,y,cx,cy,MemDC,0,0,SRCCOPY);
  DeleteDC(MemDC);
  DeleteObject(hBmp);
end;

//  Trying to make this faster then TileDraw
procedure TFastBmp.Tile(Dst:TFastBmp);
var
LineOut,
LineIn:  PLine;
x,y,a,b: Integer;
begin
  a:=0;
  b:=0;
  GetMem(LineIn,Width*3);
  GetMem(LineOut,Dst.Width*3);

  for y:=0 to Dst.Height-1 do
  begin
    GetScanLine(b,LineIn);
    for x:=0 to Dst.Width-1 do
    begin
      LineOut^[x]:=LineIn^[a];
      Inc(a);
      if a=Width then a:=0;
    end;
    Dst.ScanLines[y]:=LineOut;
    a:=0;
    Inc(b);
    if b=Height then b:=0;
  end;
  FreeMem(LineOut,Dst.Width*3);
  FreeMem(LineIn,Width*3);
end;

//  Thanks to Vit Kovalcik for his optimizations!
//  Anybody wanna apply these optimizations to the resampler?
procedure TFastBmp.Resize(Dst:TFastBmp);
var
xCount,
yCount,
x,y,xP,yP,
yiScale,
xiScale: Integer;
xScale,
yScale:  Single;
Read,
Line:    PLine;
Tmp:     TFColor;
begin
  xScale:=Dst.Width/Width;
  yScale:=Dst.Height/Height;
  if(xScale=1)and(yScale=1)then
  begin
    CopyMemory(Dst.Bits,Bits,Size);
    Exit;
  end;
  yiScale:=Trunc(yScale);
  xiScale:=Trunc(xScale);
  GetMem(Line,Dst.Width*3);
  for y:=0 to Height-1 do
  begin
    yP:=Trunc(yScale*y);
    Read:=Scanlines[y];
    for x:=0 to Width-1 do
    begin
      xP:=Trunc(xScale*x);
      Tmp:=Read^[x];
      for xCount:=0 to xiScale do
      Line^[xCount+xP]:=Tmp;
    end;
    for yCount:=0 to yiScale do
    Dst.Scanlines[yCount+yP]:=Line;
  end;
  FreeMem(Line,Dst.Width*3);
end;

procedure TFastBmp.Flip;
var
Buff,
Line: PLine;
x,y:  Integer;
begin
  GetMem(Line,Width*3);
  GetMem(Buff,Width*3);

  for y:=0 to Height-1 do
  begin
    GetScanLine(y,Buff);
    for x:=0 to Width-1 do
    begin
      Line^[(Width-1)-x].r:=Buff[x].r;
      Line^[(Width-1)-x].g:=Buff[x].g;
      Line^[(Width-1)-x].b:=Buff[x].b;
    end;
    ScanLines[y]:=Line;
  end;
  FreeMem(Buff,Width*3);
  FreeMem(Line,Width*3);
end;

procedure TFastBmp.Flop;
var
y,cy: Integer;
Buff,
Line: PLine;
begin
  GetMem(Buff,Width*3);
  GetMem(Line,Width*3);
  if Odd(Height)then cy:=Height div 2 else cy:=Height div 2 - 1;
  for y:=0 to cy do
  begin
    GetScanLine(y,Buff);
    GetScanLine((Height-1)-y,Line);
    ScanLines[y]:=Line;
    ScanLines[(Height-1)-y]:=Buff;
  end;
  FreeMem(Buff,Width*3);
  FreeMem(Line,Width*3);
end;

procedure TFastBmp.TurnCW;
var
x,y: Integer;
Tmp: TFastBmp;
begin
  Tmp:=TFastBmp.Create(Height,Width);
  for x:=0 to Width-1 do
  for y:=0 to Height-1 do
  Tmp.Pixels[Height-y-1,x]:=Pixels[x,y];
  DeleteObject(Handle);
  Handle:=Tmp.Handle;
  Width:=Tmp.Width;
  Height:=Tmp.Height;
  Size:=Tmp.Size;
  Bits:=Tmp.Bits;
  BmpHeader:=Tmp.BmpHeader;
  BmpInfo:=Tmp.BmpInfo;
  CalcLines;
end;

procedure TFastBmp.TurnCCW;
var
x,y: Integer;
Tmp: TFastBmp;
begin
  Tmp:=TFastBmp.Create(Height,Width);
  for x:=0 to Width-1 do
  for y:=0 to Height-1 do
  Tmp.Pixels[y,Width-x-1]:=Pixels[x,y];
  DeleteObject(Handle);
  Handle:=Tmp.Handle;
  Width:=Tmp.Width;
  Height:=Tmp.Height;
  Size:=Tmp.Size;
  Bits:=Tmp.Bits;
  BmpHeader:=Tmp.BmpHeader;
  BmpInfo:=Tmp.BmpInfo;
  CalcLines;
end;

procedure TFastBmp.AddColorNoise(Amount:Integer);
var
x,y,r,g,b: Integer;
Line:      PLine;
begin
  GetMem(Line,Width*3);
  for y:=0 to Height-1 do
  begin
    GetScanLine(y,Line);
    for x:=0 to Width-1 do
    begin
      r:=Line^[x].r+(Random(Amount)-(Amount div 2));
      g:=Line^[x].g+(Random(Amount)-(Amount div 2));
      b:=Line^[x].b+(Random(Amount)-(Amount div 2));
      if r>255 then r:=255 else if r<0 then r:=0;
      if g>255 then g:=255 else if g<0 then g:=0;
      if b>255 then b:=255 else if b<0 then b:=0;
      Line^[x].r:=r;
      Line^[x].g:=g;
      Line^[x].b:=b;
    end;
    ScanLines[y]:=Line;
  end;
  FreeMem(Line,Width*3);
end;

procedure TFastBmp.AddMonoNoise(Amount:Integer);
var
x,y,a,r,g,b: Integer;
Line:        PLine;
begin
  GetMem(Line,Width*3);
  for y:=0 to Height-1 do
  begin
    GetScanLine(y,Line);
    for x:=0 to Width-1 do
    begin
      a:=(Random(Amount)-(Amount div 2));
      r:=Line^[x].r+a;
      g:=Line^[x].g+a;
      b:=Line^[x].b+a;
      if r>255 then r:=255 else if r<0 then r:=0;
      if g>255 then g:=255 else if g<0 then g:=0;
      if b>255 then b:=255 else if b<0 then b:=0;
      Line^[x].r:=r;
      Line^[x].g:=g;
      Line^[x].b:=b;
    end;
    ScanLines[y]:=Line;
  end;
  FreeMem(Line,Width*3);
end;

procedure TFastBmp.RGB(ra,ga,ba:Integer);
var
r,g,b,
x,y:  Integer;
Line: PLine;
Tmp:  TFColor;
begin
  for y:=0 to Height-1 do
  begin
    Line:=Scanlines[y];
    for x:=0 to Width-1 do
    begin
      Tmp:=Line^[x];
      r:=Tmp.r+ra;
      g:=Tmp.g+ga;
      b:=Tmp.b+ba;
      if r>255 then Tmp.r:=255 else if r<0 then Tmp.r:=0 else Tmp.r:=r;
      if g>255 then Tmp.g:=255 else if g<0 then Tmp.g:=0 else Tmp.g:=g;
      if b>255 then Tmp.b:=255 else if b<0 then Tmp.b:=0 else Tmp.b:=b;
      Line^[x]:=Tmp;
    end;
  end;
end;

procedure TFastBmp.SplitBlur(Amount:Integer);
var
Lin,
Lin1,
Lin2:  PLine;
cx,
x,y: Integer;
Buf:   array[0..3]of TFColor;
Tmp:   TFColor;
begin
  if Amount=0 then Exit;

  for y:=0 to Height-1 do
  begin
    Lin:=ScanLines[y];

    if y-Amount<0         then Lin1:=ScanLines[y]
    else {y-Amount>0}          Lin1:=ScanLines[y-Amount];
    if y+Amount<Height    then Lin2:=ScanLines[y+Amount]
    else {y+Amount>=Height}    Lin2:=ScanLines[Height-y];

    for x:=0 to Width-1 do
    begin
      if x-Amount<0     then cx:=x
      else {x-Amount>0}      cx:=x-Amount;
      Buf[0]:=Lin1^[cx];
      Buf[1]:=Lin2^[cx];
      if x+Amount<Width     then cx:=x+Amount
      else {x+Amount>=Width}     cx:=Width-x;
      Buf[2]:=Lin1^[cx];
      Buf[3]:=Lin2^[cx];
      Tmp.r:=(Buf[0].r+Buf[1].r+Buf[2].r+Buf[3].r)div 4;
      Tmp.g:=(Buf[0].g+Buf[1].g+Buf[2].g+Buf[3].g)div 4;
      Tmp.b:=(Buf[0].b+Buf[1].b+Buf[2].b+Buf[3].b)div 4;
      Lin^[x]:=Tmp;
    end;
  end;
end;

procedure TFastBmp.GaussianBlur(Amount:Integer);
begin

end;


procedure TFastBmp.VertRoll(Amount:Integer);
var
Line: PLine;
p,y:  Integer;
begin
  if Amount>Width then Amount:=Amount mod Width;
  if Amount=0 then Exit;
  GetMem(Line,Amount*3);
  for y:=0 to Height-1 do
  begin
    p:=Integer(Scanlines[y]);
    CopyMemory(Line,Pointer(p+((Width-Amount)*3)),Amount*3);
    MoveMemory(Pointer(p+(Amount*3)),Pointer(p),(Width-Amount)*3);
    CopyMemory(Pointer(p),Line,Amount*3);
  end;
  FreeMem(Line,Amount*3);
end;

procedure TFastBmp.HorzRoll(Amount:Integer);
var
Buff: Pointer;
p,y:  Integer;
begin
  if Amount>Height then Amount:=Amount mod Height;
  if Amount=0 then Exit;
  p:=Integer(Bits)+(Height*(Width mod 4))+((Height*Width)*3);
  p:=p-Integer(Scanlines[Amount]);
  y:=Integer(Scanlines[Amount])-Integer(Scanlines[0]);
  GetMem(Buff,y);
  CopyMemory(Buff,Scanlines[Height-Amount],y);
  MoveMemory(Scanlines[Amount],Scanlines[0],p);
  CopyMemory(Scanlines[0],Buff,y);
  FreeMem(Buff,y);
end;

//  Optimizations Welcome!
procedure TFastBmp.WaveWrap(XDIV,YDIV,RatioVal:Integer);
var
Tmp:           TFastBMP;
i,j,XSrc,YSrc: Integer;
begin
  if(YDiv=0)or(XDiv=0)then Exit;
  Tmp:=TFastBmp.CreateCopy(Self);
  for i:=0 to Width-1 do
  for j:=0 to Height-1 do
  begin
    XSrc:=Round(i+RatioVal*Sin(j/YDiv));
    YSrc:=Round(j+RatioVal*sin(i/XDiv));

    if      XSrc<0       then XSrc:=Width-1-(-XSrc mod Width)
    else if XSrc>=Width  then XSrc:=XSrc mod Width;
    if      YSrc<0       then YSrc:=Height-1-(-YSrc mod Height)
    else if YSrc>=Height then YSrc:=YSrc mod(Height-1);

    Pixels[i,j]:=Tmp.Pixels[XSrc,YSrc];

  end;
  Tmp.Free;
end;

//  Optimizations Welcome!
procedure TFastBmp.Wave(XDIV,YDIV,RatioVal:Integer);
var
Tmp:           TFastBMP;
i,j,XSrc,YSrc: Integer;
begin
  if(YDiv=0)or(XDiv=0)then Exit;
  Tmp:=TFastBmp.CreateCopy(Self);
  for i:=0 to Width-1 do
  for j:=0 to Height-1 do
  begin
    XSrc:=Round(i+RatioVal*Sin(j/YDiv));
    YSrc:=Round(j+RatioVal*Sin(i/XDiv));

    if(XSrc>-1)and(XSrc<Width)and(YSrc>-1)and(YSrc<Height)then
    Pixels[i,j]:=Tmp.Pixels[XSrc,YSrc];

  end;
  Tmp.Free;
end;

procedure TFastBmp.Spray(Amount:Integer);
var
Tmp:     TFastBmp;
i,j,x,y,
Val:     Integer;
begin
  Tmp:=TFastBmp.CreateCopy(Self);
  for i:=0 to Width-1 do
  for j:=0 to Height-1 do
  begin
    Val:=Random(Amount);
    x:=i+Val-Random(Val*2);
    y:=j+Val-Random(Val*2);
    if(x>-1)and(x<Width)and(y>-1)and(y<Height)then
    Pixels[i,j]:=Tmp.Pixels[x,y];
  end;
  Tmp.Free;
end;

procedure Rotate(Bmp,Dst:TFastbmp;cx,cy:Integer;Angle:Double);
var
x,y,
dx,dy,
sdx,sdy,
xDiff,yDiff,
isinTheta,
icosTheta: Integer;
Tmp:       PFColor;
sinTheta,
cosTheta,
Theta:     Double;
begin

  Theta:=-Angle*Pi/180;
  sinTheta:=Sin(Theta);
  cosTheta:=Cos(Theta);
  xDiff:=(Dst.Width-Bmp.Width)div 2;
  yDiff:=(Dst.Height-Bmp.Height)div 2;
  isinTheta:=Round(sinTheta*$10000);
  icosTheta:=Round(cosTheta*$10000);

  begin
    Tmp:=Dst.Bits;
    for y:=0 to Dst.Height-1 do
    begin
      sdx:=Round(((cx+(-cx)*cosTheta-(y-cy)*sinTheta)-xDiff)*$10000);
      sdy:=Round(((cy+(-cx)*sinTheta+(y-cy)*cosTheta)-yDiff)*$10000);
      for x:=0 to Dst.Width-1 do
      begin
        dx:=(sdx shr 16);
        dy:=(sdy shr 16);
        if(dx>-1)and(dx<Bmp.Width)and(dy>-1)and(dy<Bmp.Height)then
        Tmp^:=Bmp.Pixels[dy,dx];
        Inc(sdx,icosTheta);
        Inc(sdy,isinTheta);
        Inc(Tmp);
      end;
      Tmp:=Ptr(Integer(Tmp)+sizeof(Dst.Width));
    end;
  end;

end;

procedure TFastBmp.RotateWrap(Dst:TFastBmp;Degree:Extended;iRotationAxis,jRotationAxis:Integer);
var
Theta,
cosTheta,
sinTheta:      Double;
i,j,
iOriginal,
iPrime,
iPrimeRotated,
jOriginal,
jPrime,
jPrimeRotated: Integer;
RowOriginal,
RowRotated:    PLine;
begin
  GetMem(RowRotated,Dst.Width*3);
  Theta:=-Degree*Pi/180;
  sinTheta:=Sin(Theta);
  cosTheta:=Cos(Theta);

  for j:=0 to Dst.Height-1 do
  begin
    Dst.GetScanline(j,RowRotated);
    jPrime:=2*(j-jRotationAxis)+1;
    for i:=0 to Dst.Width-1 do
    begin
      iPrime:=2*(i-iRotationAxis)+1;
      iPrimeRotated:=Round(iPrime*cosTheta-jPrime*sinTheta);
      jPrimeRotated:=Round(iPrime*sinTheta+jPrime*cosTheta);
      iOriginal:=(iPrimeRotated-1)div 2+iRotationAxis;
      jOriginal:=(jPrimeRotated-1)div 2+jRotationAxis;

      if      iOriginal<0       then iOriginal:=Width-1-(-iOriginal mod Width)
      else if iOriginal>=Width  then iOriginal:=iOriginal mod Width;
      if      jOriginal<0       then jOriginal:=Height-1-(-jOriginal mod Height)
      else if jOriginal>=Height then jOriginal:=jOriginal mod Height;

      RowOriginal:=Scanlines[jOriginal];
      RowRotated^[i]:=RowOriginal[iOriginal];
    end;
    Dst.Scanlines[j]:=RowRotated;
  end;
  FreeMem(RowRotated,Dst.Width*3);
end;

procedure TFastBmp.GrayScale;
var
Tmp:    TFColor;
Line:   PLine;
c,x,y:  Integer;
begin
  for y:=0 to Height-1 do
  begin
    Line:=ScanLines[y];
    for x:=0 to Width-1 do
    begin
      Tmp:=Line^[x];
      c:=Round(Tmp.r*0.3+Tmp.g*0.59+Tmp.b*0.11);
      Tmp.b:=c;
      Tmp.g:=c;
      Tmp.r:=c;
      Line^[x]:=Tmp;
    end;
  end;
end;

procedure TFastBmp.DiscardColor;
var
Tmp:    TFColor;
Line:   PLine;
c,x,y:  Integer;
begin
  for y:=0 to Height-1 do
  begin
    Line:=ScanLines[y];
    for x:=0 to Width-1 do
    begin
      Tmp:=Line^[x];
      c:=Round(Tmp.r+Tmp.g+Tmp.b)div 3;
      Tmp.b:=c;
      Tmp.g:=c;
      Tmp.r:=c;
      Line^[x]:=Tmp;
    end;
  end;
end;

procedure TFastBmp.Sharpen;
begin

end;

//  Interpolated Resampling Based on 'Bitmap Resampler'
//
//  By Anders Melander <anders@melander.dk>
//  -Interpolated Bitmap Resampling using filters.
//
//  v0.04 Optimized w/PLines
//
//  Contributors:
//  Dale Schumacher - "General Filtered Image Rescaling"
//  David Ullrich <ullrich@hardy.math.okstate.edu>

// Hermite filter
function HermiteFilter(Value:Single):Single;
begin
  // f(t) = 2|t|^3 - 3|t|^2 + 1, -1 <= t <= 1
  if(Value<0)then Value:=-Value;
  if(Value<1)then Result:=(2*Value-3)*Sqr(Value)+1
  else Result:=0;
end;

// Box filter
// a.k.a. "Nearest Neighbour" filter
// anme: I have not been able to get acceptable
//       results with this filter for subsampling.
function BoxFilter(Value:Single):Single;
begin
  if(Value>-0.5)and(Value<=0.5)then Result:=1
  else {Value > .5 | < -.5}         Result:=0;
end;

// Triangle filter
// a.k.a. "Linear" or "Bilinear" filter
function TriangleFilter(Value:Single):Single;
begin
  if(Value<0)then Value:=-Value;
  if(Value<1)then Result:=1-Value
  else            Result:=0;
end;

// Bell filter
function BellFilter(Value:Single):Single;
begin
  if(Value<0)then Value:=-Value;
  if(Value<0.5)then Result:=0.75-Sqr(Value)
  else if(Value<1.5)then Result:=0.5*Sqr(Value-1.5)
  else Result:=0;
end;

// B-spline filter
function SplineFilter(Value:Single):Single;
var
tt: Single;
begin
  if(Value<0)then Value:=-Value;
  if(Value<1)then
  begin
    tt:=Sqr(Value);
    Result:=0.5*tt*Value-tt+2/3;
  end else if(Value<2)then
  begin
    Value:=2-Value;
    Result:=1/6*Sqr(Value)*Value;
  end else
    Result:=0;
end;

// Lanczos3 filter
function Lanczos3Filter(Value:Single):Single;
  function SinC(Value:Single):Single;
  begin
    if(Value<>0)then
    begin
      Value:=Value*Pi;
      Result:=Sin(Value)/Value
    end
    else Result:=1;
  end;
begin
  if(Value<0)then Value:=-Value;
  if(Value<3)then Result:=SinC(Value)*SinC(Value/3)
  else Result:=0;
end;

// Mitchell Filter
function MitchellFilter(Value:Single):Single;
const
  C=0.333333333333333333333333333333333;
var
  tt:Single;
begin
  if(Value<0)then Value:=-Value;
  tt:=Sqr(Value);
  if(Value<1)then
  begin
    Value:=(((12-9*C-6*C)*(Value*tt))+
           ((-18+12*C+6*C)*tt)+
           (6-2*C));
    Result:=Value/6;
  end else
  if(Value<2)then
  begin
    Value:=(((-1*C-6*C)*(Value*tt))+
           ((6*C+30*C)*tt)+
           ((-12*C-48*C)*Value)+
           (8*C+24*C));
    Result:=Value/6;
  end else
    Result:=0;
end;

procedure TFastBmp.Resample(Dst:TFastBmp;Filter:TFilterProc;FWidth:Single);
type
// Contributor for a pixel
TContributor=record
  Pixel:  Integer;  // Source pixel
  Weight: Single;  // Pixel weight
end;

TContributorList=array[0..0] of TContributor;
PContributorList=^TContributorList;

// List of source pixels contributing to a destination pixel
TCList=record
  n: Integer;
  p: PContributorList;
end;

TCListList=array[0..0] of TCList;
PCListList=^TCListList;

TRGB=record
r,g,b: Single;
end;

var
Delta,
DestDelta,
SrcWidth,
SrcHeight,
DstWidth,
DstHeight,
i,j,k,
Left,Right,n:   Integer;

xScale,yScale,
Center,Wdth,
fScale,Weight:  Single;

Work:           TFastBmp;
Contrib:        PCListList;
rgb:            TRGB;
Color:          TFColor;
SourceLine,
DestLine:       PLine;
SourcePixel,
DestPixel:      PFColor;

begin
  DstWidth:=Dst.Width;
  DstHeight:=Dst.Height;
  SrcWidth:=Width;
  SrcHeight:=Height;

  Work:=TFastBmp.Create(DstWidth,SrcHeight);

  if(SrcWidth=1)then xScale:=DstWidth/SrcWidth
  else xScale:=(DstWidth-1)/(SrcWidth-1);
  if(SrcHeight=1)then yScale:=DstHeight/SrcHeight
  else yScale:=(DstHeight-1)/(SrcHeight-1);

  GetMem(contrib, DstWidth*SizeOf(TCList));
  // Horizontal sub-sampling
  if(xScale<1)then
  begin
    Wdth:=fWidth/xScale;
    fScale:=1/xScale;
    for i:=0 to DstWidth-1 do
    begin
      Contrib^[i].n:=0;
      GetMem(Contrib^[i].p,Trunc(Wdth*2+1)*SizeOf(TContributor));
      Center:=i/xScale;
      Left:=Round(Center-Wdth);
      Right:=Round(Center+Wdth);
      for j:=Left to Right do
      begin
        Weight:=Filter((Center-j)/fScale)/fScale;
        if(Weight=0)then Continue;
        if(j<0)then n:=-j
        else if(j>=SrcWidth)then n:=SrcWidth-j+SrcWidth-1
        else n:=j;
        k:=Contrib^[i].n;
        Contrib^[i].n :=Contrib^[i].n+1;
        Contrib^[i].p^[k].Pixel:=n;
        Contrib^[i].p^[k].Weight:=Weight;
      end;
    end;
  end else
  // Horizontal super-sampling
  begin
    for i:=0 to DstWidth-1 do
    begin
      Contrib^[i].n:=0;
      GetMem(Contrib^[i].p,Trunc(fWidth*2+1)*SizeOf(TContributor));
      Center:=i/xScale;
      Left:=Round(Center-fWidth);
      Right:=Round(Center+fWidth);
      for j:=Left to Right do
      begin
        Weight:=Filter(Center-j);
        if(Weight=0)then Continue;
        if(j<0)then n:=-j
        else if(j>=SrcWidth)then n:=SrcWidth-j+SrcWidth-1
        else n:=j;
        k:=Contrib^[i].n;
        Contrib^[i].n:=Contrib^[i].n+1;
        Contrib^[i].p^[k].Pixel:=n;
        Contrib^[i].p^[k].Weight:=Weight;
      end;
    end;
  end;

  for k:=0 to SrcHeight-1 do
  begin
    SourceLine:=ScanLines[k];
    DestPixel:=Work.ScanLines[k];
    for i:=0 to DstWidth-1 do
    begin
      rgb.r:=0;
      rgb.g:=0;
      rgb.b:=0;
      for j:=0 to Contrib^[i].n-1 do
      begin
        Color:=SourceLine^[Contrib^[i].p^[j].Pixel];
        Weight:=Contrib^[i].p^[j].Weight;
        if(Weight=0)then Continue;
        rgb.b:=rgb.b+Color.b*Weight;
        rgb.g:=rgb.g+Color.g*Weight;
        rgb.r:=rgb.r+Color.r*Weight;
      end;
      if(rgb.r>255)then Color.r:=255
      else if(rgb.r<0)then Color.r:=0
      else Color.r:=Round(rgb.r);
      if(rgb.g>255)then Color.g:=255
      else if(rgb.g<0)then Color.g:=0
      else Color.g:=Round(rgb.g);
      if(rgb.b>255)then Color.b:=255
      else if(rgb.b<0)then Color.b:=0
      else Color.b:=Round(rgb.b);
      DestPixel^:=Color;
      Inc(DestPixel);
    end;
  end;

  for i:=0 to DstWidth-1 do
  FreeMem(Contrib^[i].p);
  FreeMem(Contrib);

  GetMem(contrib, DstHeight* sizeof(TCList));

  // Vertical sub-sampling
  if(yScale<1)then
  begin
    Wdth:=fWidth/yScale;
    fScale:=1/yScale;
    for i:=0 to DstHeight-1 do
    begin
      Contrib^[i].n:=0;
      GetMem(Contrib^[i].p,Trunc(Wdth*2+1)*SizeOf(TContributor));
      Center:=i/yScale;
      Left:=Round(Center-Wdth);
      Right:=Round(Center+Wdth);
      for j:=Left to Right do
      begin
        Weight:=Filter((Center-j)/fScale)/fScale;
        if(Weight=0)then Continue;
        if(j<0)then n:=-j
        else if(j>=SrcHeight)then n:=SrcHeight-j+SrcHeight-1
        else n:=j;
        k:=Contrib^[i].n;
        Contrib^[i].n:=Contrib^[i].n+1;
        Contrib^[i].p^[k].Pixel:=n;
        Contrib^[i].p^[k].Weight:=Weight;
      end;
    end
  end else
  // Vertical super-sampling
  begin
    for i:=0 to DstHeight-1 do
    begin
      Contrib^[i].n:=0;
      GetMem(Contrib^[i].p,Trunc(fWidth*2+1)*SizeOf(TContributor));
      Center:=i/yScale;
      Left:=Round(Center-fWidth);
      Right:=Round(Center+fWidth);
      for j:=Left to Right do
      begin
        Weight:=Filter(Center-j);
        if(Weight=0)then Continue;
        if(j<0)then n:=-j
        else if(j>=SrcHeight)then n:=SrcHeight-j+SrcHeight-1
        else n:=j;
        k:=Contrib^[i].n;
        Contrib^[i].n:=Contrib^[i].n+1;
        Contrib^[i].p^[k].Pixel:=n;
        Contrib^[i].p^[k].Weight:=Weight;
      end;
    end;
  end;

  SourceLine:=Work.ScanLines[0];
  Delta:=Integer(Work.ScanLines[1])-Integer(SourceLine);
  DestLine:=Dst.ScanLines[0];
  DestDelta:=Integer(Dst.ScanLines[1])-Integer(DestLine);
  for k:=0 to DstWidth-1 do
  begin
    DestPixel:=Pointer(DestLine);
    for i:=0 to DstHeight-1 do
    begin
      rgb.r:=0;
      rgb.g:=0;
      rgb.b:=0;
      for j:=0 to Contrib^[i].n-1 do
      begin
        Color:=PFColor(Integer(SourceLine)+Contrib^[i].p^[j].Pixel*Delta)^;
        Weight:=Contrib^[i].p^[j].Weight;
        if(Weight=0)then Continue;
        rgb.r:=rgb.r+Color.r*Weight;
        rgb.g:=rgb.g+Color.g*Weight;
        rgb.b:=rgb.b+Color.b*Weight;
      end;
      if(rgb.r>255)then Color.r:=255
      else if(rgb.r<0)then Color.r:=0
      else Color.r:=Round(rgb.r);
      if(rgb.g>255)then Color.g:=255
      else if(rgb.g<0)then Color.g:=0
      else Color.g:=Round(rgb.g);
      if(rgb.b>255)then Color.b:=255
      else if(rgb.b<0)then Color.b:=0
      else Color.b:=Round(rgb.b);
      DestPixel^:=Color;
      Inc(Integer(DestPixel),DestDelta);
    end;
    Inc(SourceLine);
    Inc(DestLine);
  end;

  for i:=0 to DstHeight-1 do
  FreeMem(Contrib^[i].p);
  FreeMem(Contrib);
  Work.Free;
end;


destructor TFastBmp.Destroy;
begin
  FreeMem(Calcs,Height*SizeOf(Integer));
  DeleteObject(Handle);
  inherited;
end;

end.
