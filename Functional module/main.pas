{$N+} 
{$R-}

uses crt, U_Func, U_Type;
var
    funcModule : FunctionalModule;
    settings : SystemSettings;
    KMIN : Longint;
    minIntensity, maxIntensity, deltaIntensity : Double;
begin
    clrscr;
    randomize;

    settings.KMIN := 10000;
    settings.minIntensity := 0.5;
    settings.maxIntensity := 1.5;
    settings.deltaIntensity := 0.1;

    funcModule.init(settings);
    funcModule.start;
    funcModule.done;
end.
