{$N+}

{Application unit}
Unit F_Appl;

Interface
    uses crt, Types;

    Type Application = object
        public
            constructor init(sourceNumber : Integer; timeOfCreation : Double);
            
            function getSourceNumber : Integer;
            function getTimeOfCreation : Double;

        private
            mSourceNumber : Integer;
            mTimeOfCreation : Double;
    end;

    Type PApplication = ^Application;
         ApplicationArray = array [0..BUFFER_SIZE - 1] of PApplication;


Implementation
    constructor Application.init(sourceNumber : Integer; timeOfCreation : Double);
    begin
        mSourceNumber := sourceNumber;
        mTimeOfCreation := timeOfCreation;
    end;

    function Application.getSourceNumber : Integer;
    begin
        getSourceNumber := mSourceNumber;
    end;

    function Application.getTimeOfCreation : Double;
    begin
        getTimeOfCreation := mTimeOfCreation;
    end;
end.
