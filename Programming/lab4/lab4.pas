Program lab4;

uses 
  crt;

type PNode = ^Node; //указатель на узел
  Node = record //структура  узла
    id: string[30]; //поле для айди
    val: integer; //поле для значения
    next: PNode; //ссылка на следующий узел
    prev: PNode; //ссылка на предыдущий узел
  end;

var
  head, tail: PNode;
  choice, n, paragraphs: integer;
  exitFlag: boolean;
  key: char;
  
 
procedure CreateStructure;
begin
  head := nil;
  tail := nil;
  writeln('Структура создана.')
end;

procedure DeleteStructure;
var 
  current, nextNode: PNode;
  
begin
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
end;

procedure AddToEnd;
var
  newNode: PNode;
begin
  new(newNode); //выделяем память под новый узел
  writeln('Введите ID: ');
  readln(newNode^.id);
  
  writeln('Введите значение: ');
  readln(newNode^.val);
  
  newNode^.next := nil;
  newNode^.prev := tail;
  
  if tail = nil then
    head := newNode //если список был пуст, то новый узел становится началом и концом
  else
    tail^.next := newNode; //иначе - ставим в конец
  
  tail := newNode;
  writeln('Элемент добавлен в конец списка.');
end;
  
procedure ReadElem;
var 
  current: PNode;

begin
  if head = nil then
  begin
    writeln('Список пуст.');
    exit;
  end;

  current := head;
  while current <> nil do
  begin
    writeln(current^.id, ' <---> ', current^.val);
    current := current^.next;
  end;
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
  writeln('2. Удаление структуры');
  
  if choice = 3 then write('> ') else write('  ');
  writeln('3. Запись элемента в структуру');
  
  if choice = 4 then write('> ') else write('  ');
  writeln('4. Чтение элемента из структуры');
  
  if choice = 5 then write('> ') else write('  ');
  writeln('5. Определение пустоты структуры');
  
  if choice = 6 then write('> ') else write('  ');
  writeln('6. Определение количества элементов в структуре');
  
  if choice = 7 then write('> ') else write('  ');
  writeln('7. Поиск элемента с заданным значением');
  
  if choice = 8 then write('> ') else write('  ');
  writeln('8. Выход');
  writeln();
  writeln('----------------------------------------');
  writeln('Управление: W/↑ - вверх, S/↓ - вниз');
  writeln('Enter - выбор, ESC - выход');
  writeln('----------------------------------------');
end;

begin
  exitFlag := False;
  choice := 1;
  paragraphs := 8; //количество пунктов меню
  
  repeat
    menu;
    key := readkey;
    
    //обработка клавиш
    case key of
      'w', 'W', 'ц', 'Ц', #38:  // Вверх
        begin
          choice := choice - 1;
          if choice < 1 then choice := paragraphs;
        end;
      's', 'S', 'ы', 'Ы', #40:  // Вниз
        begin
          choice := choice + 1;
          if choice > paragraphs then choice := 1;
        end;
      #13:  // Enter
        begin
          case choice of
            1: CreateStructure;
            2: DeleteStructure;
            3: AddToEnd;
            4: ReadElem;
            5: ;
            6: ;
            7: ;
            8: exitFlag := True;
          end;
        end;
      #27:  // ESC
        exitFlag := True;
    end;
    
  until exitFlag;
  
  clrscr;
  writeln('Программа завершена.');
  writeln('Нажмите любую клавишу для выхода...');
  readkey;
end.