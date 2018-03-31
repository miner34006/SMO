{$N+}

Unit F_Hand;

Interface
    uses crt, F_Time;

    Type Handler = object
        public
            constructor init(intensity : Double; var timeBehaviour : PTimeBehaviour);
            destructor done;

            function generateFinishTime(acceptTime : Double): Double;
            function getFinishTime : Double;

            procedure zeroData;

        private
            mFinishTime    : Double; 
            mIntensity     : Double;        
            mTimeBehaviour : PTimeBehaviour;
    end;

    Type PHandler = ^Handler;


Implementation
    constructor Handler.init(intensity : Double; var timeBehaviour : PTimeBehaviour);
    begin
        mIntensity := intensity; 
        mTimeBehaviour := timeBehaviour;
        zeroData;
    end;

    destructor Handler.done;
    begin
        dispose(mTimeBehaviour);
    end;

    procedure Handler.zeroData;
    begin
        mFinishTime := 0;
    end;

    function Handler.getFinishTime: Double;
    begin
        getFinishTime := mFinishTime;
    end;

    function Handler.generateFinishTime(acceptTime : Double): Double;
    var workingTime : Double;
    begin
        workingTime := mTimeBehaviour^.countTime(mIntensity);
        mFinishTime := acceptTime + workingTime;
        generateFinishTime := workingTime;
    end;
end.
