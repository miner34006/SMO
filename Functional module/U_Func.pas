{$N+}

{FunctionalUnit unit}
Unit U_Func;

Interface
    uses crt, U_Time, U_Sour, U_Buff, U_Hand, U_Appl, U_Prin, U_Type, U_Util, U_Sele;

    Type FunctionalModule = object
        public
            constructor init;
            destructor  done;
            
            function getStatistics: IterarionStatistics;
            function allSourcesHaveGeneratedKmin: Boolean;

            procedure setIntensity(intensity : Double);
            procedure zeroData;
            procedure doIteration;
        
        private
            mSources   : SourceArray;
            mBuffer    : PBuffer;
            mHandler   : PHandler;
            mPrinter   : PPrinter;

            mIterarionStatistics : IterarionStatistics;
            
            procedure createSources;
            procedure createBuffer;
            procedure createHandler;
            procedure postFirstApplications;

            function getEarliestEvent : Integer;
            function getEarliestSource: Integer;
            
            function getNumberOfGeneratedApplications(sourceIndex : Integer) : Longint;
            procedure handleCreationOfNewApplication(sourceIndex : Integer);
            procedure handleEndOfHandlerWork;
            
            procedure rejectApplication(sourceIndex : Integer);
            procedure receiveFromBuffer(sourceIndex : Integer);
            procedure receiveFromSource(sourceIndex : Integer);
            
            procedure increeseTimeInBuffer(sourceIndex : Integer; time : Double);
            procedure increeseTimeInHandler(sourceIndex : Integer; time : Double);
            procedure increeseAppsInBuffer(sourceIndex : Integer; num : Integer);
    end;

    Type PFunctionalModule = ^FunctionalModule;


Implementation
    constructor FunctionalModule.init;
    var i : Integer;
    begin
        mPrinter := new(PPrinter, init);

        createSources;
        createBuffer;
        createHandler;

        postFirstApplications;
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

    procedure FunctionalModule.postFirstApplications;
    var i: Integer;
    begin
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            mSources[i]^.postApplication;
        end;
    end;

    procedure FunctionalModule.setIntensity(intensity : Double);
    begin
        mSources[CHANGING_SOURCE - 1]^.setIntensity(intensity);
    end;

    function FunctionalModule.getStatistics: IterarionStatistics;
    begin
        getStatistics := mIterarionStatistics;
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

    procedure FunctionalModule.createHandler;
    var intensity : Double;
        timeBehaviour : PTimeBehaviour;
    begin
        intensity := 1;
        timeBehaviour := new(PSimple, init);
        mHandler := new(PHandler, init(intensity, timeBehaviour));
    end;

    function FunctionalModule.allSourcesHaveGeneratedKmin: Boolean;
    var i : Integer;
    begin
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            if (getNumberOfGeneratedApplications(i) < mSettings.KMIN) then begin
                allSourcesHaveGeneratedKmin := false;
                exit;
            end;
        end;

        allSourcesHaveGeneratedKmin := true;
    end;

    procedure FunctionalModule.doIteration;
    var earliestEvent : Integer;
    begin
        earliestEvent := getEarliestEvent;

        if (earliestEvent <> -1) then begin
            handleCreationOfNewApplication(earliestEvent);
        end else begin
            handleEndOfHandlerWork;
        end;
    end;

    procedure FunctionalModule.handleCreationOfNewApplication(sourceIndex : Integer);
    var hasAdded: Boolean;
        app : PApplication
        i : Integer;
    begin
        app := new(PApplication, init(sourceIndex, mSources[sourceIndex]^.getPostTime));

        hasAdded := mBuffer^.addApplication(app);
        if (hasAdded = false) then begin
            rejectApplication(sourceIndex);
            dispose(app);
        end;
        mSources[sourceIndex]^.postApplication;

        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            increeseAppsInBuffer(i, mBuffer^.getNumberOfApps(i));
        end;
    end;

    procedure FunctionalModule.handleEndOfHandlerWork;
    var app : PApplication;
        earliestSource: Integer;
        timeInHandler : Double;
    begin
        if (not mBuffer^.empty) then begin
            app := mBuffer^.removeApplication;
            increeseTimeInBuffer(app^.getSourceNumber, mHandler^.getFinishTime - app^.getTimeOfCreation);
            timeInHandler := mHandler^.generateFinishTime(mHandler^.getFinishTime);
            increeseTimeInHandler(app^.getSourceNumber, timeInHandler);
            receiveFromBuffer(app^.getSourceNumber);
            dispose(app);

        end else begin
            earliestSource := getEarliestSource;
            timeInHandler := mHandler^.generateFinishTime(mSources[earliestSource]^.getPostTime);
            increeseTimeInHandler(earliestSource, timeInHandler);
            receiveFromSource(earliestSource);
            mSources[earliestSource]^.postApplication;
        end;
    end;

    function FunctionalModule.getEarliestEvent;
    var HandlerTime, sourceTime: Double;
        i, eventMarker: Integer;
    begin
        {Shows the earliest event:
            * 0..N - one of the sources generate application (source number is eventMarker);
            * -1   - Applance ends it's work;}

        eventMarker := getEarliestSource;
        sourceTime := mSources[eventMarker]^.getPostTime;

        if (mHandler^.getFinishTime < sourceTime) then begin
            eventMarker := -1;
        end;

        getEarliestEvent := eventMarker;
    end;

    function FunctionalModule.getEarliestSource: Integer;
    var minTime: Double;
        i, sourceIndex: Integer;
    begin
        sourceIndex := -1;
        minTime := -1;

        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            if (minTime = -1) or (mSources[i]^.getPostTime < minTime) then begin
                minTime := mSources[i]^.getPostTime;
                sourceIndex := i;
            end;
        end;

        getEarliestSource := sourceIndex;
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

            mIterarionStatistics[i].numReceivedFromBuffer := 0;
            mIterarionStatistics[i].numReceivedFromSource := 0;
            mIterarionStatistics[i].numRejected := 0;

            mIterarionStatistics[i].appsInBuffer := 0;
        end;
        postFirstApplications;
    end;

    function FunctionalModule.getNumberOfGeneratedApplications(sourceIndex : Integer) : Longint;
    begin
        getNumberOfGeneratedApplications := mIterarionStatistics[sourceIndex].numRejected +
            mIterarionStatistics[sourceIndex].numReceivedFromSource +
            mIterarionStatistics[sourceIndex].numReceivedFromBuffer
    end;

    procedure FunctionalModule.rejectApplication(sourceIndex : Integer);
    begin
        Inc(mIterarionStatistics[sourceIndex].numRejected);
    end;

    procedure FunctionalModule.receiveFromBuffer(sourceIndex : Integer);
    begin
        Inc(mIterarionStatistics[sourceIndex].numReceivedFromBuffer);
    end;

    procedure FunctionalModule.receiveFromSource(sourceIndex : Integer);
    begin
        Inc(mIterarionStatistics[sourceIndex].numReceivedFromSource);
    end;

    procedure FunctionalModule.increeseTimeInBuffer(sourceIndex : Integer; time : Double);
    begin
        mIterarionStatistics[sourceIndex].timeInBuffer := mIterarionStatistics[sourceIndex].timeInBuffer + time;
    end;

    procedure FunctionalModule.increeseTimeInHandler(sourceIndex : Integer; time : Double);
    begin
        mIterarionStatistics[sourceIndex].timeInHandler := mIterarionStatistics[sourceIndex].timeInHandler + time;
    end;    

    procedure FunctionalModule.increeseAppsInBuffer(sourceIndex : Integer; num : Integer);
    begin
        mIterarionStatistics[sourceIndex].appsInBuffer := mIterarionStatistics[sourceIndex].appsInBuffer + num;
    end;    
end.
