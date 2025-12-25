program lab4;

uses 
  crt;

type 
  PNode = ^Node; //указатель на узел
  Node = record  //структура узла
    login: string; //логин - первое поле
    password: integer; //пароль - второе поле
    next: PNode; //ссылка на следующий узел
    prev: PNode; //ссылка на предыдущий узел
  end;

var
  head, tail: PNode;
  head2, tail2: PNode;
  choice, paragraphs: integer;
  exitFlag, is_created, is_created2: boolean;
  key: char;
  
//тихое удаление
procedure DeleteStructureSilent;
var 
  current, nextNode: PNode;
begin
  current := head;
  while current <> nil do
  begin
    nextNode := current^.next;
    dispose(current);
    current := nextNode;
  end;
  head := nil;
  tail := nil;
  is_created := false;
end;
 
//создание структуры
procedure CreateStructure;
var
  confirm: char;
begin
  clrscr();
  writeln('     Создание структуры     ');
  writeln('----------------------------');
  
  if head <> nil then
  begin
    writeln('Структура уже существует и содержит данные.');
    writeln('Удалить текущую структуру перед созданием новой? (Y/N)');
    writeln;
    
    confirm := readkey;
    writeln(confirm);
    
    if (confirm = 'y') or (confirm = 'Y') or (confirm = 'н') or (confirm = 'Н') then
    begin
      DeleteStructureSilent;
      is_created := true;
      writeln;
      writeln('Существующая структура удалена. Новая создана.');
      writeln('Нажмите любую клавишу...');
      readkey();
    end
    else
    begin
      writeln;
      writeln('Создание отменено. Текущая структура сохранена.');
      writeln('Нажмите любую клавишу...');
      readkey();
    end;
    exit;
  end;

  head := nil;
  tail := nil;
  is_created := true;
  writeln('Структура создана.');
  writeln;
  writeln('Нажмите любую клавишу...');
  readkey();
end;

//удаление структуры
procedure DeleteStructure;
begin
  clrscr();
  writeln('     Удаление структуры     ');
  writeln('----------------------------');
  
  if not is_created then
  begin
    clrscr;
    writeln('Структура не создана. Удалять нечего.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;

  DeleteStructureSilent;
  writeln('Структура удалена.');
  writeln;
  writeln('Нажмите любую клавишу...');
  readkey();
end;

//добавление элемента в конец
procedure AddToEnd;
var
  newNode: PNode;
begin
  clrscr();
  writeln('     Добавление элемента в конец     ');
  writeln('-------------------------------------');
  
  if not is_created then
  begin
    clrscr;
    writeln('Структура не создана!');
    writeln('Сначала выполните пункт "1. Создание структуры".');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  new(newNode);
  writeln('Введите Логин: ');
  readln(newNode^.login);
  
  writeln('Введите пароль: ');
  readln(newNode^.password);
  
  newNode^.next := nil;
  newNode^.prev := tail;
  
  if tail = nil then
    head := newNode
  else
    tail^.next := newNode;
  
  tail := newNode;
  writeln('Элемент добавлен в конец списка.');
  writeln;
  writeln('Нажмите любую клавишу...');
  readkey();
end;
  
//показать все элементы списка
procedure ReadElem;
var 
  current: PNode;
begin
  clrscr();
  writeln('     Элементы структуры     ');
  writeln('----------------------------');
  
  if not is_created then
  begin
    clrscr;
    writeln('Cтруктура не создана.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;

  if head = nil then
  begin
    writeln('Список пуст.');
    writeln('Нажмите любую клавишу...');
    readkey;
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
  
//подсчёт количества элементов
function AmountOfElements: integer;
var
  current: PNode;
  count: integer;
begin  
  count := 0;
  current := head;
  while current <> nil do
  begin
    inc(count);
    current := current^.next;
  end;
  AmountOfElements := count;
end;
  
//поиск по логину
procedure FindByLogin;
var
  current: PNode;
  target: string;
  found: boolean;
begin
  clrscr();
  writeln('     Поиск элемента по логину     ');
  writeln('----------------------------------');
  if not is_created then
  begin
    clrscr;
    writeln('Ошибка: структура не создана!');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;

  if head = nil then
  begin
    clrscr;
    writeln('Список пуст.');
    writeln('Нажмите любую клавишу...');
    readkey;
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
    writeln('Элемент с логином "', target, '" не найден.');
  
  writeln('Нажмите любую клавишу...');
  readkey;
end;

//поиск по паролю
procedure FindByPassword;
var
  current: PNode;
  target: integer;
  found: boolean;
begin
  clrscr();
  writeln('     Поиск элемента по паролю     ');
  writeln('----------------------------------');
  if not is_created then
  begin
    clrscr;
    writeln('Ошибка: структура не создана!');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;

  if head = nil then
  begin
    clrscr;
    writeln('Список пуст.');
    writeln('Нажмите любую клавишу...');
    readkey;
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

procedure FindElementByIndex(index: integer);
var
  current: PNode;
  i: integer;
begin
  clrscr();
  writeln('     Поиск элемента по индексу     ');
  writeln('-----------------------------------');
  if not is_created then
  begin
    writeln('Структура не создана.');
    exit;
  end;
  if head = nil then
  begin
    writeln('Список пуст.');
    exit;
  end;
  if index < 0 then
  begin
    writeln('Индекс должен быть >= 0.');
    exit;
  end;

  current := head;
  i := 0;
  while (current <> nil) and (i < index) do
  begin
    current := current^.next;
    i := i + 1;
  end;

  if current = nil then
    writeln('Элемента с индексом ', index, ' не существует.')
  else
    writeln('Найден элемент с индексом [', index, ']: логин = ', current^.login, ', пароль = ', current^.password);
end;

procedure ReplaceElementbyIndex(index: integer);
var
  current: PNode;
  i: integer;
begin
  clrscr();
  writeln('     Замена элемента по индексу     ');
  writeln('------------------------------------');
  if not is_created then
  begin
    writeln('Структура не создана.');
    exit;
  end;
  if head = nil then
  begin
    writeln('Список пуст.');
    exit;
  end;
  if index < 0 then
  begin
    writeln('Индекс должен быть >= 0.');
    exit;
  end;

  current := head;
  i := 0;
  while (current <> nil) and (i < index) do
  begin
    current := current^.next;
    i := i + 1;
  end;

  if current = nil then
    writeln('Элемента с индексом ', index, ' не существует.')
  else
  begin
    writeln('Текущие данные: логин = ', current^.login, ', пароль = ', current^.password);
    writeln('Введите новый логин: ');
    readln(current^.login);
    writeln('Введите новый пароль: ');
    readln(current^.password);
    writeln('Элемент [', index, '] обновлён.');
  end;
end;


procedure AddBeforeIndex(index: integer);
var
  newNode, current: PNode;
  i: integer;
begin
    clrscr();
  writeln('     Добавление элемента перед индексом     ');
  writeln('--------------------------------------------');
  if not is_created then
  begin
    writeln('Структура не создана.');
    exit;
  end;

  new(newNode);
  writeln('Введите логин: '); readln(newNode^.login);
  writeln('Введите пароль: '); readln(newNode^.password);

  if head = nil then
  begin
    //вставка в пустой список
    head := newNode;
    tail := newNode;
    newNode^.next := nil;
    newNode^.prev := nil;
    writeln('Элемент добавлен в пустой список.');
    exit;
  end;

  if index <= 0 then
  begin
    //вставка в начало
    newNode^.next := head;
    newNode^.prev := nil;
    head^.prev := newNode;
    head := newNode;
    writeln('Элемент вставлен в начало списка (перед индексом 0).');
    exit;
  end;

  //ищем элемент по индексу
  current := head;
  i := 0;
  while (current <> nil) and (i < index) do
  begin
    current := current^.next;
    inc(i);
  end;

  if current = nil then
  begin
    //если индекс за пределами, значит вставляем в конец
    newNode^.next := nil;
    newNode^.prev := tail;
    tail^.next := newNode;
    tail := newNode;
    writeln('Индекс ', index, ' выходит за границы. Элемент добавлен в конец.');
  end
  else
  begin
    //вставка перед позицией index
    newNode^.prev := current^.prev;
    newNode^.next := current;
    current^.prev^.next := newNode;
    current^.prev := newNode;
    writeln('Элемент вставлен перед индексом ', index, '.');
  end;
end;

procedure DeleteByIndex(index: integer);
var
  current: PNode;
  i: integer;
begin
  clrscr();
  writeln('     Удаление по индексу     ');
  writeln('-----------------------------');
  
  if not is_created then
  begin
    writeln('Структура не создана.');
    exit;
  end;
  if head = nil then
  begin
    writeln('Список пуст.');
    exit;
  end;
  if index < 0 then
  begin
    writeln('Индекс должен быть >= 0.');
    exit;
  end;

  current := head;
  i := 0;
  while (current <> nil) and (i < index) do
  begin
    current := current^.next;
    i := i + 1;
  end;

  if current = nil then
  begin
    writeln('Элемента с индексом ', index, ' не существует.');
    exit;
  end;

  // Удаление узла current
  if current^.prev <> nil then
    current^.prev^.next := current^.next
  else
    head := current^.next;  // удаляем первый элемент

  if current^.next <> nil then
    current^.next^.prev := current^.prev
  else
    tail := current^.prev;  // удаляем последний элемент

  dispose(current);
  writeln('Элемент с индексом ', index, ' удалён.');
end;

procedure SplitList(ind: integer); //разделить список на 2
var
  current: PNode;
  i: integer;
begin
  if not is_created then
  begin
    writeln('Список не создан.');
    exit;
  end;
  if head = nil then
  begin
    writeln('Список пуст.');
    exit;
  end;
  if ind < 0 then
  begin
    writeln('Индекс должен быть >= 0.');
    exit;
  end;

  current := head;
  i := 0;
  while (current <> nil) and (i <= ind) do
  begin
    current := current^.next;
    i := i + 1;
  end;

  if current = nil then
  begin
    writeln('Невозможно разделить. Индекс выходит за границы списка.');
    exit;
  end;
  if current^.next = nil then
  begin
    writeln('Разделение после последнего элемента. Второй список будет пуст.');
    exit;
  end;

  //формируем второй список
  head2 := current^.next;
  tail2 := tail;
  head2^.prev := nil;
  current^.next := nil;
  tail := current;

  is_created2 := true;
  writeln('Список разделён. Второй список создан.');
end;

procedure GetListsTogether;
begin
  if not is_created then
  begin
    writeln('Первый список не создан.');
    exit;
  end;
  if not is_created2 then
  begin
    writeln('Второй список не создан.');
    exit;
  end;
  if head2 = nil then
  begin
    writeln('Второй список пуст. Объединение не требуется.');
    exit;
  end;

  if head = nil then //если первый список пуст
  begin
    head := head2;
    tail := tail2;
  end
  else
  begin
    //соединяем tail первого с head второго
    tail^.next := head2;
    head2^.prev := tail;
    tail := tail2;
  end;

  //обнуляем второй список
  head2 := nil;
  tail2 := nil;
  is_created2 := false;
  writeln('Списки объединены.');
end;

//отображение меню
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
  writeln('2. Добавление элемента в конец списка');
  
  if choice = 3 then write('> ') else write('  ');
  writeln('3. Добавление элемента перед индексом');
  
  if choice = 4 then write('> ') else write('  ');
  writeln('4. Удаление элемента по индексу');
  
  if choice = 5 then write('> ') else write('  ');
  writeln('5. Определение пустоты структуры');
  
  if choice = 6 then write('> ') else write('  ');
  writeln('6. Определение количества элементов в структуре');
  
  if choice = 7 then write('> ') else write('  ');
  writeln('7. Вывод всех элементов списка');
  
  if choice = 8 then write('> ') else write('  ');
  writeln('8. Поиск элемента по логину');
  
  if choice = 9 then write('> ') else write('  ');
  writeln('9. Поиск элемента по паролю');
  
  if choice = 10 then write('> ') else write('  ');
  writeln('10. Поиск элемента по индексу');
  
  if choice = 11 then write('> ') else write('  ');
  writeln('11. Замена элемента по индексу');
  
  if choice = 12 then write('> ') else write('  ');
  writeln('12. Удаление структуры');

  if choice = 13 then write('> ') else write('  ');
  writeln('13. Разделить список');
  
  if choice = 14 then write('> ') else write('  ');
  writeln('14. Объединить списки');
  
  if choice = 15 then write('> ') else write('  ');
  writeln('15. Выход');
  writeln();
  writeln('----------------------------------------');
  writeln('Управление: W/↑ - вверх, S/↓ - вниз');
  writeln('Enter - выбор, ESC - выход');
  writeln('----------------------------------------');
end;

//основная программа
begin
  is_created := false;
  is_created2 := false;
  head := nil;
  tail := nil;
  head2 := nil;
  tail2 := nil;

  //переменные для меню
  exitFlag := False;
  choice := 1;
  paragraphs := 15;

  repeat
    menu;
    key := readkey;

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
            3: AddBeforeIndex; //добавить элемент в перед индексом
            4: DeleteByIndex; //удалить по индексу
            5: begin //проверка на пустоту
                 if not is_created then
                 begin
                   clrscr;
                   writeln('Ошибка: структура не создана!');
                   writeln('Нажмите любую клавишу...');
                   readkey;
                 end
                 else
                 begin
                   clrscr;
                   if (head = nil) then
                     writeln('Структура пуста.')
                   else
                     writeln('Структура НЕ пуста.');
                   writeln('Нажмите любую клавишу...');
                   readkey;
                 end;
               end;
            6: begin //количество
                 if not is_created then
                 begin
                   clrscr;
                   writeln('Ошибка: структура не создана!');
                   writeln('Нажмите любую клавишу...');
                   readkey;
                 end
                 else
                 begin
                   clrscr;
                   writeln('Количество записей: ', AmountOfElements);
                   writeln('Нажмите любую клавишу...');
                   readkey;
                 end;
               end;
            7: ReadElem; //вывести элементы списка
            8: FindByLogin;
            9: FindByPassword;
            10: FindElementByIndex;
            11: ReplaceElementByIndex;
            12: DeleteStructure;
            13: SplitList;
            14: GetListsTogether;
            15: exitFlag := True;
          end;
        end;
      #27:  //ESC
        exitFlag := True;
    end;

  until exitFlag;

  //финальная очистка
  DeleteStructureSilent;

  clrscr;
  writeln('Программа завершена.');
  writeln('Нажмите любую клавишу для выхода...');
  readkey;
end.
