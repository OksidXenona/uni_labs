;
  
  while current <> nil do
  begin
    nextNode := current^.next;
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
  DeleteStructureSilent;
  

  clrscr;
  writeln('Программа завершена.');
  writeln('Нажмите любую клавишу для выхода...');
  readkey;
end.
