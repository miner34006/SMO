{$N+}

Unit Utils;

Interface
    uses crt, Types;

    {Подсчет вероятности отказа}
    function countProbabilityOfFailure(sourceIndex : Integer; statistics : IterarionStatistics) : Double;
    {Подсчет среднего кол-ва заявок в буфере}
    function countAverageAppsInBuffer(sourceIndex : Integer; statistics : IterarionStatistics) : Double;
    {Подсчет среднего времени ожидания}
    function countAverageWaitingTime(sourceIndex : Integer; statistics : IterarionStatistics) : Double;

Implementation
    function countProbabilityOfFailure(sourceIndex : Integer; statistics : IterarionStatistics) : Double;
    var totalApplications : Longint;
    begin
        totalApplications := statistics[sourceIndex].numRejected +
            statistics[sourceIndex].numReceivedFromSource + statistics[sourceIndex].numReceivedFromBuffer;

        if (totalApplications = 0) then begin
            countProbabilityOfFailure := 0.0;
        end else begin
            countProbabilityOfFailure := statistics[sourceIndex].numRejected / totalApplications;
        end;        
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
