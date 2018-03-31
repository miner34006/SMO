{$N+} {$R-}

Unit F_Buff;

Interface
    uses crt, Types;

    {******************************************************************}
    {**********************_Application def_***************************}

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

    {******************************************************************}
    {*******************_SelectionStrategy def_************************}

    Type SelectionStrategy = object
        constructor init;
        destructor done;

        function removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication; virtual;
    end;

    Type PrioritySelection = object(SelectionStrategy)
        function removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication; virtual;
    end;

    Type NonPrioritySelection = object(SelectionStrategy)
        function removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication; virtual;
    end;

    Type PSelectionStrategy = ^SelectionStrategy;
         PPrioritySelection = ^PrioritySelection;
         PNonPrioritySelection = ^NonPrioritySelection;

    {******************************************************************}
    {************************_Buffer def_******************************}

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
            mMaxSize           : Integer;          
            mFreeSlots         : Integer;         
            mApplications      : ApplicationArray; 
    end;

    Type PBuffer = ^Buffer;

Implementation

    {******************************************************************}
    {*******************_Application impl_*****************************}

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

    constructor Buffer.init(selectionStrategy : PSelectionStrategy);
    begin
        mSelectionStrategy := selectionStrategy;
        mMaxSize := BUFFER_SIZE;
        mFreeSlots := BUFFER_SIZE;
    end;

    {******************************************************************}
    {************************_Buffer impl_*****************************}

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

    {******************************************************************}
    {********************_SelectionStrategy impl_**********************}

    constructor SelectionStrategy.init; begin end;

    destructor SelectionStrategy.done; begin end;

    function SelectionStrategy.removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication;
    begin
        removeApplication := nil;
    end;

    function PrioritySelection.removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication;
    var i, maxPriority, appIndex: Integer;
    begin
        maxPriority := -1;
        appIndex := -1;

        for i := 0 to BUFFER_SIZE - 1 - freeSlots do begin
            if (applications[i]^.getSourceNumber > maxPriority) then begin 
                maxPriority := applications[i]^.getSourceNumber;
                appIndex := i;
            end;
        end;
        removeApplication := applications[appIndex];
        for i := appIndex to BUFFER_SIZE - 2 do begin
            applications[i] := applications[i + 1];
        end;
        applications[BUFFER_SIZE - 1] := nil;
    end;

    function NonPrioritySelection.removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication;
    var i: Integer;
    begin
        removeApplication := applications[0];
        for i := 0 to BUFFER_SIZE - 2 do begin
            applications[i] := applications[i + 1];
        end;
        applications[BUFFER_SIZE - 1] := nil;
    end;
end.
