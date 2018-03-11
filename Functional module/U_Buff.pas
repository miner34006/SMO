{$N+} {$R-}

{Buffer unit}
Unit U_Buff;

Interface
    uses crt, U_Appl, U_Type;

    Type Buffer = object
        public
            constructor init;
            destructor done;

            function addApplication(app : PApplication) : Boolean;
            function removeApplication : PApplication;

            function empty: Boolean;

            procedure zeroData;

        private
            mMaxSize      : Integer;          {Max buffer size}
            mFreeSlots    : Integer;          {Number of free (empty) slots}
            mApplications : ApplicationArray; {Array of PAplications}
    end;

    Type PBuffer = ^Buffer;


Implementation
    constructor Buffer.init;
    begin
        mMaxSize := BUFFER_SIZE;
        mFreeSlots := BUFFER_SIZE;
    end;

    destructor Buffer.done;
    var i : Integer;
    begin
        for i := 0 to mMaxSize - 1 do begin
            if (mApplications[i] <> nil) then begin
                dispose(mApplications[i]);
            end;
        end;
    end;

    procedure Buffer.zeroData;
    var i: Integer;
    begin
        mFreeSlots := mMaxSize;
        for i := 0 to mMaxSize - 1 do begin
            mApplications[i] := nil;
        end;
    end;

    function Buffer.addApplication(app : PApplication) : Boolean;
    begin
        if (mFreeSlots = 0) then begin
            addApplication := false;
            exit;
        end;

        mApplications[mMaxSize - mFreeSlots] := app;
        mFreeSlots := mFreeSlots - 1;
        addApplication := true;
    end;

    function Buffer.empty: Boolean;
    begin
        empty := (mFreeSlots = mMaxSize);
    end;

    function Buffer.removeApplication : PApplication;
    var i: Integer;
    begin
        if (mFreeSlots <> mMaxSize) then begin
            removeApplication := mApplications[0];
            for i := 0 to mMaxSize - 2 do begin
                mApplications[i] := mApplications[i + 1];
            end;
            mApplications[mMaxSize - 1] := nil;
            mFreeSlots := mFreeSlots + 1;
        end else begin
            removeApplication := nil;
        end;
    end;
end.
