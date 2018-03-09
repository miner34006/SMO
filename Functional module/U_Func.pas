{$N+}

{FunctionalUnit unit}
Unit U_Func;

Interface
    uses crt, U_Time, U_Sour, U_Buff, U_Hand, U_Appl;

    const NUMBER_OF_SOURCES = 2;
    Type SourceArray = array[0..NUMBER_OF_SOURCES - 1] of PSource;

    Type FunctionalModule = object
        public
            constructor init(KMIN : Longint; minIntensity, maxIntensity, deltaIntensity: Double);
            destructor  done;
            procedure start;
        
        private
            mSources   : SourceArray; {Sources of the SMO}
            mBuffer    : PBuffer;     {SMO Buffer}
            mHandler : PHandler;  {SMO Handler}

            mKMIN : Longint;
            mMinIntensity : Double;
            mMaxIntensity : Double;
            mDeltaIntensity : Double;

            mOutput : Text;

            function getTheEarliestEvent : Integer;
            function countProbabilityOfFailure : Double;
            function countAverageAppsInBuffer(sourceIndex : Integer) : Double;
            function countaAverageTimeInBuffer(sourceIndex : Integer) : Double;

            procedure handleCreationOfNewApplication(sourceIndex : Integer);
            procedure handleEndOfHandlerWork;

            procedure createSources;
            procedure createBuffer;
            procedure createAppliannce;
            procedure doOneClockCycle;
            procedure zeroData;
            procedure printSMOStats;
            procedure printIterationStats(intensity, probabilityOfFailure, averageTimeInBuffer1, 
                                            averageTimeInBuffer2, averageAppsInBuffer: Double);
    end;


Implementation
    constructor FunctionalModule.init(KMIN : Longint; minIntensity, maxIntensity, deltaIntensity: Double);
    begin
        mKMIN := KMIN;
        mMinIntensity := minIntensity;
        mMaxIntensity := maxIntensity;
        mDeltaIntensity := deltaIntensity;

        assign(mOutput,'output.txt');
        rewrite(mOutput);

        createSources;
        createBuffer;
        createAppliannce;
    end;

    destructor FunctionalModule.done;
    var i: Integer;
    begin
        close(mOutput);

        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            dispose(mSources[i], done);
        end;
        dispose(mBuffer);
        dispose(mHandler);
    end;

    procedure FunctionalModule.createSources;
    var intensity, tay1, tay2 : Double;
        timeBehaviour : PTimeBehaviour;
    begin
        intensity := 0.5;
        timeBehaviour := new(PSimple, init);
        mSources[0] := new(PSource, init(intensity, timeBehaviour));

        tay1 := 0.1; tay2 := 0.5; intensity := 0;
        timeBehaviour := new(PUniform, init(tay1, tay2));
        mSources[1] := new(pSource, init(intensity, timeBehaviour));
    end;

    procedure FunctionalModule.createBuffer;
    var bufferSize : Integer;
    begin
        bufferSize := 2;
        mBuffer := new(PBuffer, init(bufferSize));
    end;

    procedure FunctionalModule.createAppliannce;
    var intensity : Double;
        timeBehaviour : PTimeBehaviour;
    begin
        intensity := 1;
        timeBehaviour := new(PSimple, init);
        mHandler := new(PHandler, init(intensity, timeBehaviour));
    end;

    function FunctionalModule.countProbabilityOfFailure : Double;
    var totalApplications, totalRejected, i : Longint;
    begin
        totalApplications := 0;
        totalRejected := 0;

        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            totalRejected := totalRejected + mSources[i]^.getNumberOfRejectedApplications;
            totalApplications := totalApplications + mSources[i]^.getTotalNumberOfApplications;
        end;
        countProbabilityOfFailure := totalRejected / totalApplications;
    end;

    function FunctionalModule.countAverageAppsInBuffer(sourceIndex : Integer) : Double;
    var totalNumberOfApplications: Longint;
        i : Integer;
    begin
        totalNumberOfApplications := 0;
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            totalNumberOfApplications := totalNumberOfApplications + mSources[i]^.getNumberOfReceivedApplications;
        end;

        countAverageAppsInBuffer := mSources[sourceIndex]^.getNumberOfReceivedApplications / 
                                        totalNumberOfApplications
    end;

    function FunctionalModule.countaAverageTimeInBuffer(sourceIndex : Integer): Double;
    begin
        countaAverageTimeInBuffer := mSources[sourceIndex]^.getTimeInBuffer /
                                        mSources[sourceIndex]^.getNumberOfReceivedApplications;
    end;

    procedure FunctionalModule.start;
    var intensity, probabilityOfFailure, averageAppsInBuffer, averageTimeInBuffer1,averageTimeInBuffer2 : double;
    begin
        printSMOStats;

        intensity := mMinIntensity;
        while intensity < mMaxIntensity + mDeltaIntensity do begin

            mSources[0]^.setIntensity(intensity);
            mSources[0]^.postApplication;
            mSources[1]^.postApplication;

            while (mSources[0]^.getTotalNumberOfApplications < mKMIN) or 
                  (mSources[1]^.getTotalNumberOfApplications < mKMIN) do begin
                doOneClockCycle;
            end;

            probabilityOfFailure := countProbabilityOfFailure;
            averageAppsInBuffer := countAverageAppsInBuffer(0);
            averageTimeInBuffer1 := countaAverageTimeInBuffer(0);
            averageTimeInBuffer2 := countaAverageTimeInBuffer(1);
        
            printIterationStats(intensity, probabilityOfFailure, averageTimeInBuffer1,
                                averageTimeInBuffer2, averageAppsInBuffer);
            
            zeroData;
            intensity := intensity + mDeltaIntensity;
        end;
    end;

    procedure FunctionalModule.printSMOStats;
    begin
        writeln(mOutput, 'KMIN                    = ', mKMIN:5);
        writeln(mOutput, 'DELTA LAMBDA            = ', mDeltaIntensity:4:2);
        writeln(mOutput, 'MIN LAMBDA (1st source) = ', mMinIntensity:4:2);
        writeln(mOutput, 'MAX LAMBDA (1st source) = ', mMaxIntensity:4:2);
        writeln(mOutput, '');
    end;

    procedure FunctionalModule.printIterationStats(intensity, probabilityOfFailure, averageTimeInBuffer1,
                                            averageTimeInBuffer2, averageAppsInBuffer: Double);
    begin
        writeln(mOutput, 'Lambda = ', intensity:5:1);
        writeln(mOutput, '    * Probability Of Failure (1st+2nd)     = ', probabilityOfFailure:8:3);
        writeln(mOutput, '    * Average wating time (1st source)     = ', averageTimeInBuffer1:8:3);
        writeln(mOutput, '    * Average wating time (2nd source)     = ', averageTimeInBuffer2:8:3);
        writeln(mOutput, '    * Average apps (1st source) in Buffer  = ', averageAppsInBuffer:8:3);
        writeln(mOutput, '');
    end;

    procedure FunctionalModule.handleCreationOfNewApplication(sourceIndex : Integer);
    var hasAdded: Boolean;
        app : PApplication;
    begin
        app := new(PApplication, init(sourceIndex, mSources[sourceIndex]^.getPostTime));

        hasAdded := mBuffer^.addApplication(app);
        if (hasAdded = false) then begin
            {There is not enough space in Buffer(has not add the application)}
            mSources[sourceIndex]^.increaseNumberOfRejectedApplications;
            dispose(app);
        end;
        mSources[sourceIndex]^.postApplication;
        mHandler^.changeWorkStatus(true);
    end;

    procedure FunctionalModule.handleEndOfHandlerWork;
    var app : PApplication;
    begin
        if (mBuffer^.hasApplications) then begin
            app := mBuffer^.removeApplication;
            mSources[app^.getSourceNumber]^.increaseNumberOfReceivedApplications;
            if app^.getTimeOfCreation < mHandler^.getFinishTime then begin
                {Application was waiting Handler in Buffer}
                mSources[app^.getSourceNumber]^.increeseTimeInBuffer(mHandler^.getFinishTime - app^.getTimeOfCreation);
                mHandler^.generateFinishTime(mHandler^.getFinishTime);
            end else begin
                {Application was not waiting Handler in Buffer}
                mHandler^.generateFinishTime(app^.getTimeOfCreation);
            end;
            dispose(app);
        end else begin
            mHandler^.changeWorkStatus(false);
        end;
    end;

    procedure FunctionalModule.doOneClockCycle;
    var earliestEvent : Integer;
        hasAdded : Boolean;
        app : PApplication;
    begin
        earliestEvent := getTheEarliestEvent;

        if (earliestEvent <> -1) then begin
            {One of the sources has made the application}
            handleCreationOfNewApplication(earliestEvent);
        end else begin
            {The Handler finished work}
            handleEndOfHandlerWork;
        end;
    end;

    procedure FunctionalModule.zeroData;
    var i: Integer;
    begin
        mBuffer^.zeroData;
        mHandler^.zeroData;
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            mSources[i]^.zeroData;
        end;
    end;

    function FunctionalModule.getTheEarliestEvent;
    var HandlerTime, minTime: Double;
        i, eventMarker: Integer;
    begin
        {Shows the earliest event:
            * 0..N - one of the sources generate application (source number is eventMarker);
            * -1   - Applance ends it's work;}

        eventMarker := -1;
        minTime := -1;

        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            if (minTime = -1) or (minTime > mSources[i]^.getPostTime) then begin
                minTime := mSources[i]^.getPostTime;
                eventMarker := i;
            end;
        end;

        if (not mHandler^.canWork) then begin
            {The Handler has not yet received processing orders}
            getTheEarliestEvent := eventMarker;
            exit;
        end else if (minTime > mHandler^.getFinishTime) then begin
            eventMarker := -1;
       end;

        getTheEarliestEvent := eventMarker;
    end;
end.
