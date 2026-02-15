unit unit_Simpson_Method;

interface
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
  
  procedure DeleteStructureSilent(var head, tail: PNode; var is_created: boolean);
  procedure CreateStructure(var head, tail: PNode; var is_created: boolean);
  procedure DeleteStructure(var head, tail: PNode; var is_created: boolean);
  procedure AddToEnd(var head, tail: PNode; var is_created: boolean);
  procedure ReadElem(var head, tail: PNode; var is_created: boolean);
  function AmountOfElements(var head, tail: PNode; var is_created: boolean): integer;
  procedure FindByLogin(var head, tail: PNode; var is_created: boolean);
  procedure FindByPassword(var head, tail: PNode; var is_created: boolean);
  procedure FindElementByIndex(var head, tail: PNode; var is_created: boolean);
  procedure ReplaceElementByIndex(var head, tail: PNode; var is_created: boolean);
  procedure AddBeforeIndex(var head, tail: PNode; var is_created: boolean);
  procedure DeleteByIndex(var head, tail: PNode; var is_created: boolean);
  procedure SplitList(var head, head2, tail, tail2: PNode; var is_created, is_created2: boolean);
  procedure GetListsTogether(var head, head2, tail, tail2: PNode; var is_created, is_created2: boolean);
  procedure ShowSecondList(var head2, tail2: PNode; var is_created2: boolean);
  
  
implementation

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
  
  if head <> nil then
  begin
    writeln('Структура уже существует и содержит данные.');
    writeln('Удалить текущую структуру перед созданием новой? (Y/N)');
    writeln;
    
    confirm := readkey;

    if (confirm = 'y') or (confirm = 'Y') or (confirm = 'н') or (confirm = 'Н') then
    begin
      DeleteStructureSilent(head, tail, is_created);
      is_created := true;
      writeln;
    end
    else
    begin
      writeln;
      writeln('Создание отменено. Текущая структура сохранена.');
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
    writeln('Структура не создана. Удалять нечего.');
  end;

  DeleteStructureSilent(head, tail, is_created);
  writeln('Структура удалена.');

end;

//добавление элемента в конец
procedure AddToEnd(var head, tail: PNode; var is_created: boolean);
var
  newNode: PNode;
begin
  if not is_created then
  begin
    clrscr;
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

end;
  
//показать все элементы списка
procedure ReadElem(var head, tail: PNode; var is_created: boolean);
var 
  current: PNode;
begin
  if not is_created then
  begin
    clrscr;
    writeln('Cтруктура не создана.');

  end;

  if head = nil then
  begin
    writeln('Список пуст.');

  end;

  current := head;
  while current <> nil do
  begin
    writeln(current^.login, ' <---> ', current^.password);
    current := current^.next;
  end;

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
    writeln('Элемент с логином ", target, " не найден.');
  
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

//найти элемент по индексу
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

//заменить элемент по индексу
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

//добавить элемент перед индексом
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

//удалить элемент по индексу
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

//разделить списки
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

//соединить списки
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
  count1 := AmountOfElements(head, tail, is_created);
  writeln('Всего элементов: ', count1);
  writeln;
  
  count2 := AmountOfElements(head2, tail2, is_created2);
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

//показать второй список
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
      i := i + 1;
    end;
    writeln('--------------------------');
    writeln('Всего элементов: ', i);
  end;
  
  writeln;
  writeln('Нажмите любую клавишу...');
  readkey;
end;

begin
  
end.