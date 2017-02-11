unit evutilsBaloon;

interface

type evutilsNotifica = function(titolo: pchar; testo: pchar): boolean; stdcall;
var notifica: evutilsNotifica;

implementation

end.

