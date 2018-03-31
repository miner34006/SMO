{$N+}

Unit F_Sour;

Interface
    uses crt, Types, F_Time;

    Type Source = object
        public
            constructor init(intensity : Double; var timeBehaviour : PTimeBehaviour);
            destructor done;
            
            function getPostTime : Double;

            procedure setIntensity(intensity : Double);

            procedure zeroData;
            procedure postApplication;

        private
            mPostTime      : Double;
            mIntensity     : Double;
            mTimeBehaviour : PTimeBehaviour;
    end;

    Type PSource = ^Source;
    Type SourceArray = array[0..NUMBER_OF_SOURCES - 1] of PSource;


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

    procedure Source.zeroData;
    begin
        mPostTime := 0;
    end;

    procedure Source.setIntensity(intensity : Double);
    begin
        mIntensity := intensity;
    end;

    procedure Source.postApplication;
    begin
        mPostTime := mPostTime + mTimeBehaviour^.countTime(mIntensity);
    end;
end.
