{$N+} {$R-}

{Buffer unit}
Unit U_Buff;

Interface
    uses crt, U_Appl, U_Type, U_Sele;

    Type Buffer = object
        public
            constructor init(selectionStrategy : PSelectionStrategy);
            destructor done;

            function addApplication(app : PApplication) : Boolean;
            function removeApplication : PApplication;
            function getNumberOfApps(sourceIndex : Integer): Integer;

            function empty: Boolean;

            procedure zeroData;

        private
            mSelectionStrategy : PSelectionStrategy;
            mMaxSize           : Integer;          {Max buffer size}
            mFreeSlots         : Integer;          {Number of free (empty) slots}
            mApplications      : ApplicationArray; {Array of PAplications}
    end;

    Type PBuffer = ^Buffer;


Implementation
    constructor Buffer.init(selectionStrategy : PSelectionStrategy);
    begin
        mSelectionStrategy := selectionStrategy;
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
        dispose(mSelectionStrategy);
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

    function Buffer.getNumberOfApps(sourceIndex : Integer): Integer;
    var i, appsCount: Integer;
    begin
        appsCount := 0;
        for i := 0 to BUFFER_SIZE - 1 - mFreeSlots do begin
            if (mApplications[i]^.getSourceNumber = sourceIndex) then begin
                Inc(appsCount);
            end;
        end;
        getNumberOfApps := appsCount;
    end;

    function Buffer.empty: Boolean;
    begin
        empty := (mFreeSlots = mMaxSize);
    end;

    function Buffer.removeApplication : PApplication;
    begin
        removeApplication := mSelectionStrategy^.removeApplication(mApplications, mFreeSlots);
        mFreeSlots := mFreeSlots + 1;
    end;
end.
