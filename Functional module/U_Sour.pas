{$N+}

{Source unit}
Unit U_Sour;

Interface
    uses crt, U_Time;

    Type Source = object
        public
            constructor init(intensity : Double; var timeBehaviour : PTimeBehaviour);
            destructor done;
            function getPostTime : Double;
            function getNumberOfReceivedApplications : Longint;
            function getNumberOfRejectedApplications : Longint;
            function getTotalNumberOfApplications : Longint;
            function getTimeInBuffer : Double;

            procedure setIntensity(intensity : Double);

            procedure zeroData;
            procedure increaseNumberOfReceivedApplications;
            procedure increaseNumberOfRejectedApplications;
            procedure increaseTotalNumberOfApplications;
            procedure increeseTimeInBuffer(time : Double);

            procedure postApplication;

        private
            mPostTime : Double; {The time of the last post of the application}
            mIntensity : Double; {Intensity of the source (lambda)}
            mNumberOfReceivedApplications : Longint; {Number of requests accepted by the Handler (KOBR)}
            mNumberOfRejectedApplications : Longint; {Number of applications rejected by the Handler (KOTK)}
            mTotalNumberOfApplications : Longint; {Total Nnumber of applications (KOL)}
            mTimeInBuffer : Double; {Time of applications in the buffer}
            mTimeBehaviour : PTimeBehaviour; {Law of time generation}
    end;

    Type PSource = ^Source;


Implementation
    constructor Source.init(intensity : Double; var timeBehaviour : PTimeBehaviour);
    begin
        mIntensity := intensity; 
        mTimeBehaviour := timeBehaviour;
        zeroData;
    end;

    destructor Source.done;
    begin
        dispose(mTimeBehaviour);
    end;

    function Source.getPostTime: Double;
    begin
        getPostTime := mPostTime;
    end;

    function Source.getNumberOfReceivedApplications : Longint;
    begin
        getNumberOfReceivedApplications := mNumberOfReceivedApplications;
    end;

    function Source.getNumberOfRejectedApplications : Longint;
    begin
        getNumberOfRejectedApplications := mNumberOfRejectedApplications;
    end;

    function Source.getTotalNumberOfApplications : Longint;
    begin
        getTotalNumberOfApplications := mTotalNumberOfApplications;
    end;

    function Source.getTimeInBuffer : Double;
    begin
        getTimeInBuffer := mTimeInBuffer;
    end;

    procedure Source.zeroData;
    begin
        mNumberOfReceivedApplications := 0;
        mNumberOfRejectedApplications := 0;
        mTotalNumberOfApplications := 0;
        mPostTime := 0;
        mTimeInBuffer := 0;
    end;

    procedure Source.setIntensity(intensity : Double);
    begin
        mIntensity := intensity;
    end;

    procedure Source.increaseNumberOfReceivedApplications;
    begin
        mNumberOfReceivedApplications := mNumberOfReceivedApplications + 1;
    end;

    procedure Source.increaseNumberOfRejectedApplications;
    begin
        mNumberOfRejectedApplications := mNumberOfRejectedApplications + 1;
    end;

    procedure Source.increaseTotalNumberOfApplications;
    begin
        mTotalNumberOfApplications := mTotalNumberOfApplications + 1;
    end;

    procedure Source.increeseTimeInBuffer(time : Double);
    begin
        mTimeInBuffer := mTimeInBuffer + time;
    end;

    procedure Source.postApplication;
    begin
        mPostTime := mPostTime + mTimeBehaviour^.countTime(mIntensity);
        increaseTotalNumberOfApplications;
    end;
end.
