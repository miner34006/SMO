{$N+}

Unit F_Hand;

Interface
    uses crt, F_Time;

    {Класс прибора}
    Type Handler = object
        public
            constructor init(intensity : Double; var timeBehaviour : PTimeBehaviour);
            destructor done;

            {Генерация времени окончания обработки заявки}
            function generateFinishTime(acceptTime : Double): Double;
            {Получение времени окончания работы прибора}
            function getFinishTime : Double;
            {Установка интенсивности прибора}
            procedure setIntensity(intensity : Double);
            {Обнуление всех полей}
            procedure zeroData;

        private
            {Время окончания работы прибора}
            mFinishTime    : Double; 
            {Интенсивность прибора}
            mIntensity     : Double;      
            {Стратегия генерации времени}  
            mTimeBehaviour : PTimeBehaviour;
    end;

    Type PHandler = ^Handler;


Implementation
    constructor Handler.init(intensity : Double; var timeBehaviour : PTimeBehaviour);
    begin
        mIntensity := intensity; 
        mTimeBehaviour := timeBehaviour;
        zeroData;
    end;

    destructor Handler.done;
    begin
        dispose(mTimeBehaviour);
    end;

    procedure Handler.zeroData;
    begin
        mFinishTime := 0;
    end;

    procedure Handler.setIntensity(intensity : Double);
    begin
        mIntensity := intensity;
    end;

    function Handler.getFinishTime: Double;
    begin
        getFinishTime := mFinishTime;
    end;

    function Handler.generateFinishTime(acceptTime : Double): Double;
    var workingTime : Double;
    begin
        workingTime := mTimeBehaviour^.countTime(mIntensity);
        mFinishTime := acceptTime + workingTime;
        generateFinishTime := workingTime;
    end;
end.
