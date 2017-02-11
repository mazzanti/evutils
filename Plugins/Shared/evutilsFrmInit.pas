unit evutilsFrmInit;

interface

uses forms, windows, controls;

procedure inizializza(f: tform);

implementation

procedure inizializza(f: tform);
var
  i: integer;
begin
//  f.Position := poScreenCenter;
//  f.BorderStyle := bsToolWindow;
//  setwindowlong(f.Handle, GWL_EXSTYLE, getwindowlong(f.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW);
  for i := 0 to f.ComponentCount - 1 do
    if (f.Components[i] is twincontrol) then
      setparent(twincontrol(f.Components[i]).Handle, twincontrol(f.Components[i]).Parent.Handle);
end;

end.

