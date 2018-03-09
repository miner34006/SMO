{$N+}

{Printer unit}
Unit U_Prin;

Interface
    uses crt;

    Type Printer = object
        public
            constructor init;
            destructor  done;

            procedure printIterationStats(intensity, probabilityOfFailure, averageTimeInBuffer1, 
                                            averageTimeInBuffer2, averageAppsInBuffer: Double);
            procedure printSMOStats(deltaIntensity, minIntensity, maxIntensity : Double; KMIN : Longint);

        private
            mOutput : Text;
    end;

    Type PPrinter = ^Printer;


Implementation
    constructor Printer.init;
    begin
        assign(mOutput,'output.txt');
        rewrite(mOutput);
    end;

    destructor Printer.done;
    begin
        close(mOutput);
    end;

    procedure Printer.printIterationStats(intensity, probabilityOfFailure, averageTimeInBuffer1, 
                                            averageTimeInBuffer2, averageAppsInBuffer: Double);
    begin
        writeln(mOutput, 'Lambda = ', intensity:5:1);
        writeln(mOutput, '    * Probability Of Failure (1st+2nd)     = ', probabilityOfFailure:8:3);
        writeln(mOutput, '    * Average wating time (1st source)     = ', averageTimeInBuffer1:8:3);
        writeln(mOutput, '    * Average wating time (2nd source)     = ', averageTimeInBuffer2:8:3);
        writeln(mOutput, '    * Average apps (1st source) in Buffer  = ', averageAppsInBuffer:8:3);
        writeln(mOutput, '');
    end;

    procedure Printer.printSMOStats(deltaIntensity, minIntensity, maxIntensity : Double; KMIN : Longint);
    begin
        writeln(mOutput, 'KMIN                    = ', KMIN:5);
        writeln(mOutput, 'DELTA LAMBDA            = ', deltaIntensity:4:2);
        writeln(mOutput, 'MIN LAMBDA (1st source) = ', minIntensity:4:2);
        writeln(mOutput, 'MAX LAMBDA (1st source) = ', maxIntensity:4:2);
        writeln(mOutput, '');
    end;
end.
