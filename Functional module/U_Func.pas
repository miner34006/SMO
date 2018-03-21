{$N+}

{FunctionalUnit unit}
Unit U_Func;

Interface
    uses crt, U_Time, U_Sour, U_Buff, U_Hand, U_Appl, U_Prin, U_Type, U_Util, U_Sele;

    Type FunctionalModule = object
        public
            constructor init(settings : SystemSettings);
            destructor  done;
            procedure start;
        
        private
            mSources   : SourceArray; {Sources of the SMO}
            mBuffer    : PBuffer;     {SMO Buffer}
            mHandler   : PHandler;    {SMO Handler}
            mPrinter   : PPrinter;

            mSettings : SystemSettings;
            mIterarionStatistics : IterarionStatistics;
            
            procedure createSources;
            procedure createBuffer;
            procedure createAppliannce;

            function getTheEarliestEvent : Integer;
            function getNumberOfGeneratedApplications(sourceIndex : Integer) : Longint;

            procedure handleCreationOfNewApplication(sourceIndex : Integer);
            procedure handleEndOfHandlerWork;
            procedure doOneClockCycle;
            procedure zeroData;

            procedure rejectApplication(sourceIndex : Integer);
            procedure receiveApplication(sourceIndex : Integer);
            procedure increeseTimeInBuffer(sourceIndex : Integer; time : Double);
            procedure increeseTimeInHandler(sourceIndex : Integer; time : Double);
    end;

    Type PFunctionalModule = ^FunctionalModule;


Implementation
    constructor FunctionalModule.init(settings: SystemSettings);
    begin
        mSettings := settings;
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
        dispose(mPrinter, done);
        dispose(mBuffer, done);
        dispose(mHandler, done);
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
    var selectionStrategy : PSelectionStrategy;
    begin
        selectionStrategy := new(PNonPrioritySelection, init);
        mBuffer := new(PBuffer, init(selectionStrategy));
    end;

    procedure FunctionalModule.createAppliannce;
    var intensity : Double;
        timeBehaviour : PTimeBehaviour;
    begin
        intensity := 1;
        timeBehaviour := new(PSimple, init);
        mHandler := new(PHandler, init(intensity, timeBehaviour));
    end;

    procedure FunctionalModule.start;
    var intensity, probabilityOfFailure, averageAppsInBuffer, averageTimeInBuffer1,averageTimeInBuffer2 : double;
    begin
        mPrinter^.printSystemSettings(mSettings);

        intensity := mSettings.minIntensity;
        while intensity < mSettings.maxIntensity + mSettings.deltaIntensity do begin

            mSources[CHANGING_SOURCE - 1]^.setIntensity(intensity);

            {FIRST POST APPLICATION SECTION}
            mSources[0]^.postApplication;
            mSources[1]^.postApplication;

            while (getNumberOfGeneratedApplications(0) < mSettings.KMIN) or 
                  (getNumberOfGeneratedApplications(1) < mSettings.KMIN) do begin
                doOneClockCycle;
            end;

            {COUNT ITERATION RESULTS SECTION}
            probabilityOfFailure := countProbabilityOfFailure(mIterarionStatistics);
            averageAppsInBuffer := countAverageAppsInBuffer(0, mIterarionStatistics);
            averageTimeInBuffer1 := countAverageTimeInBuffer(0, mIterarionStatistics);
            averageTimeInBuffer2 := countAverageTimeInBuffer(1, mIterarionStatistics);
        
            mPrinter^.printIterationStats(intensity, probabilityOfFailure, averageTimeInBuffer1,
                                averageTimeInBuffer2, averageAppsInBuffer);
            
            zeroData;
            intensity := intensity + mSettings.deltaIntensity;
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

    procedure FunctionalModule.handleCreationOfNewApplication(sourceIndex : Integer);
    var hasAdded: Boolean;
        app : PApplication;
    begin
        app := new(PApplication, init(sourceIndex, mSources[sourceIndex]^.getPostTime));

        hasAdded := mBuffer^.addApplication(app);
        if (hasAdded = false) then begin
            {There is not enough space in Buffer(has not add the application)}
            rejectApplication(sourceIndex);
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
            receiveApplication(app^.getSourceNumber);
            if app^.getTimeOfCreation < mHandler^.getFinishTime then begin
                {Application was waiting Handler in Buffer}
                increeseTimeInBuffer(app^.getSourceNumber, mHandler^.getFinishTime - app^.getTimeOfCreation);
                increeseTimeInHandler(app^.getSourceNumber, mHandler^.generateFinishTime(mHandler^.getFinishTime));
            end else begin
                {Application was not waiting Handler in Buffer}
                increeseTimeInHandler(app^.getSourceNumber, mHandler^.generateFinishTime(app^.getTimeOfCreation));
            end;
            dispose(app);
        end else begin
            mHandler^.changeWorkStatus(false);
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

    procedure FunctionalModule.zeroData;
    var i: Integer;
    begin
        mBuffer^.zeroData;
        mHandler^.zeroData;
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            mSources[i]^.zeroData;
            mIterarionStatistics[i].timeInBuffer := 0;
            mIterarionStatistics[i].timeInHandler := 0;
            mIterarionStatistics[i].numberOfReceivedApplications := 0;
            mIterarionStatistics[i].numberOfRejectedApplications := 0;
        end;
    end;

    function FunctionalModule.getNumberOfGeneratedApplications(sourceIndex : Integer) : Longint;
    begin
        getNumberOfGeneratedApplications := mIterarionStatistics[sourceIndex].numberOfRejectedApplications +
                                                mIterarionStatistics[sourceIndex].numberOfReceivedApplications
    end;

    procedure FunctionalModule.rejectApplication(sourceIndex : Integer);
    begin
        Inc(mIterarionStatistics[sourceIndex].numberOfRejectedApplications);
    end;

    procedure FunctionalModule.receiveApplication(sourceIndex : Integer);
    begin
        Inc(mIterarionStatistics[sourceIndex].numberOfReceivedApplications);
    end;

    procedure FunctionalModule.increeseTimeInBuffer(sourceIndex : Integer; time : Double);
    begin
        mIterarionStatistics[sourceIndex].timeInBuffer := mIterarionStatistics[sourceIndex].timeInBuffer + time;
    end;

    procedure FunctionalModule.increeseTimeInHandler(sourceIndex : Integer; time : Double);
    begin
        mIterarionStatistics[sourceIndex].timeInHandler := mIterarionStatistics[sourceIndex].timeInHandler + time;
    end;
end.
