{$N+} {$R-}

{Buffer unit}
Unit U_Buff;

Interface
    uses crt, U_Appl;

    Type Buffer = object
        public
            constructor init(maxSize : Integer);
            destructor done;
            procedure zeroData;
            function addApplication(app : PApplication) : Boolean;
            function hasApplications: Boolean;
            function removeApplication : PApplication;

        private
            mMaxSize : Integer; {Max buffer size}
            mFreeSlots : Integer; {Number of free (empty) slots}
            mBuffer : PAArray; {Array of PAplications}
    end;

    Type PBuffer = ^Buffer;


Implementation
    constructor Buffer.init(maxSize : Integer);
    begin
        mMaxSize := maxSize;
        mFreeSlots := maxSize;

        GetMem(mBuffer, SizeOf(AArray) * mMaxSize);
    end;

    destructor Buffer.done;
    begin
        FreeMem(mBuffer, SizeOf(AArray) * mMaxSize);
    end;

    procedure Buffer.zeroData;
    var i: Integer;
    begin
        mFreeSlots := mMaxSize;
        for i := 0 to mMaxSize - 1 do begin
            mBuffer^[i] := nil;
        end;
    end;

    function Buffer.addApplication(app : PApplication) : Boolean;
    begin
        if (mFreeSlots = 0) then begin
            addApplication := false;
            exit;
        end;

        mBuffer^[mMaxSize - mFreeSlots] := app;
        mFreeSlots := mFreeSlots - 1;
        addApplication := true;
    end;

    function Buffer.hasApplications: Boolean;
    begin
        hasApplications := not (mFreeSlots = mMaxSize);
    end;

    function Buffer.removeApplication : PApplication;
    var i: Integer;
    begin
        if (mFreeSlots <> mMaxSize) then begin
            removeApplication := mBuffer^[0];
            for i := 0 to mMaxSize - 2 do begin
                mBuffer^[i] := mBuffer^[i + 1];
            end;
            mBuffer^[mMaxSize - 1] := nil;
            mFreeSlots := mFreeSlots + 1;
        end else begin
            removeApplication := nil;
        end;
    end;
end.
