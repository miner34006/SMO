{$N+} {$R-}

uses Graph, U_Type, crt;

Type PSystemSettings = ^SystemSettings;

Type GraphicModule = object
    public
        procedure printPoint(x, y : Integer);
        procedure printSimulationCoords;
        procedure eraseSimulationCoords;
    private
        {mData : SomeType;}
end;

Type PGraphicModule = ^GraphicModule;

procedure GraphicModule.printSimulationCoords;
begin
    
end;

procedure GraphicModule.eraseSimulationCoords;
begin
    
end;


procedure GraphicModule.printPoint(x, y : Integer);
begin
    
end;

{******************************************************************}
{*********************__Command Defenition__***********************}

Type Command = object
    constructor init;
    destructor done;
    procedure execute; virtual;
end;

Type HelpCommand = object(Command)
    procedure execute; virtual;
end;

Type SimulationCommand = object(Command)
    public
        constructor init(graph : PGraphicModule; func : PFunctionalModule; settings : PSystemSettings);
        procedure execute; virtual;

    private
        mSettings : PSystemSettings;
        mGraph : PGraphicModule;
        mFunc : PFunctionalModule;
end;

Type PCommand = ^Command;
     PHelpCommand = ^HelpCommand;
     PSimulationCommand = ^SimulationCommand;

{******************************************************************}
{*******************__Command Implementation__*********************}

constructor Command.init; begin end;
destructor Command.done; begin end;
procedure Command.execute; begin end;

procedure HelpCommand.execute;
var key: Char;
    xTopLeft, yTopLeft, xBottomRight, yBottomRight, rowCount: Integer;
begin
    rowCount := 4;

    xTopLeft := 0;
    yTopLeft := 40;
    xBottomRight := 410;
    yBottomRight := yTopLeft + (rowCount * 20) + 45;

    setColor(White); 
    Rectangle(xTopLeft, yTopLeft, xBottomRight, yBottomRight);
    OutTextXY(xTopLeft + 10, yTopLeft + 15, 'Help Text Help Text Help Text Help Text Help Text');
    OutTextXY(xTopLeft + 10, yTopLeft + 35, 'Help Text Help Text Help Text Help Text Help Text');
    OutTextXY(xTopLeft + 10, yTopLeft + 55, 'Help Text Help Text Help Text Help Text Help Text');
    OutTextXY(xTopLeft + 10, yTopLeft + 75, 'Help Text Help Text Help Text Help Text Help Text');

    setColor(Black); 
    SetFillStyle(SolidFill, LightGreen);
    bar(xTopLeft + 10, yTopLeft + (rowCount * 20) + 15, 
        xTopLeft + textWidth('Close') + 20, yTopLeft + rowCount * 20 + 25 + TextHeight('Close'));
    OutTextXY(xTopLeft + 15, yTopLeft + rowCount * 20 + 20, 'Close');

    key := readkey;
    while (key <> #13) do begin
        key := readkey;
    end;
    clearDevice;
end;

constructor SimulationCommand.init(graph : PGraphicModule; func : PFunctionalModule; settings : PSystemSettings);
begin
    mSettings := settings;
    mGraph := graph;
    mFunc := func;
end;

procedure SimulationCommand.execute;
var intensity : double;
    iterationQ : Integer;
begin
    mGraph^.printSimulationCoords;
    
    iterationQ := 0;
    intensity := mSettings^.minIntensity;
    while intensity < mSettings^.maxIntensity + mSettings^.deltaIntensity do begin

        mFunc^.setIntensity(intensity);
        while (not mFunc^.allSourcesHaveGeneratedKmin) do begin
            mFunc^.doIteration;
            Inc(iterationQ);
            if (iterationQ = 20) then begin
                mGraph^.printPoint(x, y);
                mGraph^.printPoint(x, y);
                mGraph^.printPoint(x, y);
                iterationQ := 0;
            end;
        end;

        {Count iteration stats and add to mGraph^.mData}
        
        mFunc^.zeroData;
        mGraph^.eraseSimulationCoords;
        intensity := intensity + mSettings^.deltaIntensity;
    end;
end;

{******************************************************************}
{****************__Selection State Defenition__********************}

Type SelectionState = object
    constructor init;
    destructor done;
    procedure draw(x, y : Integer; menuLabel : String); virtual;
    procedure erase(x, y : Integer; menuLabel : String);
end;

Type ChangingMenuState = object(SelectionState)
    procedure draw(x, y : Integer; menuLabel : String); virtual;
end;

Type ActiveMenuState = object(SelectionState)
    procedure draw(x, y : Integer; menuLabel : String); virtual;
end;

Type DeactiveMenuState = object(SelectionState)
    procedure draw(x, y : Integer; menuLabel : String); virtual;
end;

Type PSelectionState = ^SelectionState;
     PChangingMenuState = ^ChangingMenuState;
     PActiveMenuState = ^ActiveMenuState;
     PDeactiveMenuState = ^DeactiveMenuState;

{*********************************************************************}
{**************__Selection State Implementation__*********************}

constructor SelectionState.init; begin end;
destructor SelectionState.done; begin end;

procedure SelectionState.draw(x, y : Integer; menuLabel : String); begin end;

procedure SelectionState.erase(x, y : Integer; menuLabel : String);
begin
    SetFillStyle(SolidFill, Black);
    bar(x, y, x + textWidth(menuLabel) + 10, y + TextHeight(menuLabel) + 10);
end;

procedure ActiveMenuState.draw(x, y : Integer; menuLabel : String);
begin
    SetFillStyle(SolidFill, LightGreen);
    bar(x, y, x + textWidth(menuLabel) + 10, y + TextHeight(menuLabel) + 10);
    setColor(Black);
    OutTextXY(x + 5, y + 5, menuLabel);
end;

procedure DeactiveMenuState.draw(x, y : Integer; menuLabel : String);
begin
    SetFillStyle(SolidFill, White);
    bar(x, y, x + textWidth(menuLabel) + 10, y + TextHeight(menuLabel) + 10);
    setColor(Black);
    OutTextXY(x + 5, y + 5, menuLabel);
end;

procedure ChangingMenuState.draw(x, y : Integer; menuLabel : String);
begin
    SetFillStyle(SolidFill, Red);
    bar(x, y, x + textWidth(menuLabel) + 10, y + TextHeight(menuLabel) + 10);
    setColor(White);
    OutTextXY(x + 5, y + 5, menuLabel);
end;

{*********************************************************************}
{************************__Menu Defenition__**************************}

Type Menu = object
    public
        constructor initXY(x, y : Integer; menuLabel : String; com : PCommand);
        constructor init(menuLabel : String; com : PCommand);
        destructor done;

        procedure execute; virtual;
        procedure draw; virtual;
        procedure erase;

        function getX: Integer;
        function getY: Integer;
        function getmenuLabel: String;

        procedure setX(x : Integer);
        procedure setY(y : Integer);
        procedure setmenuLabel(menuLabel : String);
        procedure setState(state : PSelectionState);
        procedure setCommand(com : PCommand);

    private
        mSelectionState : PSelectionState;
        mCommand : PCommand;
        mMenuLabel : String;
        mX : Integer;
        mY : Integer;
end;

Type PMenu = ^Menu;
     Menus = array[0..10] of PMenu;

Type SettingsCommand = object(Command)
    public
        constructor init(param : PDouble; men : PMenu; menuLabel : String);
        procedure execute; virtual;
        procedure printStep(color: Word; step: Double);
    private
        mMenuLabel : String;
        mParam : PDouble;
        mMenu : PMenu;
end;


Type PSettingsCommand = ^SettingsCommand;

constructor SettingsCommand.init(param : PDouble; men : PMenu; menuLabel : String);
begin
    mMenuLabel := menuLabel;
    mParam := param;
    mMenu := men;
end;

procedure SettingsCommand.printStep(color: Word; step: Double);
var s : String;
begin
    setColor(color);
    str(step:1:1, s);
    OutTextXY(400, 5, 'Inc step = ' + s);
end;

procedure SettingsCommand.execute;
var s : String;
    key: Char;
    step : Double;
begin
    mMenu^.setState(new(PChangingMenuState, init));
    mMenu^.erase;
    mMenu^.draw;

    step := 0.1;
    printStep(White, step);

    key := readkey;
    while key <> #8 do begin
        if (key = #77) then begin
            mParam^ := mParam^ + step;
        end else 
        if (key = #75) then begin
            mParam^ := mParam^ - step;
        end else 
        if (key = #72) then begin
            printStep(Black, step);
            step := step * 10;
        end else 
        if (key = #80) then begin
            printStep(Black, step);
            step := step / 10;
        end;

        mMenu^.erase;
        str(mParam^:1:1, s);
        mMenu^.setmenuLabel(mMenuLabel + s);
        mMenu^.draw;

        printStep(White, step);

        key := readkey;
    end;

    printStep(Black, step);

    mMenu^.setState(new(PActiveMenuState, init));
    mMenu^.erase;
    mMenu^.draw;
end;

{*********************************************************************}
{***********************__Menu Implementation__***********************}

constructor Menu.initXY(x, y : Integer; menuLabel : String; com : PCommand);
begin
    mSelectionState := new(PDeactiveMenuState, init);
    mCommand := com;
    mMenuLabel := menuLabel;
    mX := x;
    mY := y;
end;

constructor Menu.init(menuLabel : String; com : PCommand);
begin
    Menu.initXY(0, 0, menuLabel, com);
end;

destructor Menu.done;
begin
    dispose(mSelectionState, done);
    if (mCommand <> nil) then begin
        dispose(mCommand, done);
    end;
end;

procedure Menu.execute;
begin
    mCommand^.execute;
end;

procedure Menu.draw;
begin
    mSelectionState^.draw(mx, my, mMenuLabel);
end;

procedure Menu.erase;
begin
    mSelectionState^.erase(mx, my, mMenuLabel);
end;

function Menu.getX: Integer;
begin
    getX := mX;
end;

function Menu.getY: Integer;
begin
    getY := mY;
end;

function Menu.getmenuLabel: String;
begin
    getmenuLabel := mMenuLabel;
end;

procedure Menu.setX(x : Integer);
begin
    mX := x;
end;

procedure Menu.setY(y : Integer);
begin
    mY := y;
end;

procedure Menu.setmenuLabel(menuLabel : String);
begin
    mMenuLabel := menuLabel;        
end;

procedure Menu.setState(state : PSelectionState);
begin
    dispose(mSelectionState, done);
    mSelectionState := state;
end;

procedure Menu.setCommand(com : PCommand);
begin
    if (mCommand <> nil) then begin
        dispose(mCommand, done);
    end;
    mCommand := com;
end;

{*********************************************************************}
{*********************__CompositeMenu Defenition__********************}

Type CompositeMenu = object(Menu)
    public
        constructor initXY(x, y : Integer; menuLabel : String);
        constructor init(menuLabel : String);
        destructor done;

        procedure execute; virtual;
        procedure prepareForExit;


        function isNext(key : Char): Boolean; virtual;
        function isPrevious(key : Char): Boolean; virtual;

        procedure selectNext;
        procedure selectPrevious;

        procedure add(item : PMenu); virtual;
        procedure remove(item : PMenu);

    private
        mChildren : Menus;
        mArrayIndex : Integer;
        mActiveMenu : Integer;
end;

Type VerticalCompositeMenu = object(CompositeMenu)
    procedure add(item : PMenu); virtual;
    function isNext(key : Char): Boolean; virtual;
    function isPrevious(key : Char): Boolean; virtual;
end;

Type HorizontalCompositeMenu = object(CompositeMenu)
    procedure add(item : PMenu); virtual;
end;

Type PCompositeMenu = ^CompositeMenu;
     PVerticalCompositeMenu = ^VerticalCompositeMenu;
     PHorizontalCompositeMenu = ^HorizontalCompositeMenu;

{*********************************************************************}
{*******************__CompositeMenu Implementation__******************}

constructor CompositeMenu.initXY(x, y : Integer; menuLabel : String);
begin
    Menu.initXY(x, y, menuLabel, nil);
    mArrayIndex := -1;
    mActiveMenu := 0;
end;

constructor CompositeMenu.init(menuLabel : String);
begin
    CompositeMenu.initXY(0, 0, menuLabel);
end;

destructor CompositeMenu.done;
var i : Integer;
begin
    for i := 0 to mArrayIndex do begin
        dispose(mChildren[i], done);
    end;
end;

procedure CompositeMenu.selectNext;
begin
    if (mActiveMenu >= mArrayIndex) then begin
        exit;
    end;
    mChildren[mActiveMenu]^.setState(new(PDeactiveMenuState, init));
    Inc(mActiveMenu);
    mChildren[mActiveMenu]^.setState(new(PActiveMenuState, init));
end;

procedure CompositeMenu.selectPrevious;
begin
    if (mActiveMenu <= 0) then begin
        exit;
    end;
    mChildren[mActiveMenu]^.setState(new(PDeactiveMenuState, init));
    Dec(mActiveMenu);
    mChildren[mActiveMenu]^.setState(new(PActiveMenuState, init));
end;

function CompositeMenu.isNext(key : Char): Boolean;
begin
    isNext := (key = #77);
end;

function CompositeMenu.isPrevious(key : Char): Boolean;
begin
    isPrevious := (key = #75);
end;

procedure CompositeMenu.execute;
var key : char;
    i : Integer;
begin
    mActiveMenu := 0;
    mChildren[mActiveMenu]^.setState(new(PActiveMenuState, init));
    while true do begin
        for i := 0 to mArrayIndex do begin
            mChildren[i]^.draw;
        end;
        
        key := readkey;
        
        if (key = #13) then begin
            mChildren[mActiveMenu]^.execute;
        end else
        if (isNext(key)) then begin
            selectNext;
        end else 
        if (isPrevious(key)) then begin
            selectPrevious;
        end else 
        if (key = #8) then begin
            prepareForExit;
            break;
        end;
    end;
end;

procedure CompositeMenu.prepareForExit;
begin
    clearDevice;
    mChildren[mActiveMenu]^.setState(new(PDeactiveMenuState, init));
end;

procedure CompositeMenu.add(item : PMenu);
begin
    Inc(mArrayIndex);
    mChildren[mArrayIndex] := item;
end;

procedure CompositeMenu.remove(item : PMenu);
var i, j: Integer;
begin
    for i := 0 to mArrayIndex do begin
        if (mChildren[i] = item) then begin
            for j := i to 9 do begin
                mChildren[j] := mChildren[j + 1];
            end;
            mChildren[10] := nil;
            break;
        end;
    end;

    setX(getX - 30);

    Dec(mArrayIndex);
end;

procedure VerticalCompositeMenu.add(item : PMenu);
var i, deltaHeight: Integer;
begin
    deltaHeight := mY;
    for i := 0 to mArrayIndex do begin
        deltaHeight := deltaHeight + TextHeight(mChildren[i]^.getmenuLabel) + 15;
    end;

    Inc(mArrayIndex);

    item^.setX(mX);
    item^.setY(TextHeight(mMenuLabel) + 15 + deltaHeight);

    mChildren[mArrayIndex] := item;
end;

function VerticalCompositeMenu.isNext(key : Char): Boolean;
begin
    isNext := (key = #80);
end;

function VerticalCompositeMenu.isPrevious(key : Char): Boolean;
begin
    isPrevious := (key = #72);
end;

procedure HorizontalCompositeMenu.add(item : PMenu);
var i, deltaWidth: Integer;
begin
    deltaWidth := mX;
    for i := 0 to mArrayIndex do begin
        deltaWidth := deltaWidth + textWidth(mChildren[i]^.getmenuLabel) + 15;
    end;

    Inc(mArrayIndex);

    item^.setX(textWidth(mMenuLabel) + 15 + deltaWidth);
    item^.setY(mY);

    mChildren[mArrayIndex] := item;
end;

{*********************************************************************}
{*******************__InterfaceModule Defenition__********************}

Type InterfaceModule = object
    public
        constructor init;
        destructor done;

        procedure run;
        procedure setMenu(men : PMenu);

    private
        mSettings : SystemSettings;
        mMenu : PCompositeMenu;
end;

Type PInterfaceModule = ^InterfaceModule;

{*********************************************************************}
{***************__InterfaceModule Implementation__********************}

constructor InterfaceModule.init; begin end;

destructor InterfaceModule.done;
begin
    dispose(mMenu, done);
end;

procedure InterfaceModule.setMenu(men : PMenu);
begin
    mMenu := men;
end;

procedure InterfaceModule.run;
begin
    mMenu^.execute;
end;
{*********************************************************************}

Type SMO = object
        constructor init(settings : SystemSettings);
        destructor done;
    private
        mSettings : SystemSettings;
        mGraphicModule : PGraphicModule;
        mInterfaceModule : PInterfaceModule;
        mFunctionalModule : PFunctionalModule;
end;

constructor SMO.init(settings : SystemSettings);
var mainMenu, settingsMenu, resultsMenu, simulationMenu: PCompositeMenu;
    simpleMenu : PMenu;
    com : PCommand;
    s : String;
begin
    mGraphicModule := new(PGraphicModule, init);
    mInterfaceModule := new(PInterfaceModule, init);
    mFunctionalModule := new(PFunctionalModule, init);
    mSettings := settings;

    mainMenu := new(PHorizontalCompositeMenu, initXY(-15, 0, ''));

    mainMenu^.add(new(PMenu, init('Help',  new(PHelpCommand, init))));

    settingsMenu := new(PVerticalCompositeMenu, init('Settings'));
    mainMenu^.add(settingsMenu);
    str(mSettings.KMIN:1:1, s);
    simpleMenu := new(PMenu, init('Kmin ' + s, nil));
    com := new(PSettingsCommand, init(Addr(mSettings.KMIN), simpleMenu, 'Kmin '));
    simpleMenu^.setCommand(com);
    settingsMenu^.add(simpleMenu);

    str(mSettings.minIntensity:1:1, s);
    simpleMenu := new(PMenu, init('MinL ' + s, nil));
    com := new(PSettingsCommand, init(Addr(mSettings.minIntensity), simpleMenu, 'MinL '));
    simpleMenu^.setCommand(com);
    settingsMenu^.add(simpleMenu);

    str(mSettings.maxIntensity:1:1, s);
    simpleMenu := new(PMenu, init('MaxL ' + s, nil));
    com := new(PSettingsCommand, init(Addr(mSettings.maxIntensity), simpleMenu, 'MaxL '));
    simpleMenu^.setCommand(com);
    settingsMenu^.add(simpleMenu);

    str(mSettings.deltaIntensity:1:1, s);
    simpleMenu := new(PMenu, init('Delt ' + s, nil));
    com := new(PSettingsCommand, init(Addr(mSettings.deltaIntensity), simpleMenu, 'Delt '));
    simpleMenu^.setCommand(com);
    settingsMenu^.add(simpleMenu);

    {
    resultsMenu := new(PVerticalCompositeMenu, init('Results'));
    mainMenu^.add(resultsMenu);
    resultsMenu^.add(new(PMenu, init('Table', new(PCommand, init))));
    resultsMenu^.add(new(PMenu, init('Graph', new(PCommand, init))));
    }

    simulationMenu := new(PVerticalCompositeMenu, init('Simulation'));
    com := new(PSimulationCommand, init(mGraphicModule, mFunctionalModule, Addr(mSettings)));
    mainMenu^.add(new(PMenu, init('Simulation', com)));

    mInterfaceModule^.setMenu(mainMenu);
    mInterfaceModule^.execute;
end;

destructor SMO.done;
begin
    dispose(mGraphicModule);
    dispose(mFunctionalModule);
    dispose(mInterfaceModule);
end;

var gd, gm : Integer;
    smo_ : SMO;
    settings : SystemSettings;
begin
    randomize;
    InitGraph(gd, gm, '');
    settextstyle (2,0,5);

    settings.KMIN := 10000;
    settings.minIntensity := 0.5;
    settings.maxIntensity := 1.5;
    settings.deltaIntensity := 0.1;

    smo_.init(settings);
    smo_.run;
    smo_.done;

    CloseGraph;
end.
