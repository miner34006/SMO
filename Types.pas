{$N+}

{Types unit}
Unit Types;

Interface
    uses crt;

    {Кол-во источников}
    const NUMBER_OF_SOURCES = 2;
    {Размер буфера}
    const BUFFER_SIZE = 2;
    {Изменяющийся источник}
    const CHANGING_SOURCE = 1;

    {Указатель на double}
    Type PDouble = ^Double;
    {Массив размерности NUMBER_OF_SOURCES}
    Type DoubleArray = array[0..NUMBER_OF_SOURCES - 1] of Double;

    {Настройки для СМО}
    Type SystemSettings = record
        {Минимальная длинна реализации}
        KMIN           : Double;
        {Минимальная интенсивность (лямбда)}
        minIntensity   : Double;
        {Максимальная интенсивность (лямбда)}
        maxIntensity   : Double;
    end;
    Type PSystemSettings = ^SystemSettings;

    {Финальная статистика работы СМО}
    Type RResults = record
        {Интенсивность (лямбда)}
        intensity : Double;
        {Вероятность отказа}
        probabilityOfFailure : DoubleArray;
        {Среднее время ожидания}
        averageWaitingTime : DoubleArray;
        {Среднее кол-во заявок в буфере}
        averageAppsInBuffer : DoubleArray;
    end;

    {Типизированный файл со статистикой}
    Type ResultFile = file of RResults;

    {Статистика для одного источника}
    Type SourceStatistics = record
        {Время проведенное в буфере}
        timeInBuffer          : Double;
        {Время проведенное в приборе}
        timeInHandler         : Double;
        {Кол-во обработанных заявок из источника}
        numReceivedFromSource : Longint;
        {Кол-во обработанных заявок из буфера}
        numReceivedFromBuffer : Longint;
        {Кол-во отклоненных заявок}
        numRejected           : Longint;
        {Число заявок в буфере}
        appsInBuffer          : Longint;
    end;

    {Статистика для всех источников}
    Type IterarionStatistics = array [0..NUMBER_OF_SOURCES - 1] of SourceStatistics;
         PIterarionStatistics = ^IterarionStatistics;


Implementation
    
end.
