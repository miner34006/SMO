{$N+} {$R-}

Unit I_Inter;

Interface
    uses Graph, crt, Types, F_Func, G_Graph, Utils;

    {******************************************************************}
    {*********************__Command Defenition__***********************}

    {Класс комманды (см. паттерн команда)}
    Type Command = object
        constructor init;
        destructor done;
        {Метод запуска команды}
        procedure execute; virtual;
    end;

    {Команда для кнопки "помощь"}
    Type HelpCommand = object(Command)
        procedure execute; virtual;
    end;

    {команда для кнопки "симуляция"}
    Type SimulationCommand = object(Command)
        public
            constructor init(graph : PGraphicModule; func : PFunctionalModule; settings : PSystemSettings);
            procedure execute; virtual;

        private
            {Настройки системы}
            mSettings : PSystemSettings;
            {Графический модуль}
            mGraph : PGraphicModule;
            {Функциональный модуль}
            mFunc : PFunctionalModule;
    end;

    {Команда для отображения результатов в виде таблицы}
    Type TableResultsCommand = object(Command)
        public
            constructor init(graph : PGraphicModule);
            procedure execute; virtual;

        private
            {Графический модуль}
            mGraph : PGraphicModule;
    end;

    {Команда для отображения результатов в виде графиков}
    Type GraphResultCommand = object(Command)
        public
            constructor init(graph : PGraphicModule);
            procedure execute; virtual;

        private
            {Графический модуль}
            mGraph : PGraphicModule;
    end;

    Type PCommand = ^Command;
         PHelpCommand = ^HelpCommand;
         PSimulationCommand = ^SimulationCommand;
         PTableResultsCommand = ^TableResultsCommand;
         PGraphResultCommand = ^GraphResultCommand;

    {******************************************************************}
    {****************__Selection State Defenition__********************}

    {Класс состояния меню (см. паттерн состояние)}
    Type SelectionState = object
        constructor init;
        destructor done;
        {Отобразить меню}
        procedure draw(x, y : Integer; menuLabel : String); virtual;
        {Стереть меню}
        procedure erase(x, y : Integer; menuLabel : String);
    end;

    {Сотояние для изменяющегося меню}
    Type ChangingMenuState = object(SelectionState)
        procedure draw(x, y : Integer; menuLabel : String); virtual;
    end;

    {Состояние для активного меню}
    Type ActiveMenuState = object(SelectionState)
        procedure draw(x, y : Integer; menuLabel : String); virtual;
    end;

    {Состояние для неактивного меню}
    Type DeactiveMenuState = object(SelectionState)
        procedure draw(x, y : Integer; menuLabel : String); virtual;
    end;

    Type PSelectionState = ^SelectionState;
         PChangingMenuState = ^ChangingMenuState;
         PActiveMenuState = ^ActiveMenuState;
         PDeactiveMenuState = ^DeactiveMenuState;

    {*********************************************************************}
    {************************__Menu Defenition__**************************}

    {Класс Меню (см. паттерн Компоновщик)}
    Type Menu = object
        public
            constructor initXY(x, y : Integer; menuLabel : String; com : PCommand);
            constructor init(menuLabel : String; com : PCommand);
            destructor done;

            {Выполнить действие, предназначенное кнопке}
            procedure execute; virtual;
            {Нарисовать кнопку}
            procedure draw; virtual;
            {Стереть кнопку}
            procedure erase;

            {Получить x координату кнопки}
            function getX: Integer;
            {Получить y координату кнопки}
            function getY: Integer;
            {Получить label кнопки}
            function getmenuLabel: String;

            {Установить x координату кнопки}
            procedure setX(x : Integer);
            {Установить y координату кнопки}
            procedure setY(y : Integer);
            {Установить label кнопки}
            procedure setmenuLabel(menuLabel : String);
            {Изменить состояние кнопки}
            procedure setState(state : PSelectionState);
            {Изменить действие кнопки}
            procedure setCommand(com : PCommand);

        private
            {Состояние для отображения меню}
            mSelectionState : PSelectionState;
            {Действие выполняемое кнопкой}
            mCommand : PCommand;
            {Label кнопки}
            mMenuLabel : String;
            {X координата кнопки}
            mX : Integer;
            {Y координата кнопки}
            mY : Integer;
    end;

    Type PMenu = ^Menu;
         Menus = array[0..10] of PMenu;


    {Команда для кнопки "настройки"}
    Type SettingsCommand = object(Command)
    public
        constructor init(param : PDouble; men : PMenu; menuLabel : String);
        procedure execute; virtual;
        {Отобразить шаг}
        procedure printStep(color: Word; step: Double);
    private
        {Label меню}
        mMenuLabel : String;
        {Параметр для изменения}
        mParam : PDouble;
        {Меню отображающее параметр для изменения}
        mMenu : PMenu;
    end;

    Type PSettingsCommand = ^SettingsCommand;

    {*********************************************************************}
    {*********************__CompositeMenu Defenition__********************}

    {Составное меню (Composite)}
    Type CompositeMenu = object(Menu)
        public
            constructor initXY(x, y : Integer; menuLabel : String);
            constructor init(menuLabel : String);
            destructor done;

            {Отобразить всех свои подменю}
            procedure execute; virtual;
            {Подготовка к выходы из меню}
            procedure prepareForExit;

            {Отвечает на вопрос
            "Клавиша предназначена для перехода на следующее подменю?"}
            function isNext(key : Char): Boolean; virtual;
            {Отвечает на вопрос
            "Клавиша предназначена для перехода на предыдущее подменю?"}
            function isPrevious(key : Char): Boolean; virtual;

            {Выбрать следующее подменю}
            procedure selectNext;
            {Выбрать предыдущее подменю}
            procedure selectPrevious;

            {Добавить подменю}
            procedure add(item : PMenu); virtual;
            {Удалить подменю}
            procedure remove(item : PMenu);

        private
            {Подменю}
            mChildren : Menus;
            {Индекс последнего подменю в mChildren}
            mArrayIndex : Integer;
            {Активное в данный момент подменю}
            mActiveMenu : Integer;
    end;
        
    {Вертикальное составное меню}
    Type VerticalCompositeMenu = object(CompositeMenu)
        procedure add(item : PMenu); virtual;
        function isNext(key : Char): Boolean; virtual;
        function isPrevious(key : Char): Boolean; virtual;
    end;

    {Горизонтальное составное меню}
    Type HorizontalCompositeMenu = object(CompositeMenu)
        procedure add(item : PMenu); virtual;
    end;

    Type PCompositeMenu = ^CompositeMenu;
         PVerticalCompositeMenu = ^VerticalCompositeMenu;
         PHorizontalCompositeMenu = ^HorizontalCompositeMenu;


    {*********************************************************************}
    {*******************__InterfaceModule Defenition__********************}

    {Модуль интерфейса}
    Type InterfaceModule = object
        public
            destructor done;

            {Запуск интерфейса}
            procedure run;
            {Установка главного меню}
            procedure setMenu(men : PMenu);

        private
            {Меню интерфейса}
            mMenu : PMenu;
    end;

    Type PInterfaceModule = ^InterfaceModule;


Implementation
    {******************************************************************}
    {*******************__Command Implementation__*********************}

    constructor Command.init; begin end;
    destructor Command.done; begin end;
    procedure Command.execute; begin end;

    procedure HelpCommand.execute;
    var key: Char;
        xTopLeft, yTopLeft : Integer;
    begin
        xTopLeft := 0;
        yTopLeft := 40;
        
        setColor(White);
        OutTextXY(xTopLeft + 10, yTopLeft + 15, 'Running the program you will see the main menu of the system.');
        OutTextXY(xTopLeft + 10, yTopLeft + 35, 'Controlled by arrows. To activate the menu, go to the appropriate');
        OutTextXY(xTopLeft + 10, yTopLeft + 55, 'menu and press Enter. To return to the higher level (from the');
        OutTextXY(xTopLeft + 10, yTopLeft + 75, 'submenu to the main menu, press the BackSpace key). For more information,');
        OutTextXY(xTopLeft + 10, yTopLeft + 95, 'refer to the Readme.doc file.');

        key := readkey;
        while (key <> #8) do begin
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
    var intensity, probabilityOfFailure, deltaIntensity : double;
        i : Integer;
        stats : IterarionStatistics;
        printStep : Integer;
        results : RResults;
        f : ResultFile;
    begin 
        if ((mSettings^.minIntensity <= 0) or 
            (mSettings^.maxIntensity <= 0) or 
            (mSettings^.minIntensity <= 0)) then 
        begin
            exit;
        end;

        Assign(f,'RESULTS.dat');
        Rewrite(f);

        intensity := mSettings^.minIntensity;
        deltaIntensity := (mSettings^.maxIntensity - mSettings^.minIntensity) / 10;

        printStep := round(mSettings^.KMIN / 1000);
        if printStep = 0 then begin
            printStep := 1;
        end;

        while intensity < mSettings^.maxIntensity + deltaIntensity do begin
            mGraph^.printSimulationCoords(mSettings^);
            mFunc^.setIntensity(intensity);

            while (not mFunc^.allSourcesHaveGeneratedKmin(mSettings^.Kmin)) do begin
                mFunc^.doIteration;
     
                if ((mFunc^.getAllNumberOfGeneratedApplications mod printStep) = 0) then begin
                    stats := mFunc^.getStatistics^;

                    probabilityOfFailure := countProbabilityOfFailure(0, stats);
                    mGraph^.printPoint((mFunc^.getNumberOfGeneratedApplications(0) div printStep), probabilityOfFailure, Blue);

                    probabilityOfFailure := countProbabilityOfFailure(1, stats);
                    mGraph^.printPoint((mFunc^.getNumberOfGeneratedApplications(1) div printStep), probabilityOfFailure, Red);
                end;
            end;

            stats := mFunc^.getStatistics^;
            results.intensity := intensity;
            for i := 0 to NUMBER_OF_SOURCES - 1 do begin
                results.probabilityOfFailure[i] := countProbabilityOfFailure(i, stats);
                results.averageWaitingTime[i] := countAverageWaitingTime(i, stats);
                results.averageAppsInBuffer[i] := countAverageAppsInBuffer(i, stats);
            end;
            write(f, results);
            
            mFunc^.zeroData;
            {TODO : реализовать отчистку у класса графика}
            mGraph^.erase;
            intensity := intensity + deltaIntensity;
        end;

        close(f);
    end;

    constructor TableResultsCommand.init(graph : PGraphicModule);
    begin
        mGraph := graph;
    end;

    procedure TableResultsCommand.execute;
        var f : ResultFile;
        rows, columns : Integer;
    begin
        {TODO : реализовать отчистку по выходу из метода
                + отчистка у класса Table }
        mGraph^.erase;
        rows := 12;
        columns := 7;

        Assign(f,'RESULTS.dat');
        mGraph^.printTable(f, rows, columns);
    end;

    constructor GraphResultCommand.init(graph : PGraphicModule);
    begin
        mGraph := graph;
    end;

    procedure GraphResultCommand.execute;
        var f : ResultFile;
        rows, columns : Integer;
    begin
        {TODO : реализовать отчистку по выходу из метода
                + отчистка у классов FunctionGraph}
        mGraph^.erase;
        Assign(f,'RESULTS.dat');
        mGraph^.printResultsCoords(f);
    end;

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
    {***************__InterfaceModule Implementation__********************}

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
end.
