{$N+} {$R-}

{SelectionStrategy unit}
Unit F_Sele;

Interface
    uses crt, F_Appl, Types;

    Type SelectionStrategy = object
        public
            constructor init;
            destructor done;

            function removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication; virtual;
    end;

    Type PrioritySelection = object(SelectionStrategy)
        public
            constructor init;
            destructor done;

            function removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication; virtual;
    end;

    Type NonPrioritySelection = object(SelectionStrategy)
        public
            constructor init;
            destructor done;

            function removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication; virtual;
    end;

    Type PSelectionStrategy = ^SelectionStrategy;
         PPrioritySelection = ^PrioritySelection;
         PNonPrioritySelection = ^NonPrioritySelection;


Implementation
    constructor SelectionStrategy.init; begin end;

    destructor SelectionStrategy.done; begin end;

    function SelectionStrategy.removeApplication(var applications : ApplicationArray; freeSlots : Integer) : PApplication;
    begin
        removeApplication := nil;
    end;

    constructor PrioritySelection.init; begin end;

    destructor PrioritySelection.done; begin end;

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

    constructor NonPrioritySelection.init; begin end;

    destructor NonPrioritySelection.done; begin end;

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
