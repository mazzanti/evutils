unit CodFiscImp;

interface

var
   com,sesso: char;
   comu,nome,cognome,anno,s,codice,tmp: string[80];
   ss2: string[2];
   jj,l,s1,s2,res,i,let,g,n,gio: integer;
   corretto,maschio,riconosciuto: boolean;

Procedure Main_control();
Procedure somma_s2;
function booleana(s: char): integer;
function _cons(stringa: string;jj: integer): string;
Procedure copia_nome;
Procedure dati_centrali;


Implementation

function booleana(s: char): integer;   { 1 = cons  2 = voc  3 = altro }

 begin
  booleana:=3;
  case s of
   'A','E','I','O','U','a','e','i','o','u': booleana:=2;
   else
    if (s>='A') and (s<='Z') or (s>='a') and (s<='z') then
     booleana:=1;
  end;
 end;


function _cons(stringa: string;jj: integer): string;
 var                        { se jj=1 allora 1,3,4 consonante (nome) }
   i,l,ls: integer;
   st2: string[10];

 begin
  st2:='';
  l:=length(stringa);
  ls:=1;
  i:=1;
  while (ls<=3+jj) and (i<=l) do
   begin
    if booleana(stringa[i])=1 then
     begin
      st2:=st2+copy(stringa,i,1);
      ls:=ls+1;
     end;
    i:=i+1;
   end;
  i:=1;
  if ls<>4+jj then
   begin
    while (ls<=3+jj) do
     begin
      if booleana(stringa[i])=2 then
       begin
        st2:=st2+copy(stringa,i,1);
        ls:=ls+1;
       end;
      i:=i+1;
     end;
   end;
 _cons:=st2;
end;

Procedure copia_nome;
 begin
  tmp:=_cons(nome,1);
  insert(tmp[1],codice,4);          { ritornano 4 caratteri }
  if (booleana(tmp[4])=2) then      { se cons<=3 --> 1ø 2ø 3ø }
   begin
    insert(tmp[2],codice,5);
    insert(tmp[3],codice,6);
   end
  else                              { se cons>3 --> 1ø 3ø 4ø }
   begin
    insert(tmp[3],codice,5);
    insert(tmp[4],codice,6);
   end;
 end;



Procedure dati_centrali;
 begin

  ss2:=copy(anno,3,2);
  insert(ss2,codice,7);

  case g of
   01: s:='A';
   02: s:='B';
   03: s:='C';
   04: s:='D';
   05: s:='E';
   06: s:='H';
   07: s:='L';
   08: s:='M';
   09: s:='P';
   10: s:='R';
   11: s:='S';
   12: s:='T';
  end;
  insert(s,codice,9);

  if maschio=false then gio:=gio+40;
  str(gio, s);
  if gio<10 then s:='0'+s;  
  insert(s,codice,11);
 end;


Procedure somma_s2;
 begin
  case codice[i] of
   'A','0': s2:=s2+1;
   'B','1': s2:=s2+0;
   'C','2': s2:=s2+5;
   'D','3': s2:=s2+7;
   'E','4': s2:=s2+9;
   'F','5': s2:=s2+13;
   'G','6': s2:=s2+15;
   'H','7': s2:=s2+17;
   'I','8': s2:=s2+19;
   'J','9': s2:=s2+21;
   'K': s2:=s2+2;
   'L': s2:=s2+4;
   'M': s2:=s2+18;
   'N': s2:=s2+20;
   'O': s2:=s2+11;
   'P': s2:=s2+3;
   'Q': s2:=s2+6;
   'R': s2:=s2+8;
   'S': s2:=s2+12;
   'T': s2:=s2+14;
   'U': s2:=s2+16;
   'V': s2:=s2+10;
   'W': s2:=s2+22;
   'X': s2:=s2+25;
   'Y': s2:=s2+24;
   'Z': s2:=s2+23;
  end;
 end;

Procedure copiaX;
 begin  
  if (booleana(cognome[1])=2) and (booleana(cognome[2])=1) then
   begin
    insert(cognome[2],codice,jj);
    insert(cognome[1],codice,jj+1);
   end
  else
   insert(cognome,codice,jj);

  insert('X',codice,jj+2);   
 end;


Procedure Main_control();
 begin  
  codice:='';                             { cognome e nome }
  let:=length(cognome);
  if let>2 then
   insert((_cons(cognome,0)),codice,1);    { ritornano i 3 caratteri }
  jj:=1;
  if let=2 then copiaX;
   
  let:=length(nome);
  if let>2 then copia_nome;
  jj:=4;
  if let=2 then copiaX;
  
  dati_centrali;                          { dati centrali }

  l:=1;
  while not( (comu[l]>='0') and (comu[l]<='9') ) do    { posizione del codice }
   l:=l+1;
  l:=l-2;
  delete(comu,1,l);
  delete(comu,5,1);
  insert(comu,codice,14);
  for i:=1 to 15 do                      { carattere di controllo }
   codice[i]:=upcase(codice[i]);
  s1:=0;
  s2:=0;
  i:=2;
  while (i<=14) do
   begin
    if (codice[i]>='0') and (codice[i]<='9') then
     s1:=s1+( ord(codice[i])-ord('0') )
    else     { tra 65 e 90 }
     s1:=s1+( ord(codice[i])-ord('A') );
    i:=i+2;
   end;
   i:=1;
  while (i<=15) do
   begin
    somma_s2;
    i:=i+2;
   end;
  s1:=s1+s2;
  res:=s1 mod 26;
  s:=chr(res+65);
  insert(s, codice, 16);
 end;

end.