{$N+}

Unit F_Sour;

Interface
    uses crt, Types, F_Time;

    {Класс источника}
    Type Source = object
        public
            constructor init(intensity : Double; var timeBehaviour : PTimeBehaviour);
            destructor done;
            
            {Получение времени генерации заявки}
            function getPostTime : Double;
            {Установка интенсивности источника}
            procedure setIntensity(intensity : Double);
            {Обнуление всех полей}
            procedure zeroData;
            {Генерация новой заявки}
            procedure postApplication;

        private
            {Время генерации последней заявки}
            mPostTime      : Double;
            {Интенсивность источника}
            mIntensity     : Double;
            {Стратегия генерации времени}  
            mTimeBehaviour : PTimeBehaviour;
    end;

    Type PSource = ^Source;
    Type SourceArray = array[0..NUMBER_OF_SOURCES - 1] of PSource;


Implementation
    constructor Source.init(intensity : Double; var timeBehaviour : PTimeBehaviour);
    begin
        mIntensity := intensity; 
        mTimeBehaviour := timeBehaviour;
        zeroData;
    end;

    destructor Source.done;
    begin
        dispose(mTimeBehaviour);
    end;

    function Source.getPostTime: Double;
    begin
        getPostTime := mPostTime;
    end;

    procedure Source.zeroData;
    begin
        mPostTime := 0;
    end;

    procedure Source.setIntensity(intensity : Double);
    begin
        mIntensity := intensity;
    end;

    procedure Source.postApplication;
    begin
        mPostTime := mPostTime + mTimeBehaviour^.countTime(mIntensity);
    end;
end.
