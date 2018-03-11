{$N+}

{Handler unit}
Unit U_Hand;

Interface
    uses crt, U_Time;

    Type Handler = object
        public
            constructor init(intensity : Double; var timeBehaviour : PTimeBehaviour);
            destructor done;

            procedure generateFinishTime(acceptTime : Double);
            function getFinishTime : Double;

            procedure zeroData;
            procedure changeWorkStatus(status : Boolean);

            function canWork : Boolean;

        private
            mCanWork       : Boolean;        {Flag = true if Buffer empty}
            mFinishTime    : Double;         {The time of the last post of the application}
            mIntensity     : Double;         {Intensity of the source (lambda)}
            mTimeBehaviour : PTimeBehaviour; {Law of time generation}        
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
        mCanWork := false;
        mFinishTime := 0;
    end;

    function Handler.canWork: Boolean;
    begin
        canWork := mCanWork;
    end;

    procedure Handler.changeWorkStatus(status : Boolean);
    begin
        mCanWork := status;
    end;

    function Handler.getFinishTime: Double;
    begin
        getFinishTime := mFinishTime;
    end;

    procedure Handler.generateFinishTime(acceptTime : Double);
    begin
        mFinishTime := acceptTime + mTimeBehaviour^.countTime(mIntensity);
    end;
end.
