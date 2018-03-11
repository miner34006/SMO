{$N+}

{Types unit}
Unit U_Type;

Interface
    uses crt;

    const NUMBER_OF_SOURCES = 2;
    const BUFFER_SIZE = 2;

    Type SystemSettings = record
        KMIN           : Longint;
        minIntensity   : Double;
        maxIntensity   : Double;
        deltaIntensity : Double;
    end;

    Type SourceStatistics = record
        timeInBuffer                 :  Double; 
        numberOfReceivedApplications :  Longint;
        numberOfRejectedApplications :  Longint; 
    end;

    Type IterarionStatistics = array [0..NUMBER_OF_SOURCES - 1] of SourceStatistics;


Implementation
    
end.
