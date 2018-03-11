{$N+}

{Utils unit}
Unit U_Util;

Interface
    uses crt, U_Type;

    function countProbabilityOfFailure(statistics : IterarionStatistics) : Double;
    function countAverageAppsInBuffer(sourceIndex : Integer; statistics : IterarionStatistics) : Double;
    function countAverageTimeInBuffer(sourceIndex : Integer; statistics : IterarionStatistics) : Double;


Implementation
    function countProbabilityOfFailure(statistics : IterarionStatistics) : Double;
    var totalReceived, totalRejected, i : Longint;
    begin
        totalReceived := 0;
        totalRejected := 0;

        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            totalRejected := totalRejected + statistics[i].numberOfRejectedApplications;
            totalReceived := totalReceived + statistics[i].numberOfReceivedApplications;
        end;
        countProbabilityOfFailure := totalRejected / (totalRejected + totalReceived);
    end;

    function countAverageAppsInBuffer(sourceIndex : Integer; statistics : IterarionStatistics) : Double;
    var totalNumberOfReceivedApplications: Longint;
        i : Integer;
    begin
        totalNumberOfReceivedApplications := 0;
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            totalNumberOfReceivedApplications := totalNumberOfReceivedApplications +
                                                    statistics[i].numberOfReceivedApplications;
        end;

        countAverageAppsInBuffer := statistics[sourceIndex].numberOfReceivedApplications / 
                                        totalNumberOfReceivedApplications
    end;

    function countAverageTimeInBuffer(sourceIndex : Integer; statistics : IterarionStatistics): Double;
    begin
        countAverageTimeInBuffer := statistics[sourceIndex].timeInBuffer /
                                        statistics[sourceIndex].numberOfReceivedApplications;
    end;
end.
