{$N+}

Unit G_FGraph;

Interface
    uses crt, Graph, Types;

    const ARRAY_SIZE = 10;
    Type DataArray = array [0..ARRAY_SIZE] of Double;

    Type Rfunc = record
        funcName : String;
        color : Word;
        xCoords : DataArray;
        yCoords : DataArray;
    end;

    Type FunctionGraph = object
        public
            constructor init(xLabel, yLabel : String);
            destructor done;

            procedure draw(x, y : Word);
            procedure addFunction(func : Rfunc);

        private
            mXLabel : String;
            mYLabel : String;

            mXCof : Double;
            mYCof : Double;

            mXAver : Double;
            mYAver : Double;

            mXMin : Double;
            mYMin : Double;

            mNumFunctions : Word;
            mFunctions : array [0..5] of Rfunc;

            procedure drawCoordinateSystem(x, y : Word);
            procedure drawCoordinateAxes(x, y : Word);
            procedure markCoordinateAxes(x, y : Word);
            procedure signCoordinateAxes(x, y : Word);
            procedure drawFunctions(x, y : Word);
    end;

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
end.
