unit PopupFunzioni;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, XPMan, StdCtrls, BoxList, ExtCtrls, plugin, kutils;

type
  TFPopoupFunzioni = class(TForm)
    Panel1: TPanel;
    BoxList1: TBoxList;
    procedure FormCreate(Sender: TObject);
    procedure BoxList1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPopoupFunzioni: TFPopoupFunzioni;

implementation

uses MainCore;

{$R *.dfm}

procedure TFPopoupFunzioni.BoxList1Click(Sender: TObject);
var
  kfunzione: TevFunction;
  Par: PParametroChiamata;
begin
  if BoxList1.CurentItem > 0 then
  begin
    kfunzione := TevFunction(BoxList1.items.Objects[BoxList1.CurentItem - 1]);
    new(Par);
    Par.Funzione := kfunzione;
    Par.FromHotkey := false;
    StartThread(@MainCore.AvviaFunzione, Par);
    hide;
    if not (Settings.semprevisibile) then
      fevutils.hide;
  end;
end;

procedure TFPopoupFunzioni.FormCreate(Sender: TObject);
begin
//metto on top..
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;



end.

