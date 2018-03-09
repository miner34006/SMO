{$N+}

{Appliance unit}
Unit APU;

Interface
    uses crt, TBU;

    Type Appliance = object
        public
            constructor init(intensity : Double; var timeBehaviour : PTimeBehaviour);
            destructor done;
            procedure zeroData;
            function getFinishTime : Double;
            function canWork : Boolean;
            procedure changeWorkStatus(status : Boolean);
            procedure generateFinishTime(acceptTime : Double);

        private
            mCanWork : Boolean; {Flag = true if Buffer empty}
            mFinishTime : Double; {The time of the last post of the application}
            mIntensity : Double; {Intensity of the source (lambda)}
            mTimeBehaviour : PTimeBehaviour; {Law of time generation}        
    end;

    Type PAppliance = ^Appliance;


Implementation
    constructor Appliance.init(intensity : Double; var timeBehaviour : PTimeBehaviour);
    begin
        mCanWork := false;
        mFinishTime := 0;
        mIntensity := intensity; 
        mTimeBehaviour := timeBehaviour;
    end;

    destructor Appliance.done;
    begin
        dispose(mTimeBehaviour);
    end;

    procedure Appliance.zeroData;
    begin
        mFinishTime := 0;
    end;

    function Appliance.canWork: Boolean;
    begin
        canWork := mCanWork;
    end;

    procedure Appliance.changeWorkStatus(status : Boolean);
    begin
        mCanWork := status;
    end;

    function Appliance.getFinishTime: Double;
    begin
        getFinishTime := mFinishTime;
    end;

    procedure Appliance.generateFinishTime(acceptTime : Double);
    begin
        mFinishTime := acceptTime + mTimeBehaviour^.countTime(mIntensity);
    end;
end.
