{$N+}

{Utils unit}
Unit F_Util;

Interface
    uses crt, Types;

    function countProbabilityOfFailure(sourceIndex : Integer; statistics : IterarionStatistics) : Double;
    function countAverageAppsInBuffer(sourceIndex : Integer; statistics : IterarionStatistics) : Double;
    function countAverageWaitingTime(sourceIndex : Integer; statistics : IterarionStatistics) : Double;

Implementation
    function countProbabilityOfFailure(sourceIndex : Integer; statistics : IterarionStatistics) : Double;
    var totalApplications : Longint;
    begin
        totalApplications := statistics[sourceIndex].numRejected +
            statistics[sourceIndex].numReceivedFromSource + statistics[sourceIndex].numReceivedFromBuffer;

        countProbabilityOfFailure := statistics[sourceIndex].numRejected / totalApplications;
    end;

    function countAverageappsInBuffer(sourceIndex : Integer; statistics : IterarionStatistics) : Double;
    var totalApps: Longint;
        i : Integer;
    begin
        totalApps := 0;
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            totalApps := totalApps + statistics[i].numReceivedFromBuffer + 
                statistics[i].numReceivedFromSource + 
                statistics[i].numRejected;
        end;

        countAverageappsInBuffer := statistics[sourceIndex].appsInBuffer / totalApps
    end;

    function countAverageWaitingTime(sourceIndex : Integer; statistics : IterarionStatistics): Double;
    begin
        countAverageWaitingTime := statistics[sourceIndex].timeInBuffer /
            statistics[sourceIndex].numReceivedFromBuffer;
    end;
end.
