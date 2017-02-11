unit evutilsDatabase;

interface

uses stdctrls,comctrls;

type pprestito = record
  titolo:string;
  cosa:string;
  achi:string;
  restituito:byte;
end;

procedure riempilista(testo:TMemo;lista:TListView);

implementation

function cetab(asd:string):integer;
var c:byte;
begin
 c:=1;
  while(asd[c]<>' ') do
  inc(c);
 result:=0;
end;

procedure riempilista(testo:TMemo;lista:TListView);
var db:pprestito;
elemento:TListItem;
clinea,ccarattere:byte;
begin
 for clinea := 0 to testo.Lines.Count - 1 do
 begin
  //conto linea per linea.

  //guardo se c sono dei tab.. se non ci sono, è il nome del db
  if cetab(testo.Lines.Strings[clinea])=0 then
   db.titolo:=testo.Lines.Strings[clinea];
 end;

end;

end.
