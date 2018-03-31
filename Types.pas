{$N+}

{Types unit}
Unit Types;

Interface
    uses crt;

    const NUMBER_OF_SOURCES = 2;
    const BUFFER_SIZE = 2;
    const CHANGING_SOURCE = 1;

    Type DoubleArray = array[0..NUMBER_OF_SOURCES - 1] of Double;

    Type SystemSettings = record
        KMIN           : Double;
        minIntensity   : Double;
        maxIntensity   : Double;
    end;

    Type RResults = record
        intensity : Double;
        probabilityOfFailure : DoubleArray;
        averageWaitingTime : DoubleArray;
        averageAppsInBuffer : DoubleArray;
    end;

    Type ResultFile = file of RResults;

    Type PDouble = ^Double;
         PSystemSettings = ^SystemSettings;

    Type SourceStatistics = record
        timeInBuffer                 : Double;
        timeInHandler                : Double;

        numReceivedFromSource        : Longint;
        numReceivedFromBuffer        : Longint;
        numRejected                  : Longint;
        
        appsInBuffer                 : Longint;
    end;

    Type IterarionStatistics = array [0..NUMBER_OF_SOURCES - 1] of SourceStatistics;
         PIterarionStatistics = ^IterarionStatistics;


Implementation
    
end.
