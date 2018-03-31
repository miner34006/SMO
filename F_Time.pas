{$N+}

Unit F_Time;

Interface
    uses crt;

    Type TimeBehaviour = object
        constructor init;
        function countTime(intensity : Double) : Double; virtual;
    end;

    Type Regular = object(TimeBehaviour)
        public
            constructor init(tay : Double);
            function countTime(intensity : Double) : Double; virtual;

        private
            mTay : Double; 
    end;

    Type Uniform = object(TimeBehaviour)
        public
            constructor init(tay1, tay2 : Double);
            function countTime(intensity : Double) : Double; virtual;

        private
            mTay1 : Double; 
            mTay2 : Double; 
    end;

    Type Simple = object(TimeBehaviour)
        function countTime(intensity : Double) : Double; virtual;
    end;

    Type Erlang = object(TimeBehaviour)
        public
            constructor init(order : Integer);
            function countTime(intensity : Double) : Double; virtual;

        private
            mOrder : Integer;
    end;

    Type PTimeBehaviour = ^TimeBehaviour;
         PRegular       = ^Regular;
         PUniform       = ^Uniform;
         PSimple        = ^Simple;
         PErlang        = ^Erlang;
         

Implementation
    constructor TimeBehaviour.init; begin end;

    function TimeBehaviour.countTime(intensity : Double) : Double;
    begin
        countTime := 0.0;
    end;

    
    constructor Regular.init(tay : Double);
    begin
        mTay := tay;
    end;

    function Regular.countTime(intensity : Double) : Double;
    begin
        countTime := mTay;
    end;


    constructor Uniform.init(tay1, tay2 : Double);
    begin
        mTay1 := tay1;
        mTay2 := tay2;
    end;

    function Uniform.countTime(intensity : Double) : Double;
    var timeDelta : Double;
    begin
        timeDelta := mTay1 + (mTay2 - mTay1) * random;
        countTime := timeDelta;
    end;


    function Simple.countTime(intensity : Double) : Double;
    var timeDelta, rand: Double;
    begin
        timeDelta :=  -1.0 / intensity * ln(random);
        countTime := timeDelta;
    end;


    constructor Erlang.init(order : Integer);
    begin
        mOrder := order;
    end;

    function Erlang.countTime(intensity : Double) : Double;
    var timeDelta, rand : Double;
        i : Integer;
    begin
        rand := random;
        for i := 0 to mOrder - 2 do begin
            rand := rand * random;
        end;

        timeDelta := -1 / intensity * ln(rand);
        countTime := timeDelta;
    end;
end.
