Program lab4;

uses 
  crt;

type 
  PNode = ^Node; //указатель на узел
  Node = record //структура  узла
    login: string; //поле для айди
    password: integer; //поле для значения
    next: PNode; //ссылка на следующий узел
    prev: PNode; //ссылка на предыдущий узел
  end;

var
  head, tail: PNode;
  choice, paragraphs: integer;
  exitFlag: boolean;
  key: char;
  
 
procedure CreateStructure;
begin
  clrscr();
  writeln('     Создание структуры     ');
  writeln('----------------------------');
  head := nil;
  tail := nil;
  writeln('Структура создана.');
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey();
  exit;
end;

procedure DeleteStructure;
var 
  current, nextNode: PNode;
  
begin
  clrscr();
  writeln('     Удаление структуры     ');
  writeln('----------------------------');
  current := head;
  
  while current <> nil do
  begin
    nextNode := current^.next; //сохранение следующего узла
    dispose(current);
    current := nextNode; //переходим к следующему
  end;
  
  head := nil;
  tail := nil;
  writeln('Структура удалена');
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey();
  exit;
end;

procedure AddToEnd;
var
  newNode: PNode;
begin
  clrscr();
  writeln('     Добавление элемента в конец     ');
  writeln('-------------------------------------');
  new(newNode); //выделяем память под новый узел
  writeln('Введите Логин: ');
  readln(newNode^.login);
  
  writeln('Введите пароль: ');
  readln(newNode^.password);
  
  newNode^.next := nil;
  newNode^.prev := tail;
  
  if tail = nil then
    head := newNode //если список был пуст, то новый узел становится началом и концом
  else
    tail^.next := newNode; //иначе - ставим в конец
  
  tail := newNode;
  writeln('Элемент добавлен в конец списка.');
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey();
end;
  
procedure ReadElem;
var 
  current: PNode;
begin
  clrscr();
  writeln('     Чтение элементов     ');
  writeln('--------------------------');
  if head = nil then
  begin
    writeln('Список пуст.');
    exit;
  end;

  current := head;
  while current <> nil do
  begin
    writeln(current^.login, ' <---> ', current^.password);
    current := current^.next;
  end;
  writeln('Нажмите любую клавишу...');
  readkey;
end;
  
function AmountOfElements: integer;
var
  current: PNode;
  count: integer;
begin
  count := 0;
  current := head;
  
  while current <> nil do
  begin
    count := count + 1;
    current := current^.next;
  end;
  AmountOfElements := count;
end;
  
procedure FindByLogin; //поиск элемента
var
  current: PNode;
  target: string;
  found:boolean;
begin
  if head = nil then
  begin
    writeln('Список пуст.');
    exit;
  end;
  
  write('Введите логин для поиска: ');
  readln(target);
  
  current := head;
  found := false;
  
  while current <> nil do
  begin
    if current^.login = target then
    begin
      writeln('Найдено: логин - ', current^.login, ', пароль - ', current^.password);
      found := true;
    end;
    current := current^.next;
  end;
  
  if not found then
    writeln('Элемент с логином ', target, ' не найден.');
  
  writeln('Нажмите любую клавишу...');
  readkey;
end;

procedure FindByPassword; //поиск элемента
var
  current: PNode;
  target: integer;
  found:boolean;
begin
  if head = nil then
  begin
    writeln('Список пуст.');
    exit;
  end;
  
  write('Введите пароль для поиска: ');
  readln(target);
  
  current := head;
  found := false;
  
  while current <> nil do
  begin
    if current^.password = target then
    begin
      writeln('Найдено: логин - ', current^.login, ', пароль - ', current^.password);
      found := true;
    end;
    current := current^.next;
  end;
  
  if not found then
    writeln('Элемент с паролем ', target, ' не найден.');
  
  writeln('Нажмите любую клавишу...');
  readkey;
end;
  
procedure menu;
begin
  clrscr();
  writeln('Лабораторная работа №4.');
  writeln('Двусвязный список.');
  writeln('----------------------------------------');
  writeln();
  writeln('Выберите действие:');
  writeln();
  
  if choice = 1 then write('> ') else write('  ');
  writeln('1. Создание структуры');
  
  if choice = 2 then write('> ') else write('  ');
  writeln('2. Запись элемента в структуру');
  
  if choice = 3 then write('> ') else write('  ');
  writeln('3. Поиск элемента по логину');
  
  if choice = 4 then write('> ') else write('  ');
  writeln('4. Поиск элемента по паролю');
  
  if choice = 5 then write('> ') else write('  ');
  writeln('5. Чтение элемента из структуры');
  
  if choice = 6 then write('> ') else write('  ');
  writeln('6. Определение пустоты структуры');
  
  if choice = 7 then write('> ') else write('  ');
  writeln('7. Определение количества элементов в структуре');
  
  if choice = 8 then write('> ') else write('  ');
  writeln('8. Удаление структуры');
  
  if choice = 9 then write('> ') else write('  ');
  writeln('9. Выход');
  writeln();
  writeln('----------------------------------------');
  writeln('Управление: W/↑ - вверх, S/↓ - вниз');
  writeln('Enter - выбор, ESC - выход');
  writeln('----------------------------------------');
end;

begin
  // Инициализация глобальных переменных списка
  head := nil;
  tail := nil;

  // Переменные для меню
  exitFlag := False;
  choice := 1;
  paragraphs := 9; //количество пунктов меню

  repeat
    menu; //процедура отображения меню
    key := readkey;

    //обработка клавиш
    case key of
      'w', 'W', 'ц', 'Ц', #38:  //вверх
        begin
          choice := choice - 1;
          if choice < 1 then choice := paragraphs;
        end;
      's', 'S', 'ы', 'Ы', #40:  //вниз
        begin
          choice := choice + 1;
          if choice > paragraphs then choice := 1;
        end;
      #13:  //Enter
        begin
          case choice of
            1: CreateStructure; //создать структуру
            2: AddToEnd; //добавить элемент в конец 
            3: FindByLogin; //найти элемент по логину
            4: FindByPassword; //найти элемент по паролю
            5: ReadElem; //прочитать элементы
            6: begin //проверка на пустоту
                 clrscr;
                 if (head = nil) then
                   writeln('Структура пуста.')
                 else
                   writeln('Структура НЕ пуста.');
                 writeln('Нажмите любую клавишу...');
                 readkey;
               end;
            7: begin //количество элементов
                 clrscr;
                 writeln('Количество записей: ', AmountOfElements);
                 writeln('Нажмите любую клавишу...');
                 readkey;
               end;
            8: DeleteStructure; //удалить структуру;
            9: exitFlag := True; //выход
          end;
        end;
      #27:  //ESC
        exitFlag := True;
    end;

  until exitFlag;

  //перед завершением удаляем структуру
//  DeleteStructureSilent;

  clrscr;
  writeln('Программа завершена.');
  writeln('Нажмите любую клавишу для выхода...');
  readkey;
end.
