{$N+}

Unit G_Graph;

Interface
    uses crt, Graph, Types;

    {Размер массива со статистикой моделирования (10 итераций)}
    const ARRAY_SIZE = 10;
    {Массив данных статистики}
    Type DataArray = array [0..ARRAY_SIZE] of Double;

    {структура функции}
    Type Rfunc = record
        {Имя функции}
        funcName : String;
        {Цвет функции на графике}
        color : Word;
        {Массив x координат функции}
        xCoords : DataArray;
        {Массив y координат функции}
        yCoords : DataArray;
    end;


    {Класс для отображения графиков функций}
    Type FunctionGraph = object
        public
            constructor init(xLabel, yLabel : String);
            destructor done;

            {Рисует графикс добавленными функциями}
            procedure draw(x, y : Word);
            {Добавить функцию на график}
            procedure addFunction(func : Rfunc);

        private
            {Имя оси x}
            mXLabel : String;
            {Имя оси y}
            mYLabel : String;

            {Коэффициент масштабирования для оси x}
            mXCof : Double;
            {Коэффициент масштабирования для оси y}
            mYCof : Double;

            {Шаг x для построения графика (max-min / кол-во делений)}
            mXAver : Double;
            {Шаг y для построения графика (max-min / кол-во делений)}
            mYAver : Double;

            {Минамальное значение x (для всех функций, добавленных в график)}
            mXMin : Double;
            {Минамальное значение y (для всех функций, добавленных в график)}
            mYMin : Double;

            mNumFunctions : Word;
            mFunctions : array [0..5] of Rfunc;

            {Построить систему координат}
            procedure drawCoordinateSystem(x, y : Word);
            {Построить оси координат}
            procedure drawCoordinateAxes(x, y : Word);
            {Разметить оси координат}
            procedure markCoordinateAxes(x, y : Word);
            {Подписать оси координат}
            procedure signCoordinateAxes(x, y : Word);
            {Отобразить функции в системе координат}
            procedure drawFunctions(x, y : Word);
    end;

    Type GraphicModule = object
        {TODO: Выделить в отдельный класс}
        {Рисует точку в системе координат для моделирования "online"}
        procedure printPoint(x : Longint; y : Double; color : Word);
        {TODO: Выделить в отдельный класс}
        {Рисует систему координат для моделирования "online"}
        procedure printSimulationCoords(settings : SystemSettings);
        
        {TODO: должен возвращать FunctionGraph}
        {Рисует системы координат с результатами моделирования}
        procedure printResultsCoords(var f : ResultFile);

        {TODO: рефакторинг этого метода}
        {Печатает таблицу с результатами моделирования}
        procedure printTable(var f : ResultFile; rows, columns: Integer);
        {Стирает все графики}
        procedure erase;
    end;

    Type PGraphicModule = ^GraphicModule;

Implementation
    constructor FunctionGraph.init(xLabel, yLabel : String);
    var i: Integer;
    begin
        mNumFunctions := 0;
        mXLabel := xLabel;
        mYLabel := yLabel;
    end;

    destructor FunctionGraph.done; begin end;

    procedure FunctionGraph.addFunction(func : Rfunc);
    var i, j : Integer;
        maxX, maxY, minX, minY : Double;
    begin
        mFunctions[mNumFunctions] := func;
        Inc(mNumFunctions);

        maxX := mFunctions[0].xCoords[0];
        maxY := mFunctions[0].yCoords[0];
        minX := mFunctions[0].xCoords[0];
        minY := mFunctions[0].yCoords[0];
        
        for i := 0 to mNumFunctions - 1 do begin
            for j := 0 to ARRAY_SIZE do begin
                if (mFunctions[i].xCoords[j] > maxX) then begin
                    maxX := mFunctions[i].xCoords[j];
                end;
                if (mFunctions[i].yCoords[j] > maxY) then begin
                    maxY := mFunctions[i].yCoords[j];
                end;
                if (mFunctions[i].xCoords[j] < minX) then begin
                    minX := mFunctions[i].xCoords[j];
                end;
                if (mFunctions[i].yCoords[j] < minY) then begin
                    minY := mFunctions[i].yCoords[j];
                end;
            end;
        end;

        mXCof := 180 / (maxX - minX);
        mYCof := 104 / (maxY - minY);

        mXAver := (maxX - minX) / 4;
        mYAver := (maxY - minY) / 4;

        mXMin := minX;
        mYMin := minY;
    end;

    procedure FunctionGraph.drawCoordinateAxes(x, y : Word);
    begin
        line(x, y, x, y - 130);
        line(x, y, x + 225, y);

        line(x - 3, y - 127, x, y - 130);
        line(x, y - 130, x + 3, y - 127);
        line(x + 222, y - 3, x + 225, y);
        line(x + 225, y, x + 222, y + 3);
    end;

    procedure FunctionGraph.markCoordinateAxes(x, y : Word);
    var i: Integer;
    begin
        for i := 1 to 4 do begin
            line(x + 45 * i, y - 3, x + 45 * i, y + 3);
            line(x - 3, y - 26 * i, x + 3, y - 26 * i);
        end;
    end;

    procedure FunctionGraph.signCoordinateAxes(x, y : Word);
    var i: Integer;
        s : String;
    begin
        outTextXY(x + 215, y + 10, mXLabel);
        outTextXY(x - TextWidth(mYLabel) - 10, y - 140,  mYLabel);

        for i := 0 to 4 do begin
            str((mXMin + mXAver * i):1:2, s);
            outTextXY(x + 45 * i - 10, y + 10, s);

            str((mYMin + mYAver * i):1:2, s);
            outTextXY(x - 40, y - 26 * i - 7, s);
        end;

        moveTo(x + 20, y - 130);
        for i := 0 to mNumFunctions - 1 do begin
            setColor(mFunctions[i].color);
            Circle(getX - 2, getY + 8, 2);
            MoveRel(5, 0);
            setColor(White);
            outText(mFunctions[i].funcName);
            MoveRel(10, 0);
        end;
    end;

    procedure FunctionGraph.drawCoordinateSystem(x, y : Word);
    begin
        drawCoordinateAxes(x, y);
        markCoordinateAxes(x, y);
        signCoordinateAxes(x, y);
    end;

    procedure FunctionGraph.drawFunctions(x, y : Word);
    var i, j, x0, y0, x1, y1 : Integer;
    begin
        for i := 0 to mNumFunctions - 1 do begin
            setColor(mFunctions[i].color);

            x0 := round(x + mXCof * (mFunctions[i].xCoords[0] - mXMin));
            y0 := round(y - mYCof * (mFunctions[i].yCoords[0] - mYMin));

            for j := 1 to ARRAY_SIZE do begin
                x1 := round(x + mXCof * (mFunctions[i].xCoords[j] - mXMin));
                y1 := round(y - mYCof * (mFunctions[i].yCoords[j] - mYMin));

                line(x0, y0, x1, y1);

                x0 := x1;
                y0 := y1;
            end;
        end;
    end;

    procedure FunctionGraph.draw(x, y : Word);
    begin
        setColor(White);
        drawCoordinateSystem(x, y);
        drawFunctions(x, y);
    end;

    procedure GraphicModule.printSimulationCoords(settings : SystemSettings);
    var xBottomLeft, yBottomLeft, xBottomRight, yBottomRight, xTopLeft, yTopLeft, i : Integer;
        s : String;
        d : Double;
    begin
        xBottomLeft := 50;
        yBottomLeft := 400;

        xBottomRight := xBottomLeft + 550;
        yBottomRight := yBottomLeft;

        xTopLeft := xBottomLeft;
        yTopLeft := yBottomLeft - 330;

        setColor(White);
        line(xBottomLeft, yBottomLeft, xTopLeft, yTopLeft);
        line(xBottomLeft, yBottomLeft, xBottomRight, yBottomRight);

        line(xTopLeft, yTopLeft, xTopLeft - 10, yTopLeft + 10);
        line(xTopLeft, yTopLeft, xTopLeft + 10, yTopLeft + 10);

        line(xBottomRight, yBottomRight, xBottomRight - 10, yBottomRight + 10);
        line(xBottomRight, yBottomRight, xBottomRight - 10, yBottomRight - 10);

        outTextXY(xBottomRight - 10, yBottomRight + 15, 'KMIN');
        outTextXY(xTopLeft - 50, yTopLeft, 'P_otk');

        d := settings.KMIN / 10;
        for i := 1 to 10 do begin
            line(xBottomLeft + i * 50, yBottomLeft - 5, xBottomLeft + i * 50, yBottomLeft + 5);
            str((d * i):1:0, s);
            outTextXY(xBottomLeft + i * 50 - 15, yBottomLeft + 15, s);

            line(xBottomLeft - 5, yBottomLeft - i * 30, xBottomLeft + 5, yBottomLeft - i * 30);
            str((i/10):1:1, s);
            outTextXY(xBottomLeft - 30, yBottomLeft - i * 30 - 8, s);
        end;
    end;

    procedure GraphicModule.erase;
    begin
        SetFillStyle(SolidFill, Black);
        bar(0, 50, getMaxX, getMaxY);
    end;


    procedure GraphicModule.printPoint(x : Longint; y : Double; color : Word);
    var xBottomLeft, yBottomLeft : Integer;
        px, py : Longint;
    begin
        xBottomLeft := 50;
        yBottomLeft := 400;

        px := round(xBottomLeft + x * 0.5);
        py := round(yBottomLeft - (y * 300));
        if (px > xBottomLeft + 500) then begin
            exit;
        end;

        putPixel(px, py, color);
    end;

    procedure GraphicModule.printTable(var f : ResultFile; rows, columns: Integer);
    var i, j, oneColumnWidth, OneRowHeight, firstColumnCenterX, columnCenterY: Integer;
        results : RResults;
        s : String;
    begin
        setColor(White);

        Rectangle(50, 100, getMaxX - 50, getMaxY - 50);
        oneColumnWidth := round((getMaxX - 100) / columns);
        oneRowHeight := round((getMaxY - 150) / rows);

        for i := 1 to columns - 1 do begin
            line(50 + i * oneColumnWidth, 100, 50 + i * oneColumnWidth, getMaxY - 50);
        end;
        for i := 1 to rows - 1 do begin
            line(50, 100 + i * oneRowHeight, getMaxX - 50, 100 + i * oneRowHeight);
        end;
        firstColumnCenterX := round(50 + oneColumnWidth / 2) - 20;
        columnCenterY := round(100 + oneRowHeight / 2) - 10;

        outTextXY(firstColumnCenterX + oneColumnWidth * 0, columnCenterY, 'LAM');
        outTextXY(firstColumnCenterX + oneColumnWidth * 1, columnCenterY, 'P_OTK1');
        outTextXY(firstColumnCenterX + oneColumnWidth * 2, columnCenterY, 'P_OTK2');
        outTextXY(firstColumnCenterX + oneColumnWidth * 3, columnCenterY, 'M_WAIT1');
        outTextXY(firstColumnCenterX + oneColumnWidth * 4, columnCenterY, 'M_WAIT2');
        outTextXY(firstColumnCenterX + oneColumnWidth * 5, columnCenterY, 'K_APPS1');
        outTextXY(firstColumnCenterX + oneColumnWidth * 6, columnCenterY, 'K_APPS2');

        {$I-}
        reset(f);
        {$I+}
        if IOresult <> 0 then begin
            exit;
        end;

        for i := 1 to rows - 1 do begin
            read(f, results);

            columnCenterY := columnCenterY + oneRowHeight;

            str(results.intensity:1:2, s);
            outTextXY(firstColumnCenterX + oneColumnWidth * 0, columnCenterY, s);
            str(results.probabilityOfFailure[0]:1:2, s);
            outTextXY(firstColumnCenterX + oneColumnWidth * 1, columnCenterY, s);
            str(results.probabilityOfFailure[1]:1:2, s);
            outTextXY(firstColumnCenterX + oneColumnWidth * 2, columnCenterY, s);
            str(results.averageWaitingTime[0]:1:2, s);
            outTextXY(firstColumnCenterX + oneColumnWidth * 3, columnCenterY, s);
            str(results.averageWaitingTime[1]:1:2, s);
            outTextXY(firstColumnCenterX + oneColumnWidth * 4, columnCenterY, s);
            str(results.averageAppsInBuffer[0]:1:2, s);
            outTextXY(firstColumnCenterX + oneColumnWidth * 5, columnCenterY, s);
            str(results.averageAppsInBuffer[1]:1:2, s);
            outTextXY(firstColumnCenterX + oneColumnWidth * 6, columnCenterY, s);
        end;

        close(f);
    end;

    procedure GraphicModule.printResultsCoords(var f : ResultFile);
    var i, j: Integer;
        graph1, graph2, graph3: FunctionGraph;
        results : RResults;
        funcArray : array [0..NUMBER_OF_SOURCES - 1] of Rfunc;
        s: String;
    begin
        {$I-}
        reset(f);
        {$I+}
        if IOresult <> 0 then begin
            exit;
        end;

        graph1.init('LAM', 'P_OTK');
        graph2.init('LAM', 'M_WAIT');
        graph3.init('LAM', 'K_APPS');

        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            str(i + 1, s);
            funcArray[i].funcName := s + 'Source';
            funcArray[i].color := i + 1;
        end;

        for i := 0 to ARRAY_SIZE do begin
            read(f, results);
            for j := 0 to NUMBER_OF_SOURCES - 1 do begin
                funcArray[j].xCoords[i] := results.intensity;
                funcArray[j].yCoords[i] := results.probabilityOfFailure[j];
            end;
        end;
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            graph1.addFunction(funcArray[i]);
        end;
        graph1.draw(100, 230);

        seek(f, 0);
        for i := 0 to ARRAY_SIZE do begin
            read(f, results);
            for j := 0 to NUMBER_OF_SOURCES - 1 do begin
                funcArray[j].xCoords[i] := results.intensity;
                funcArray[j].yCoords[i] := results.averageWaitingTime[j];
            end;
        end;
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            graph2.addFunction(funcArray[i]);
        end;
        graph2.draw(400, 230);

        seek(f, 0);
        for i := 0 to ARRAY_SIZE do begin
            read(f, results);
            for j := 0 to NUMBER_OF_SOURCES - 1 do begin
                funcArray[j].xCoords[i] := results.intensity;
                funcArray[j].yCoords[i] := results.averageAppsInBuffer[j];
            end;
        end;
        for i := 0 to NUMBER_OF_SOURCES - 1 do begin
            graph3.addFunction(funcArray[i]);
        end;
        graph3.draw(100, 400);

        close(f);
        settextstyle (SmallFont, HorizDir, 5);
    end;
end.
