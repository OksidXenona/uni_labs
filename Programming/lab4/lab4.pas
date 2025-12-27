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
procedure DeleteStructureSilent(var head, tail: PNode; var is_created: boolean);
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
procedure CreateStructure(var head, tail: PNode; var is_created: boolean);
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
      DeleteStructureSilent(head, tail, is_created);
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
procedure DeleteStructure(var head, tail: PNode; var is_created: boolean);
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

  DeleteStructureSilent(head, tail, is_created);
  writeln('Структура удалена.');
  writeln;
  writeln('Нажмите любую клавишу...');
  readkey();
end;

//добавление элемента в конец
procedure AddToEnd(var head, tail: PNode; var is_created: boolean);
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
procedure ReadElem(var head, tail: PNode; var is_created: boolean);
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
function AmountOfElements(var head, tail: PNode; var is_created: boolean): integer;
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
  
//поиск по логину
procedure FindByLogin(var head, tail: PNode; var is_created: boolean);
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
procedure FindByPassword(var head, tail: PNode; var is_created: boolean);
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

procedure FindElementByIndex(var head, tail: PNode; var is_created: boolean);
var
  current: PNode;
  i, index: integer;
begin
  clrscr();
  writeln('     Поиск элемента по индексу     ');
  writeln('-----------------------------------');
  
  if not is_created then
  begin
    writeln('Структура не создана.');
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
  
  write('Введите индекс для поиска (от 0 до ', AmountOfElements(head, tail, is_created) - 1, '): ');
  readln(index);
  
  if index < 0 then
  begin
    writeln('Индекс должен быть >= 0.');
    writeln('Нажмите любую клавишу...');
    readkey;
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
    writeln('Найден элемент с индексом [', index, ']: логин = ', 
            current^.login, ', пароль = ', current^.password);
  
  writeln('Нажмите любую клавишу...');
  readkey;
end;

procedure ReplaceElementByIndex(var head, tail: PNode; var is_created: boolean);
var
  current: PNode;
  i, index: integer;
  newLogin: string;
  newPassword: integer;
begin
  clrscr();
  writeln('     Замена элемента по индексу     ');
  writeln('------------------------------------');
  
  if not is_created then
  begin
    writeln('Структура не создана.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  if head = nil then
  begin
    writeln('Список пуст. Нечего заменять.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;

  writeln('Текущие элементы списка:');
  writeln('------------------------');
  current := head;
  i := 0;
  while current <> nil do
  begin
    writeln('[', i, '] ', current^.login, ' <---> ', current^.password);
    current := current^.next;
    i := i + 1;
  end;
  writeln('------------------------');
  writeln('Всего элементов: ', i);
  writeln;
  
  //запрашиваем индекс
  write('Введите индекс элемента для замены (0 - ', i-1, '): ');
  readln(index);
  
  //проверяем корректность индекса
  if (index < 0) or (index >= i) then
  begin
    writeln('Ошибка: индекс должен быть от 0 до ', i-1, '.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //находим элемент с указанным индексом
  current := head;
  i := 0;
  while (current <> nil) and (i < index) do
  begin
    current := current^.next;
    i:= i + 1;
  end;
  
  if current = nil then
  begin
    writeln('Элемента с индексом ', index, ' не существует.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //показываем текущие данные элемента
  writeln;
  writeln('Текущие данные элемента [', index, ']:');
  writeln('Логин: ', current^.login);
  writeln('Пароль: ', current^.password);
  writeln;
  writeln('Введите новые данные:');
  
  //запрашиваем новые данные
  write('Новый логин: ');
  readln(newLogin);
  write('Новый пароль: ');
  readln(newPassword);
  
 
    //выполняем замену
    current^.login := newLogin;
    current^.password := newPassword;
    
    writeln;
    writeln('Элемент [', index, '] успешно обновлён.');
    
    //показываем обновленный список
    writeln;
    writeln('Обновленный список:');
    writeln('-------------------');
    current := head;
    i := 0;
    while current <> nil do
    begin
      writeln('[', i, '] ', current^.login, ' <---> ', current^.password);
      current := current^.next;
      i := i + 1;
    end;
  
  writeln;
  writeln('Нажмите любую клавишу...');
  readkey;
end;

procedure GetListsTogether(var head, head2, tail, tail2: PNode; var is_created, is_created2: boolean);
var
  current: PNode;
  count1, count2, total: integer;
begin
  clrscr();
  writeln('     Объединение двух списков     ');
  writeln('----------------------------------');
  
  //проверяем существование списков
  if not is_created then
  begin
    writeln('Первый список не создан.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  if not is_created2 then
  begin
    writeln('Второй список не создан.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //подсчитываем элементы в каждом списке
  count1 := 0;
  current := head;
  writeln('Первый список:');
  writeln('--------------');
  if head = nil then
    writeln('Список пуст.')
  else
  begin
    while current <> nil do
    begin
      writeln('[', count1, '] ', current^.login, ' <---> ', current^.password);
      current := current^.next;
      count1 := count1 + 1;
    end;
  end;
  writeln('Всего элементов: ', count1);
  writeln;
  
  count2 := 0;
  current := head2;
  writeln('Второй список:');
  writeln('--------------');
  if head2 = nil then
    writeln('Список пуст')
  else
  begin
    while current <> nil do
    begin
      writeln('[', count2, '] ', current^.login, ' <---> ', current^.password);
      current := current^.next;
      count2 := count2 + 1;
    end;
  end;
  writeln('Всего элементов: ', count2);
  writeln;
  
  total := count1 + count2;
  
  //если оба списка пустые
  if (count1 = 0) and (count2 = 0) then
  begin
    writeln('Оба списка пусты.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //если второй список пустой
  if count2 = 0 then
  begin
    writeln('Второй список пуст.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //показываем, что будет после объединения
  writeln('После объединения будет ', total, ' элементов.');
  writeln();
  
  //выполняем объединение
  if head = nil then
  begin
    //если первый список пустой
    head := head2;
    tail := tail2;
  end
  else
  begin
    //если первый список не пустой
    if tail <> nil then
    begin
      tail^.next := head2;
      if head2 <> nil then
        head2^.prev := tail;
    end;
    
    //обновляем tail
    if tail2 <> nil then
      tail := tail2;
  end;
  
  //очищаем второй список
  head2 := nil;
  tail2 := nil;
  is_created2 := false;
  
  //показываем результат
  writeln;
  writeln('Списки успешно объединены!');
  writeln;
  
  //показываем объединенный список
  current := head;
  if current = nil then
  begin
    writeln('Объединенный список пуст.');
  end
  else
  begin
    writeln('Объединенный список:');
    writeln('--------------------');
    var i: integer := 0;
    while current <> nil do
    begin
      writeln('[', i, '] ', current^.login, ' <---> ', current^.password);
      current := current^.next;
      i := i + 1;
    end;
    writeln('--------------------');
    writeln('Всего элементов: ', i);
  end;
  
  writeln;
  writeln('Второй список очищен.');
  writeln('Теперь доступен только объединенный список.');
  
  writeln('Нажмите любую клавишу...');
  readkey;
end;

procedure AddBeforeIndex(var head, tail: PNode; var is_created: boolean);
var
  newNode, current: PNode;
  i, index: integer;
begin
  clrscr();
  writeln('     Добавление элемента перед индексом     ');
  writeln('--------------------------------------------');
  
  if not is_created then
  begin
    writeln('Структура не создана.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;

  //запрашиваем индекс у пользователя
  if head = nil then
  begin
    writeln('Список пуст. Новый элемент будет добавлен как первый.');
    index := 0;
  end
  else
  begin
    write('Введите индекс, перед которым добавить элемент (0 - ', AmountOfElements(head, tail, is_created) - 1, '): ');
    readln(index);
  end;

  if (index < 0) then
  begin
    writeln('Индекс должен быть >= 0.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;

  //создаем новый узел
  new(newNode);
  writeln('Введите логин нового элемента: ');
  readln(newNode^.login);
  writeln('Введите пароль нового элемента: ');
  readln(newNode^.password);

  //если список пустой
  if head = nil then
  begin
    head := newNode;
    tail := newNode;
    newNode^.next := nil;
    newNode^.prev := nil;
    writeln('Элемент добавлен в пустой список.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;

  //если вставляем перед первым элементом
  if index = 0 then
  begin
    newNode^.next := head;
    newNode^.prev := nil;
    head^.prev := newNode;
    head := newNode;
    writeln('Элемент вставлен в начало списка (перед индексом 0).');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;

  //ищем элемент с указанным индексом
  current := head;
  i := 0;
  
  //идем до элемента с нужным индексом
  while (current <> nil) and (i < index) do
  begin
    current := current^.next;
    i := i + 1;
  end;

  //если индекс равен количеству элементов, добавляем в конец
  if (current = nil) and (i = index) then
  begin
    //добавляем в конец
    newNode^.next := nil;
    newNode^.prev := tail;
    tail^.next := newNode;
    tail := newNode;
    writeln('Элемент добавлен в конец списка.');
  end
  else if current = nil then
  begin
    //если индекс выходит за пределы списка
    writeln('Индекс ', index, ' выходит за границы списка. Элемент не добавлен.');
    dispose(newNode); // Освобождаем память, так как не используем
  end
  else
  begin
    //вставляем перед найденным элементом
    newNode^.prev := current^.prev;
    newNode^.next := current;
    
    if current^.prev <> nil then
      current^.prev^.next := newNode
    else
      head := newNode;
      
    current^.prev := newNode;
    writeln('Элемент вставлен перед индексом ', index, '.');
  end;
  
  writeln('Нажмите любую клавишу...');
  readkey;
end;

procedure DeleteByIndex(var head, tail: PNode; var is_created: boolean);
var
  current: PNode;
  i, index: integer;
begin
  clrscr();
  writeln('     Удаление элемента по индексу     ');
  writeln('--------------------------------------');
  
  if not is_created then
  begin
    writeln('Структура не создана.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  if head = nil then
  begin
    writeln('Список пуст. Удалять нечего.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //показываем текущие элементы и их индексы
  writeln('Текущие элементы списка:');
  writeln('------------------------');
  current := head;
  i := 0;
  while current <> nil do
  begin
    writeln('[', i, '] ', current^.login, ' <---> ', current^.password);
    current := current^.next;
    i := i + 1;
  end;
  writeln('------------------------');
  
  //запрашиваем индекс
  write('Введите индекс элемента для удаления (0 - ', i-1, '): ');
  readln(index);
  
  if (index < 0) or (index >= i) then
  begin
    writeln('Ошибка: индекс должен быть от 0 до ', i-1, '.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //находим элемент с указанным индексом
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
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //сохраняем данные для отображения
  writeln('Удаляем элемент: ', current^.login, ' <---> ', current^.password);
  
  //удаляем элемент в зависимости от его позиции
  if current = head then
  begin
    //удаление первого элемента
    head := current^.next;
    if head <> nil then
      head^.prev := nil
    else
      tail := nil; //если был единственный элемент
  end
  else if current = tail then
  begin
    //удаление последнего элемента
    tail := current^.prev;
    tail^.next := nil;
  end
  else
  begin
    //удаление элемента в середине
    current^.prev^.next := current^.next;
    current^.next^.prev := current^.prev;
  end;
  
  //освобождаем память
  dispose(current);
  
  writeln('Элемент с индексом ', index, ' успешно удалён.');
  
  //показываем обновленный список
  if head = nil then
    writeln('Список теперь пуст.')
  else
  begin
    writeln;
    writeln('Обновленный список:');
    writeln('-------------------');
    current := head;
    i := 0;
    while current <> nil do
    begin
      writeln('[', i, '] ', current^.login, ' <---> ', current^.password);
      current := current^.next;
      i := i + 1;
    end;
  end;
  
  writeln('Нажмите любую клавишу...');
  readkey;
end;

procedure SplitList(var head, head2, tail, tail2: PNode; var is_created, is_created2: boolean);
var
  current: PNode;
  i, index: integer;
begin
  clrscr();
  writeln('     Разделение списка на два     ');
  writeln('----------------------------------');
  
  if not is_created then
  begin
    writeln('Первый список не создан.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  if head = nil then
  begin
    writeln('Первый список пуст. Нечего разделять.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  if is_created2 then
  begin
    writeln('Второй список уже существует!');
    writeln('Сначала объедините списки или очистите второй список.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //показываем текущий список
  writeln('Текущий список:');
  writeln('---------------');
  current := head;
  i := 0;
  while current <> nil do
  begin
    writeln('[', i, '] ', current^.login, ' <---> ', current^.password);
    current := current^.next;
    i := i + 1;
  end;
  writeln('---------------');
  writeln('Всего элементов: ', i);
  writeln;
  
  //запрашиваем индекс для разделения
  write('Введите индекс для разделения (0 - ', i - 2, '): ');
  writeln('(список разделится перед элементом с этим индексом)');
  write('Индекс: ');
  readln(index);
  
  //проверяем корректность индекса
  if (index < 0) or (index >= i) then
  begin
    writeln('Индекс должен быть от 0 до ', i - 1, '.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //если index = 0, то весь первый список останется первым
  //второй список будет содержать все элементы
  if index = 0 then
  begin
    head2 := head;
    tail2 := tail;
    head := nil;
    tail := nil;
    is_created2 := true;
    
    writeln;
    writeln('Список успешно разделён:');
    writeln('Первый список: пуст');
    writeln('Второй список: содержит все ', i, ' элементов');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  //находим элемент, перед которым будем разделять
  current := head;
  i := 0;
  while (current <> nil) and (i < index) do
  begin
    current := current^.next;
    i := i + 1;
  end;
  
  if current = nil then
  begin
    writeln('Невозможно найти элемент с индексом ', index, '.');
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
   
  //устанавливаем второй список
  head2 := current;
  tail2 := tail;
  
  //обрезаем первый список
  tail := current^.prev;
  if tail <> nil then
    tail^.next := nil;
  
  //настраиваем связи для второго списка
  if head2 <> nil then
    head2^.prev := nil;
  
  //если разделили так, что первый список стал пустым
  if head = current then
    head := nil;
  
  //обновляем tail первого списка, если нужно
  if tail = nil then
    head := nil;
  
  is_created2 := true;
  
  //подсчитываем количество элементов в каждом списке
  var count1, count2: integer;
  current := head;
  count1 := 0;
  while current <> nil do
  begin
    count1 := count1 + 1;
    current := current^.next;
  end;
  
  current := head2;
  count2 := 0;
  while current <> nil do
  begin
    count2 := count2 + 1;
    current := current^.next;
  end;
  
  //показываем результат
  writeln();
  writeln('Список успешно разделён!');
  writeln('Первый список: ', count1, ' элементов');
  writeln('Второй список: ', count2, ' элементов');
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey;
end;

procedure ShowSecondList(var head2, tail2: PNode; var is_created2: boolean);
var
  current: PNode;
  i: integer;
begin
  clrscr();
  writeln('     Второй список     ');
  writeln('-----------------------');
  
  if not is_created2 then
  begin
    writeln('Второй список не создан.');
  end
  else if head2 = nil then
  begin
    writeln('Второй список пуст.');
  end
  else
  begin
    current := head2;
    i := 0;
    writeln('Содержимое второго списка:');
    writeln('--------------------------');
    while current <> nil do
    begin
      writeln('[', i, '] Логин: ', current^.login, ', Пароль: ', current^.password);
      current := current^.next;
      inc(i);
    end;
    writeln('--------------------------');
    writeln('Всего элементов: ', i);
  end;
  
  writeln;
  writeln('Нажмите любую клавишу...');
  readkey;
end;

//отображение меню
procedure menu(var choice: integer);
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
  writeln('15. Вывод элементов второго списка');

  if choice = 16 then write('> ') else write('  ');
  writeln('16. Выход');
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
  paragraphs := 16;

  repeat
    menu(choice);
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
            1: CreateStructure(head, tail, is_created); //создать структуру
            2: AddToEnd(head, tail, is_created); //добавить элемент в конец
            3: AddBeforeIndex(head, tail, is_created); //добавить элемент в перед индексом
            4: DeleteByIndex(head, tail, is_created); //удалить по индексу
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
                   writeln('Количество записей: ', AmountOfElements(head, tail, is_created));
                   writeln('Нажмите любую клавишу...');
                   readkey;
                 end;
               end;
            7: ReadElem(head, tail, is_created); //вывести элементы списка
            8: FindByLogin(head, tail, is_created); //найти по логину
            9: FindByPassword(head, tail, is_created); //найти по паролю
            10: FindElementByIndex(head, tail, is_created); //найти по индексу
            11: ReplaceElementByIndex(head, tail, is_created); //заменить по индексу
            12: DeleteStructure(head, tail, is_created); //удалить структуру
            13: SplitList(head, head2, tail, tail2, is_created, is_created2); //разделить списки
            14: GetListsTogether(head, head2, tail, tail2, is_created, is_created2); //соединить списки
            15: ShowSecondList(head2, tail2, is_created2); //показать второй список
            16: exitFlag := True;
          end;
        end;
      #27:  //ESC
        exitFlag := True;
    end;

  until exitFlag;

  //финальная очистка
  DeleteStructureSilent(head, tail, is_created);

  clrscr;
  writeln('Программа завершена.');
  writeln('Нажмите любую клавишу для выхода...');
  readkey;
end.
