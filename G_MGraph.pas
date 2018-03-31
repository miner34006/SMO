{$N+}

Unit G_MGraph;

Interface
    uses crt, G_FGraph, Graph, Types;

    Type GraphicModule = object
        {TODO: Выделить в отдельный класс}
        procedure printPoint(x : Longint; y : Double; color : Word);
        procedure printSimulationCoords(settings : SystemSettings);
        {TODO: Выделить в отдельный класс}

        {TODO: должен возвращать FunctionGraph}
        procedure printResultsCoords(var f : ResultFile);

        {TODO: рефакторинг этого метода}
        procedure printTable(var f : ResultFile; rows, columns: Integer);
        procedure erase;
    end;

    Type PGraphicModule = ^GraphicModule;

Implementation
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
    var i : Integer;
        probabilityOfFailureGraph, AverageWaitingTimeGraph, averageAppsInBufferGraph: FunctionGraph;
        results : RResults;
        func1, func2, func3, func4 : Rfunc;
        s: String;
    begin
        {$I-}
        reset(f);
        {$I+}
        if IOresult <> 0 then begin
            exit;
        end;

        probabilityOfFailureGraph.init('LAM', 'P_OTK');
        AverageWaitingTimeGraph.init('LAM', 'M_WAIT');
        averageAppsInBufferGraph.init('LAM', 'K_APPS');

        func1.funcName := '1Source';
        func1.color := Red;

        func2.funcName := '2Source';
        func2.color := Blue;

        for i := 0 to ARRAY_SIZE do begin
            read(f, results);
            func1.xCoords[i] := results.intensity;
            func1.yCoords[i] := results.probabilityOfFailure[0];
            func2.xCoords[i] := results.intensity;
            func2.yCoords[i] := results.probabilityOfFailure[1];
        end;
        probabilityOfFailureGraph.addFunction(func1);
        probabilityOfFailureGraph.addFunction(func2);
        probabilityOfFailureGraph.draw(100, 230);

        seek(f, 0);
        for i := 0 to ARRAY_SIZE do begin
            read(f, results);
            func1.xCoords[i] := results.intensity;
            func1.yCoords[i] := results.averageWaitingTime[0];
            func2.xCoords[i] := results.intensity;
            func2.yCoords[i] := results.averageWaitingTime[1];
        end;
        AverageWaitingTimeGraph.addFunction(func1);
        AverageWaitingTimeGraph.addFunction(func2);
        AverageWaitingTimeGraph.draw(400, 230);

        seek(f, 0);
        for i := 0 to ARRAY_SIZE do begin
            read(f, results);
            func1.xCoords[i] := results.intensity;
            func1.yCoords[i] := results.averageAppsInBuffer[0];
            func2.xCoords[i] := results.intensity;
            func2.yCoords[i] := results.averageAppsInBuffer[1];
        end;
        averageAppsInBufferGraph.addFunction(func1);
        averageAppsInBufferGraph.addFunction(func2);
        averageAppsInBufferGraph.draw(100, 400);

        close(f);
        settextstyle (SmallFont, HorizDir, 5);
    end;
end.
