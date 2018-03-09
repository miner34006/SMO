{$N+}

{FunctionalUnit unit}
Unit U_Func;

Interface
    uses crt, U_Time, U_Sour, U_Buff, U_Hand, U_Appl, U_Prin;

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
            mPrinter : PPrinter;

            mKMIN : Longint;
            mMinIntensity : Double;
            mMaxIntensity : Double;
            mDeltaIntensity : Double;

            function getKMIN : Longint;
            function getMinIntensity : Double;
            function getMaxIntensity : Double;
            function getDeltaIntensity : Double;


            function countProbabilityOfFailure : Double;
            function countAverageAppsInBuffer(sourceIndex : Integer) : Double;
            function countAverageTimeInBuffer(sourceIndex : Integer) : Double;

            procedure createSources;
            procedure createBuffer;
            procedure createAppliannce;

            function getTheEarliestEvent : Integer;
            procedure doOneClockCycle;
            procedure zeroData;
            procedure handleCreationOfNewApplication(sourceIndex : Integer);
            procedure handleEndOfHandlerWork;
    end;

    Type PFunctionalModule = ^FunctionalModule;


Implementation
    constructor FunctionalModule.init(KMIN : Longint; minIntensity, maxIntensity, deltaIntensity: Double);
    begin
        mKMIN := KMIN;
        mMinIntensity := minIntensity;
        mMaxIntensity := maxIntensity;
        mDeltaIntensity := deltaIntensity;

        mPrinter := new(PPrinter, init);

        createSources;
        createBuffer;
        createAppliannce;
    end;

    destructor FunctionalModule.done;
    var i: Integer;
    begin
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
    var totalNumberOfReceivedApplications: Longint;
        i : Integer;
    begin
        totalNumberOfReceivedApplications := 0;
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            totalNumberOfReceivedApplications := totalNumberOfReceivedApplications +
                                                    mSources[i]^.getNumberOfReceivedApplications;
        end;

        countAverageAppsInBuffer := mSources[sourceIndex]^.getNumberOfReceivedApplications / 
                                        totalNumberOfReceivedApplications
    end;

    function FunctionalModule.countAverageTimeInBuffer(sourceIndex : Integer): Double;
    begin
        countAverageTimeInBuffer := mSources[sourceIndex]^.getTimeInBuffer /
                                        mSources[sourceIndex]^.getNumberOfReceivedApplications;
    end;

    procedure FunctionalModule.start;
    var intensity, probabilityOfFailure, averageAppsInBuffer, averageTimeInBuffer1,averageTimeInBuffer2 : double;
    begin
        mPrinter^.printSMOStats(self);

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
            averageTimeInBuffer1 := countAverageTimeInBuffer(0);
            averageTimeInBuffer2 := countAverageTimeInBuffer(1);
        
            mPrinter^.printIterationStats(intensity, probabilityOfFailure, averageTimeInBuffer1,
                                averageTimeInBuffer2, averageAppsInBuffer);
            
            zeroData;
            intensity := intensity + mDeltaIntensity;
        end;
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
        if (not mBuffer^.empty) then begin
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

    function FunctionalModule.getKMIN : Longint;
    begin
        getKMIN := mKMIN;
    end;

    function FunctionalModule.getMinIntensity : Double;
    begin
        getMinIntensity := mMinIntensity;
    end;

    function FunctionalModule.getMaxIntensity : Double;
    begin
        getMaxIntensity := mMaxIntensity;    
    end;

    function FunctionalModule.getDeltaIntensity : Double;
    begin
        getDeltaIntensity := mDeltaIntensity;
    end;
end.
