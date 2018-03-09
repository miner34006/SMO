{$N+}

{Application unit}
Unit U_Appl;

Interface
    uses crt;

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
         AArray = array [0..0] of PApplication;
         PAArray = ^AArray;


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
