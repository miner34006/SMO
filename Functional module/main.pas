{$N+} 
{$R-}

uses crt, U_Func;
var
    funcModule : FunctionalModule;
    KMIN : Longint;
    minIntensity, maxIntensity, deltaIntensity : Double;
begin
    clrscr;
    randomize;

    KMIN := 10000;
    minIntensity := 0.5;
    maxIntensity := 1.5;
    deltaIntensity := 0.1;

    funcModule.init(KMIN, minIntensity, maxIntensity, deltaIntensity);
    funcModule.start;
    funcModule.done;
end.
