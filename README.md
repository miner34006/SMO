# Классы и их назначение

## Функциональный модуль
Бизнес логика программы.

### TimeBehaviour
`TimeBehaviour` -  стратегия генерации времени заявки  (см. [паттерн стратегия](https://refactoring.guru/ru/design-patterns/strategy)). В данной работе используются несколько стратегий генерации: регулярный, равномерный, простейший, эрланга.  За каждый из данных типов генерации отвечает соответсвующий класс, являющийся дочерним к классу _TimeBehaviour_ (_Uniform, Regular, Simple, Erlang_).

Число, соответствующее временному отрезку, генерируется в методе `countTime(intensity : Double)`. В зависимости от типа генерации меняется формула.

Данные классы используются в нескольких местах в программе, а именно: в классах `Source` и `Handler`.  Класс Source создает заявки через определенное время (выдаваемое методом _countTime(), а класс Handler обрабатывает полученные заявки также за время полученное из метода /countTime()_.

### Source
 `Source`  - класс источник, генерирующий заявки. Сгенерировать заявку – значит сформировать момент поступления ее в систему. Самый важный параметр источника - интенсивность (скорость работы). От нее зависит то, насколько быстро будут генерироваться заявки.

### Handler
`Handler` - прибор. Устройство обрабатывающее поступающие заявки.  Прибор также как и источник имеет интенсивность (скорость работы). От нее зависит то, насколько быстро он будет обрабатывать поступающие заявки. 

### Application
`Application` - заявка. Класс заявки содержит несколько важных полей, необходимых для учета статистики: номер источника, который ее генерировал и время генерации.

### SelectionStrategy
`SelectionStrategy` - стратегия выборки из буфера. В данной работе имеется несколько различных вариаций выборки заявок (с приоритетом, без приоритета, LIFO, FIFO и так далее). Было принято решение использовать паттерн стратегия (см. [паттерн стратегия](https://refactoring.guru/ru/design-patterns/strategy)) для удобной модификации кода под различные варианты выборки. 

### Buffer
`Buffer` - класс буфера. Буфер необходим для реализации очереди заявок. Когда прибор обрабатывает заявку, новые заявки помещаются в буфер, откуда в дальнейшем они отправятся в прибор. Как и любая очередь, буфер имеет несколько важных методов: `addApplication()` и `removeApplication()` реализующих соотвественно добавление новой заявки и выборки оной из буфера (в соотвествии со стратегией выборки [см. _SelectionStrategy_]).

### FuncitonalModule
 `FunctionalModule` - основной класс для работы системы. Содержит в себе источники, прибор и буфер.  В конструкторе класса инициализируются источник и прибор (задается необходимая интенсивность и создаются классы генерации времени). 

#### Алгоритм работы
1. Генерируем первичные заявки;
2. Выбираем самое ранее событие (окончание работы прибора или генерация новой заявки);
3. Если самое ранее событие - генерация новой заявки то, пытаемся добавить ее в буфер (если не получается (буфер заполнен), увеличиваем кол-во необработанных заявок) и генерируем новую заявку.
4. Если самое ранее событие - окончания работы прибора то проверяем есть ли заявки в буфере. Если там не пусто, берем оттуда заявку и подсчитываем все интересующие нас данные. Если же буфер пустой, ищем самое ранее время генерации новой заявки и начинаем ее обрабатывать, генерируем новую заявку. 
5. Повторяем с пункта 2.

## Интерфейсный модуль
Данный модуль отвечает за  GUI данной программы. 

### Menu
`Menu` - класс простого меню (можно назвать его кнопкой). Каждое меню имеет свое действие (за это отвечает команда, которую мы вручаем кнопке на этапе создания (класс _Command_)). Для выполнения этого действия используется метод `execute()`.  Также стоит отметить отдельное поле - состояние кнопки ( за это отвечает класс _SelectionState_, о чем далее). В данной работе предусмотрены 3 различных состояния: меню активно (пользователь находится на нем), меню неактивно, меню для редактирования (используется в настройках системы). Как и любое меню, наше имеет Label и позицию на экране.

### CompositeMenu
`CompositeMenu ` - составное меню. Практически ничем не отличается от Menu за исключение нескольких вещей. Агрегирует (хранит) в себе другие меню (выпадающие подменю). Соответсвенно метод `execute()` реализует лишь одну функцию (отображает все подменю). 

Имеет несколько наследников `VerticalCompositeMenu` и `HorizontalCompositeMenu` реализующих соотвественно вертикальное составное меню (все подменю разворачиваются вертикально) и горизонтальное.

Для лучшего понимания устройства меню, советую прочитать про паттерн [Компоновщик](https://refactoring.guru/ru/design-patterns/composite). 

### Command
`Command` - класс команды (см. [паттерн команда](https://refactoring.guru/ru/design-patterns/command)). Действие которое мы предоставляем кнопке. Некий слой между интересом и бизнес логикой нашей программы. 

Для каждой кнопки имеется своя команда: `HelpCommand`(показ помощи), `SimulationCommand` (симуляция работы СМО), `TableResultsCommand`(отображение результатов в виде таблицы), `GraphResultCommand`(отображение результатов в виде графиков), `SettingsCommand`(настройки параметров системы). 

### SelectionState
`SelectionState` - состояние кнопки (активна, неактивна, изменяющаяся соотвественно `ActiveMenuState`, `DeactiveMenuState`, `ChangingMenuState`).  Каждое из состояний меняет лишь отрисовку меню. Нам достаточно лишь изменить состояние кнопки во время выполнения программы чтобы она начала отображаться по-новому (см. [паттерн состояние](https://refactoring.guru/ru/design-patterns/state)).

### InterfaceModule
`InterfaceModule` - собственно сам модуль интерфейса. Вся логика интерфейса реализована в классах меню, их состояний и команд. Интерфейсный модуль содержит лишь указатель на меню, метод `execute()` которого выполнит действие предназначенное данному меню. 

## Модуль графики
Отвечает за отображение графиков (во время симуляции и конечных результатов), таблиц.

### FunctionGraph
`FunctionGraph` - класс графика. Данный класс позволяет не беспокоиться о масштабировании и отображении различных функций. Все что нам нужно, передать функцию в данный класс, а он уже подберет нужный масштаб, подпишет оси координат, сделает разметку. Пользователю остается лишь вызвать метод `draw()` , передав в него координаты места, в котором необходимо отобразить график.

### GraphicModule
`GraphicModule` - графический модуль. Данный класс предоставляет несколько важных функций, таких как: `printSimulationCoords()`- рисование системы координат, отображающемся во время симуляции, `printPoint()` - рисование точки на графике по время симуляции, `printTable()` и `printResultsCoords()` - методы для отображения финальной статистики в различных представлениях (в виде таблицы и графиков соотвественно).

Стоит упомянуть, что финальные результаты моделирования записываются в файл (во время симуляции (_SimulationCommand_)). А методы `printTable()` и `printResultsCoords()` лишь читают и отображают данные из файла.

## Main
### SMO
`SMO` - класс, стоящий из всех модулей описанных выше. В конструкторе класса происходит настройка всех модулей, необходимых для его работы (происходит инициализация меню, модулей, создаются команды). Данный класс имеет лишь один метод - `start()` , запускающий всю систему.
