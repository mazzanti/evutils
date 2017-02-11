unit Plugin;

interface

uses
  windows, classes, graphics, sysutils, definizioni, inifiles;

const
  _MAXNOMEPLUGIN = 255;

type
  TevPlugin = class(TObject)

  public
    id: integer;
    idplugin: pchar;
    DLLHandle: THandle;
    nomeplugin: pchar;
    versione: pchar;
    descrizione: pchar;
    nfunzioni: byte;
    funzioni: TList;
    icona: ticon;
  public
    constructor Create;
    destructor Destroy; override;
  end;


type
  TevFunction = class(TObject)

  private
    parent: TevPlugin;
  public
    address: Pointer;
    NomeFunzione: pchar;
    id: pchar;
    HotKey: Cardinal;
  public
    constructor Create(p: TevPlugin);
    destructor Destroy; override;
  end;


type ParametroChiamata = record
    FromHotkey: boolean;
    Funzione: TevFunction;
  end;
type PParametroChiamata = ^ParametroChiamata;

implementation

constructor TevPlugin.Create;
begin
  inherited;
  id := -1;
  getmem(idplugin, _MAXNOMEPLUGIN);
  getmem(nomeplugin, _MAXNOMEPLUGIN);
  getmem(versione, _MAXNOMEPLUGIN);
  getmem(descrizione, _MAXNOMEPLUGIN);
  icona := ticon.Create;
end;

destructor TevPlugin.Destroy;
var
  Dllfree: DLLevutilsFree;
  i: integer;
begin
  inherited;
  if id <> -1 then
  begin
    @Dllfree := GetProcAddress(DLLHandle, 'evutilsfree');
    if Assigned(Dllfree) then
      Dllfree(nil);

    i := nfunzioni - 1;
    while (i >= 0) do
    begin
      TevFunction(funzioni.Items[i]).Free;
      funzioni.Delete(i);
      dec(i);
    end;
    funzioni.Free;

  end;
  freelibrary(DLLHandle);
  freemem(idplugin, _MAXNOMEPLUGIN);
  freemem(nomeplugin, _MAXNOMEPLUGIN);
  freemem(versione, _MAXNOMEPLUGIN);
  freemem(descrizione, _MAXNOMEPLUGIN);
  icona.Free;

end;

//------------------------------------

constructor TevFunction.Create(p: TevPlugin);
begin
  inherited Create;
  getmem(NomeFunzione, _MAXNOMEPLUGIN);
  getmem(id, _MAXNOMEPLUGIN);
  parent := p;
end;

destructor TevFunction.Destroy;
begin
  inherited;
  freemem(NomeFunzione, _MAXNOMEPLUGIN);
  freemem(id, _MAXNOMEPLUGIN);
end;

end.

