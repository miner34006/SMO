{$N+}

{Types unit}
Unit U_Type;

Interface
    uses crt;

    const NUMBER_OF_SOURCES = 2;
    const BUFFER_SIZE = 2;
    const CHANGING_SOURCE = 1;

    Type DoubleArray = array[0..NUMBER_OF_SOURCES - 1] of Double;

    Type SystemSettings = record
        KMIN           : Longint;
        minIntensity   : Double;
        maxIntensity   : Double;
        deltaIntensity : Double;
    end;

    Type SourceStatistics = record
        timeInBuffer                 : Double;
        timeInHandler                : Double;

        numReceivedFromSource        : Longint;
        numReceivedFromBuffer        : Longint;
        numRejected                  : Longint;
        
        appsInBuffer                 : Longint;
    end;

    Type IterarionStatistics = array [0..NUMBER_OF_SOURCES - 1] of SourceStatistics;


Implementation
    
end.
