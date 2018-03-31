{$N+} {$R-}

uses Graph, crt, Types, F_Func, G_Graph, I_Inter;

{Сестема массового обслуживания}
Type SMO = object
        constructor init(settings : SystemSettings);
        destructor done;
        {Запуск системы}
        procedure start;

    private
        {Настройки СМО}
        mSettings : SystemSettings;
        {Графический модуль}
        mGraphicModule : PGraphicModule;
        {Модуль интерфейса}
        mInterfaceModule : PInterfaceModule;
        {Функциональный модуль}
        mFunctionalModule : PFunctionalModule;
end;

constructor SMO.init(settings : SystemSettings);
var mainMenu, settingsMenu, resultsMenu, simulationMenu: PCompositeMenu;
    simpleMenu : PMenu;
    com : PCommand;
    s : String;
begin
    mGraphicModule := new(PGraphicModule);
    mInterfaceModule := new(PInterfaceModule);
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

    resultsMenu := new(PVerticalCompositeMenu, init('Results'));
    mainMenu^.add(resultsMenu);
    com := new(PTableResultsCommand, init(mGraphicModule));
    resultsMenu^.add(new(PMenu, init('Table', com)));
    com := new(PGraphResultCommand, init(mGraphicModule));
    resultsMenu^.add(new(PMenu, init('Graph', com)));

    simulationMenu := new(PVerticalCompositeMenu, init('Simulation'));
    com := new(PSimulationCommand, init(mGraphicModule, mFunctionalModule, Addr(mSettings)));
    mainMenu^.add(new(PMenu, init('Simulation', com)));

    mInterfaceModule^.setMenu(mainMenu);
end;

destructor SMO.done;
begin
    dispose(mGraphicModule);
    dispose(mFunctionalModule);
    dispose(mInterfaceModule);
end;

procedure SMO.start;
begin
    mInterfaceModule^.run;
end;

var gd, gm : Integer;
    smo_ : SMO;
    settings : SystemSettings;
begin
    randomize;
    InitGraph(gd, gm, '');
    settextstyle (SmallFont, HorizDir, 5);

    settings.KMIN := 10000;
    settings.minIntensity := 0.5;
    settings.maxIntensity := 1.5;

    smo_.init(settings);
    smo_.start;
    smo_.done;

    CloseGraph;
end.
