Program lab3;

uses
  crt; 
var
  choice, n, paragraphs: integer;
    a, b, res, error, exact_value: double;
  exitFlag: boolean;
  key: char;
  // Флаги для отслеживания состояния расчетов
  limits_set: boolean;      // установлены ли пределы
  n_set: boolean;          // установлено ли число разбиений
  integral_calculated: boolean; // рассчитан ли интеграл
  error_calculated: boolean;    // рассчитана ли погрешность

const
  root = -2.1875;

//Функция
function f(x: double): double; //Задаём функцию
begin
  f := 2 * x * x * x - 5 * x + 10;
end;

//Функция, возвращающая только положительные значения
function f_positive(x: double): double;
var
  val: double;
begin
  val := f(x); 
  if val > 0 then
    f_positive := val
  else
    f_positive := 0;
end;

//Первообразная
function Antiderivative(x: double): double;
begin
  Antiderivative := 0.5 * x * x * x * x - 2.5 * x * x + 10 * x;
end;

//Значение интеграла по формуле Ньютона-Лейбница
function ExactIntegral(a, b: double): double;
begin
  ExactIntegral := Antiderivative(b) - Antiderivative(a);
end;

function Simpson(a, b: double; n: integer): double; //реализуем метод Симпсона
var 
  h, sum: double;
  i: integer;
begin
  if n mod 2 <> 0 then n := n + 1; //Нам нужно чётное число разбиений
  
  h := (b - a) / n; //Считаем шаг
  sum := f_positive(a) + f_positive(b); //Считаем сумму первого и последнего y
  
  for i := 1 to n - 1 do //считаем суммы элементов, исходя из формулы
  begin
    if i mod 2 = 0 then
      sum := sum + 2 * f_positive(a + i*h) //сумму четных y умножаем на 2
    else
      sum := sum + 4 * f_positive(a + i*h) //сумму нечетных y умножаем на 4
  end;
  
  Simpson := sum * h / 3;
end;

// Сброс флагов расчетов при изменении параметров
procedure reset_calculation_flags;
begin
  integral_calculated := false;
  error_calculated := false;
end;

//Ввод пределов интегрирования с меню на стрелках
procedure limits(var a, b: double);
var
  sub_choice, sub_paragraphs: integer;
  exit_submenu: boolean;
  temp: double;
  key: char;
  input_str: string;
  code: integer;
  temp_a, temp_b: double;
  a_entered, b_entered: boolean;
begin
  exit_submenu := false;
  sub_choice := 1;
  sub_paragraphs := 4; // Количество пунктов подменю
  
  // Используем временные переменные для хранения введенных значений
  temp_a := a;
  temp_b := b;
  a_entered := limits_set;
  b_entered := limits_set;
  
  repeat
    clrscr();
    writeln('========================================');
    writeln('Настройка пределов интегрирования');
    writeln('========================================');
    writeln();
    writeln('Корень уравнения f(x) = 0: ', root:0:6);
    writeln();
    writeln('Текущие значения:');
    if a_entered then
      writeln('  Нижний предел (a) = ', temp_a:0:6)
    else
      writeln('  Нижний предел (a) = не установлен');
    
    if b_entered then
      writeln('  Верхний предел (b) = ', temp_b:0:6)
    else
      writeln('  Верхний предел (b) = не установлен');
    
    writeln();
    writeln('----------------------------------------');
    writeln('Выберите действие:');
    writeln();
    
    // Пункт 1
    if sub_choice = 1 then write('> ') else write('  ');
    writeln('1. Изменить нижний предел (a)');
    
    // Пункт 2
    if sub_choice = 2 then write('> ') else write('  ');
    writeln('2. Изменить верхний предел (b)');
    
    // Пункт 3
    if sub_choice = 3 then write('> ') else write('  ');
    writeln('3. Изменить оба предела');
    
    // Пункт 4
    if sub_choice = 4 then write('> ') else write('  ');
    writeln('4. Применить изменения и выйти');
    
    writeln();
    writeln('----------------------------------------');
    writeln('Управление: W/↑ - вверх, S/↓ - вниз');
    writeln('Enter - выбор, ESC - выход без сохранения');
    writeln('----------------------------------------');
    
    key := readkey;
    
    case key of
      'w', 'W', 'ц', 'Ц', #38:  // Вверх (стрелка вверх)
        begin
          sub_choice := sub_choice - 1;
          if sub_choice < 1 then sub_choice := sub_paragraphs;
        end;
      's', 'S', 'ы', 'Ы', #40:  // Вниз (стрелка вниз)
        begin
          sub_choice := sub_choice + 1;
          if sub_choice > sub_paragraphs then sub_choice := 1;
        end;
      #13:  // Enter
        begin
          case sub_choice of
            1: // Изменить только a
              begin
                clrscr();
                writeln('========================================');
                writeln('Изменение нижнего предела (a)');
                writeln('========================================');
                writeln();
                writeln('Корень уравнения: ', root:0:6);
                if a_entered then
                  writeln('Текущее значение: a = ', temp_a:0:6)
                else
                  writeln('Текущее значение: a = не установлен');
                
                if b_entered then
                  writeln('Верхний предел: b = ', temp_b:0:6)
                else
                  writeln('Верхний предел: b = не установлен');
                
                writeln();
                writeln('Введите новое значение a:');
                write('> ');
                
                readln(input_str);
                if input_str <> '' then
                begin
                  val(input_str, temp, code);
                  if code = 0 then
                  begin
                    if (not b_entered) or (temp < temp_b) then
                    begin
                      temp_a := temp;
                      a_entered := true;
                      writeln();
                      writeln('Нижний предел установлен: a = ', temp_a:0:6);
                    end
                    else
                    begin
                      writeln();
                      writeln('Ошибка! a должен быть меньше b');
                    end;
                  end
                  else
                  begin
                    writeln();
                    writeln('Ошибка! Введите корректное число.');
                  end;
                end
                else
                begin
                  writeln();
                  writeln('Значение не изменено.');
                end;
                
                writeln();
                writeln('Нажмите любую клавишу для продолжения...');
                readkey;
              end;
              
            2: // Изменить только b
              begin
                clrscr();
                writeln('========================================');
                writeln('Изменение верхнего предела (b)');
                writeln('========================================');
                writeln();
                writeln('Корень уравнения: ', root:0:6);
                if a_entered then
                  writeln('Нижний предел: a = ', temp_a:0:6)
                else
                  writeln('Нижний предел: a = не установлен');
                
                if b_entered then
                  writeln('Текущее значение: b = ', temp_b:0:6)
                else
                  writeln('Текущее значение: b = не установлен');
                
                writeln();
                writeln('Введите новое значение b:');
                write('> ');
                
                readln(input_str);
                if input_str <> '' then
                begin
                  Val(input_str, temp, code);
                  if code = 0 then
                  begin
                    if (not a_entered) or (temp > temp_a) then
                    begin
                      temp_b := temp;
                      b_entered := true;
                      writeln();
                      writeln('Верхний предел установлен: b = ', temp_b:0:6);
                    end
                    else
                    begin
                      writeln();
                      writeln('Ошибка! b должен быть больше a');
                    end;
                  end
                  else
                  begin
                    writeln();
                    writeln('Ошибка! Введите корректное число.');
                  end;
                end
                else
                begin
                  writeln();
                  writeln('Значение не изменено.');
                end;
                
                writeln();
                writeln('Нажмите любую клавишу для продолжения...');
                readkey;
              end;
              
            3: // Изменить оба предела
              begin
                clrscr();
                writeln('========================================');
                writeln('Изменение обоих пределов');
                writeln('========================================');
                writeln();
                writeln('Корень уравнения: ', root:0:6);
                writeln('Текущие значения:');
                if a_entered then
                  writeln('a = ', temp_a:0:6)
                else
                  writeln('a = не установлен');
                
                if b_entered then
                  writeln('b = ', temp_b:0:6)
                else
                  writeln('b = не установлен');
                
                writeln();
                
                // Ввод a
                repeat
                  write('Введите нижний предел a: ');
                  readln(input_str);
                  
                  if input_str = '' then
                  begin
                    if a_entered then
                    begin
                      writeln('Значение a не изменено.');
                      Break;
                    end
                    else
                    begin
                      writeln('Ошибка! Нижний предел должен быть установлен.');
                      continue;
                    end;
                  end;
                    
                  Val(input_str, temp, code);
                  
                  if code <> 0 then
                  begin
                    writeln('Ошибка! Введите число.');
                  end
                  else
                  begin
                    temp_a := temp;
                    a_entered := true;
                    Break;
                  end;
                until false;
                
                // Ввод b
                repeat
                  writeln();
                  write('Введите верхний предел b (должен быть > ', temp_a:0:6, '): ');
                  readln(input_str);
                  
                  if input_str = '' then
                  begin
                    if b_entered then
                    begin
                      writeln('Значение b не изменено.');
                      Break;
                    end
                    else
                    begin
                      writeln('Ошибка! Верхний предел должен быть установлен.');
                      continue;
                    end;
                  end;
                    
                  Val(input_str, temp, code);
                  
                  if code <> 0 then
                  begin
                    writeln('Ошибка! Введите число.');
                  end
                  else if temp <= temp_a then
                  begin
                    writeln('Ошибка! b должен быть больше a.');
                  end
                  else
                  begin
                    temp_b := temp;
                    b_entered := true;
                    writeln();
                    writeln('Пределы установлены:');
                    writeln('a = ', temp_a:0:6);
                    writeln('b = ', temp_b:0:6);
                    Break;
                  end;
                until false;
                
                writeln();
                writeln('Нажмите любую клавишу для продолжения...');
                readkey;
              end;
              
            4: // Применить изменения и выйти
              begin
                if a_entered and b_entered then
                begin
                  a := temp_a;
                  b := temp_b;
                  limits_set := true;
                  reset_calculation_flags; // Сбрасываем флаги расчетов
                  exit_submenu := true;
                end
                else
                begin
                  writeln();
                  writeln('Ошибка! Оба предела должны быть установлены.');
                  writeln('Нажмите любую клавишу для продолжения...');
                  readkey;
                end;
              end;
          end;
        end;
      #27:  // ESC - выход без сохранения
        exit_submenu := true;
    end;
  until exit_submenu;
end;

//Ввод количества разбиений
procedure cuts(var n: integer);
var
  input_str: string;
  code: integer;
begin
  clrscr();
  writeln('========================================');
  writeln('Количество разбиений');
  writeln('========================================');
  writeln();
  
  repeat
    write('Введите чётное количество разбиений n >= 2: ');
    readln(input_str);
    
    if input_str = '' then
    begin
      if n_set then
      begin
        writeln('Значение не изменено.');
        Break;
      end
      else
      begin
        writeln('Ошибка! Число разбиений должно быть установлено.');
        continue;
      end;
    end;
    
    val(input_str, n, code);
    
    if code <> 0 then
      writeln('Ошибка! Введите целое число.')
    else if n < 2 then
      writeln('Ошибка! Количество разбиений должно быть не менее 2!')
    else
    begin
      if n mod 2 <> 0 then
        n := n + 1;
      n_set := true;
      reset_calculation_flags; // Сбрасываем флаги расчетов
      writeln();
      writeln('Число разбиений установлено: n = ', n);
      writeln('Флаги расчетов сброшены.');
      Break;
    end;
  until false;
  
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey;
end;

//Расчет интеграла
procedure calculate_integral;
begin
  if not limits_set then
  begin
    clrscr();
    writeln('========================================');
    writeln('Ошибка расчета!');
    writeln('========================================');
    writeln();
    writeln('Для расчета интеграла необходимо сначала');
    writeln('установить пределы интегрирования!');
    writeln();
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  if not n_set then
  begin
    clrscr();
    writeln('========================================');
    writeln('Ошибка расчета!');
    writeln('========================================');
    writeln();
    writeln('Для расчета интеграла необходимо сначала');
    writeln('установить число разбиений!');
    writeln();
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  res := Simpson(a, b, n);
  exact_value := ExactIntegral(a, b);
  
  integral_calculated := true;
  error_calculated := false; // При новом расчете интеграла погрешность устаревает
  
  clrscr();
  writeln('========================================');
  writeln('Интеграл рассчитан.');
  writeln('========================================');
  writeln();
  writeln('Функция: y = 2x^3 - 5x + 10');
  writeln('Нижний предел a = ', a:0:6);
  writeln('Верхний предел b = ', b:0:6);
  writeln('Корень уравнения: ', root:0:6);
  writeln('Число разбиений n = ', n);
  writeln('----------------------------------------');
  writeln('Площадь фигуры S ≈ ', res:0:6);
  writeln();
  writeln('Примечание: учитывается только область, где функция положительна.');
  writeln();
  writeln('Теперь можно рассчитать погрешность.');
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey;
end;

//Расчет погрешности
procedure calculate_error;
var
  abs_error, rel_error: double;
begin
  if not integral_calculated then
  begin
    clrscr();
    writeln('========================================');
    writeln('Ошибка расчета!');
    writeln('========================================');
    writeln();
    writeln('Для расчета погрешности необходимо сначала');
    writeln('рассчитать интеграл!');
    writeln();
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  abs_error := abs(exact_value - res);
  
  if exact_value <> 0 then
    rel_error := (abs_error / abs(exact_value)) * 100
  else
    rel_error := 0;
  
  error_calculated := true;
  
  clrscr();
  writeln('========================================');
  writeln('Погрешность рассчитана.');
  writeln('========================================');
  writeln();
  writeln('Функция: y = 2x^3 - 5x + 10');
  writeln('Нижний предел a = ', a:0:6);
  writeln('Верхний предел b = ', b:0:6);
  writeln('Корень уравнения: ', root:0:6);
  writeln('Число разбиений n = ', n);
  writeln('----------------------------------------');
  writeln('Площадь фигуры S ≈ ', res:0:6);
  writeln('----------------------------------------');
  writeln('Абсолютная погрешность: ', abs_error:0:6);
  writeln('Относительная погрешность: ', rel_error:0:2, ' %');
  writeln('----------------------------------------');
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey;
end;

//Вывод полных результатов
procedure output_results;
begin
  if not limits_set then
  begin
    clrscr();
    writeln('========================================');
    writeln('Ошибка вывода!');
    writeln('========================================');
    writeln();
    writeln('Для вывода результатов необходимо сначала');
    writeln('установить пределы интегрирования!');
    writeln();
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  if not n_set then
  begin
    clrscr();
    writeln('========================================');
    writeln('Ошибка вывода!');
    writeln('========================================');
    writeln();
    writeln('Для вывода результатов необходимо сначала');
    writeln('установить число разбиений!');
    writeln();
    writeln('Нажмите любую клавишу...');
    readkey;
    exit;
  end;
  
  if not integral_calculated then
  begin
    clrscr();
    writeln('========================================');
    writeln('Внимание!');
    writeln('========================================');
    writeln();
    writeln('Интеграл еще не рассчитан!');
    writeln('Рассчитать интеграл сейчас? (y/n)');
    
    key := readkey;
    if (key = 'y') or (key = 'Y') or (key = 'н') or (key = 'Н') then
    begin
      calculate_integral;
      if not integral_calculated then exit;
    end
    else
      exit;
  end;
  
  if not error_calculated then
  begin
    clrscr();
    writeln('========================================');
    writeln('Внимание!');
    writeln('========================================');
    writeln();
    writeln('Погрешность еще не рассчитана!');
    writeln('Рассчитать погрешность сейчас? (y/n)');
    
    key := readkey;
    if (key = 'y') or (key = 'Y') or (key = 'н') or (key = 'Н') then
      calculate_error
    else
    begin
      // Вывод без погрешности
      clrscr();
      writeln('========================================');
      writeln('Результаты вычислений.');
      writeln('========================================');
      writeln();
      writeln('Функция: y = 2x^3 - 5x + 10');
      writeln('Нижний предел a = ', a:0:6);
      writeln('Верхний предел b = ', b:0:6);
      writeln('Корень уравнения: ', root:0:6);
      writeln('Число разбиений n = ', n);
      writeln('----------------------------------------');
      writeln('Площадь фигуры S ≈ ', res:0:6);
      writeln('Погрешность: не рассчитана');
      writeln('========================================');
      writeln();
      writeln('Нажмите любую клавишу...');
      readkey;
      exit;
    end;
  end;
  
  // Вывод полных результатов
  clrscr();
  writeln('========================================');
  writeln('Результаты вычислений.');
  writeln('========================================');
  writeln();
  writeln('Функция: y = 2x^3 - 5x + 10');
  writeln('Нижний предел a = ', a:0:6);
  writeln('Верхний предел b = ', b:0:6);
  writeln('Корень уравнения: ', root:0:6);
  writeln('Число разбиений n = ', n);
  writeln('----------------------------------------');
  writeln('Площадь фигуры S ≈ ', res:0:6);
  writeln('Абсолютная погрешность: ', abs(exact_value - res):0:6);
  
  if exact_value <> 0 then
    writeln('Относительная погрешность: ', 
            (abs(exact_value - res) / abs(exact_value) * 100):0:2, ' %')
  else
    writeln('Относительная погрешность: 0 %');
  
  writeln('========================================');
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey;
end;

//Меню
procedure menu;
begin
  clrscr();
  writeln('Лабораторная работа №3.');
  writeln('Изучение базовых принципов организации процедур и функций.');
  writeln('----------------------------------------');
  writeln('y = 2x^3 - 5x + 10');
  writeln('Корень уравнения: ', root);
  writeln();
  writeln('Выберите действие:');
  writeln();
  
  if choice = 1 then write('> ') else write('  ');
  writeln('1. Ввести пределы интегрирования');
  
  if choice = 2 then write('> ') else write('  ');
  writeln('2. Задать число разбиений');
  
  if choice = 3 then write('> ') else write('  ');
  writeln('3. Рассчитать интеграл');
  
  if choice = 4 then write('> ') else write('  ');
  writeln('4. Рассчитать погрешность');
  
  if choice = 5 then write('> ') else write('  ');
  writeln('5. Показать все результаты');
  
  if choice = 6 then write('> ') else write('  ');
  writeln('6. Показать текущие данные');
  
  if choice = 7 then write('> ') else write('  ');
  writeln('7. Справка');
  
  if choice = 8 then write('> ') else write('  ');
  writeln('8. Выход');
  writeln();
  writeln('----------------------------------------');
  writeln('Статус:');
  if limits_set then writeln('Пределы установлены') else writeln('Пределы не установлены');
  if n_set then writeln('Число разбиений установлено') else writeln('Число разбиений не установлено');
  if integral_calculated then writeln('Интеграл рассчитан') else writeln('Интеграл не рассчитан');
  if error_calculated then writeln('Погрешность рассчитана') else writeln('Погрешность не рассчитана');
  writeln('----------------------------------------');
  writeln('Управление: W/↑ - вверх, S/↓ - вниз');
  writeln('Enter - выбор, ESC - выход');
  writeln('----------------------------------------');
end;

//Текущие значения
procedure current;
begin
  clrscr();
  writeln('========================================');
  writeln('Текущие данные.');
  writeln('========================================');
  writeln();
  writeln('Функция: y = 2x^3 - 5x + 10');
  writeln('Корень уравнения: ', root:0:6);
  writeln();
  
  if limits_set then
  begin      
    writeln('Исходные пределы:');
    writeln('  a = ', a:0:6);
    writeln('  b = ', b:0:6);
    writeln();
  end
  else
  begin
    writeln('Нижний предел интегрирования a: не установлен');
    writeln('Верхний предел интегрирования b: не установлен');
  end;
  
  writeln();
  if n_set then
    writeln('Число разбиений n: ', n)
  else
    writeln('Число разбиений n: не установлено');
    
  writeln();
  writeln('Статус расчетов:');
  if limits_set then writeln('Пределы установлены') else writeln('Пределы не установлены');
  if n_set then writeln('Число разбиений установлено') else writeln('Число разбиений не установлено');
  if integral_calculated then 
  begin
    writeln('Интеграл рассчитан');
    writeln('Значение интеграла: ', res:0:6);
  end
  else writeln('Интеграл не рассчитан');
  
  if error_calculated then 
  begin
    writeln('Погрешность рассчитана');
    writeln('Абсолютная погрешность: ', abs(exact_value - res):0:6);
    if exact_value <> 0 then
      writeln('Относительная погрешность: ', 
              (abs(exact_value - res) / abs(exact_value) * 100):0:2, ' %');
  end
  else writeln('Погрешность не рассчитана');
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey;
end;

//Справка
procedure help;
begin
  clrscr();
  writeln('========================================');
  writeln('Справка.');
  writeln('========================================');
  writeln();
  writeln('Порядок работы:');
  writeln('1. Введите пределы интегрирования. (1 пункт)');
  writeln('2. Введите количество разбиений (целое число, >= 2, чётное). (2 пункт)');
  writeln('3. Рассчитайте интеграл. (3 пункт)');
  writeln('4. Рассчитайте погрешность. (4 пункт)');
  writeln('5. Просмотрите все результаты. (5 пункт)');
  writeln();
  writeln('Особенности работы с корнем:');
  writeln('- Корень уравнения f(x) = 0: x = ', root:0:6);
  writeln('- Интеграл считается только для области, где f(x) > 0.');
  writeln('- При расчете автоматически обнуляются отрицательные значения функции.');
  writeln();
  writeln('Важно:');
  writeln('- При изменении пределов или числа разбиений');
  writeln('  предыдущие расчеты (интеграл и погрешность)');
  writeln('  становятся недействительными и требуют');
  writeln('  пересчета.');
  writeln('- Рассчитать погрешность можно только после');
  writeln('  расчета интеграла.');
  writeln();
  writeln('Нажмите любую клавишу...');
  readkey;
end;

begin
  exitFlag := False;
  a := 0; // будет перезаписано пользователем
  b := 0; // будет перезаписано пользователем
  n := 0; // будет перезаписано пользователем
  choice := 1;
  error := 0;
  res := 0;
  paragraphs := 8; //количество пунктов меню
  
  // Инициализация флагов
  limits_set := false;        // пределы не установлены
  n_set := false;            // число разбиений не установлено
  integral_calculated := false; // интеграл не рассчитан
  error_calculated := false;    // погрешность не рассчитана
  
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
            1: limits(a, b);
            2: cuts(n);
            3: calculate_integral;
            4: calculate_error;
            5: output_results;
            6: current;
            7: help;
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