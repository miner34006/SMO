{$N+}

Unit G_Graph;

Interface
    uses crt, Types;

    Type GraphicModule = object
        public

            procedure printPoint(x, y : Integer);
            procedure printSimulationCoords;
            procedure eraseSimulationCoords;
        private
            {mData : SomeType;}
    end;

    Type PGraphicModule = ^GraphicModule;

Implementation
    procedure GraphicModule.printSimulationCoords;
    begin
        
    end;

    procedure GraphicModule.eraseSimulationCoords;
    begin
        
    end;


    procedure GraphicModule.printPoint(x, y : Integer);
    begin
        
    end;
end.
