unit Definizioni;

interface

type ParametriQuery = record
    nome: pchar;
    versione: pchar;
    descrizione:pchar;
    lang: integer;
    id:pchar;
    funzioni: pbyte;
  end;

type PParametriQuery = ^ParametriQuery;

type ParametriInit = record
    FNotifica: Pointer;
    Working_dir: pchar;
    lang: integer;
  end;

type PParametriInit = ^ParametriInit;

type ParametriFree = record
  end;

type PParametriFree = ^ParametriFree;

type ParametriFunction = record
  numero: byte;
  nome: pchar;
  id: pchar;
  address: ppointer;
end;

type PParametriFunction = ^ParametriFunction;


type ParametriFunzioneGenerica = record
    FromHotkey: boolean;
    ChangeMenuName:boolean;
    MenuName:pchar;
    parametro:integer;
  end;

type PParametriFunzioneGenerica = ^ParametriFunzioneGenerica;

type
  DLLevutilsQuery = function(Parametri: PParametriQuery): integer; stdcall;
  DLLevutilsInit = function(Parametri: PParametriInit): integer; stdcall;
  DLLevutilsFunction = function(Parametri:PParametriFunction): integer; stdcall;
  DLLevutilsFree = function(Parametri: PParametriFree): integer; stdcall;
  GenericFunction = Function(Parametri: PParametriFunzioneGenerica):integer; stdcall;

implementation

end.

