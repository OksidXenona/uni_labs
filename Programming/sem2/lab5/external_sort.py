import csv
import time # для отслеживания времени

def choose_key(key_name):
    hat = {
        "дата": 0,
        "город": 1,
        "артист": 2
    }
    return hat[key_name]

max_section_size = 100_000 # держим в памяти

def split_file(input_file, key_index):
    temp_files = [] # список временных файлов
    start_time = time.time() # запоминаем текущее время

    with open(input_file, newline='', encoding='utf-8-sig') as f:
        reader = csv.reader(f) # итератор по строкам файла
        header = next(reader) # читает заголовок

        section = []
        file_count = 0

        for row in reader:
            section.append(row)

            if len(section) >= max_section_size:
                section.sort(key=lambda x: x[key_index]) # сортируем по полю (выбор пользователя)

                filename = f"temp_{file_count}.csv"
                with open(filename, 'w', newline ='', encoding='utf-8-sig') as temp_f:
                    writer = csv.writer(temp_f)
                    writer.writerows(section)

                temp_files.append(filename)
                section = []
                file_count += 1

        # оставшиеся данные
        if section:
            section.sort(key=lambda x: x[key_index])
            filename = f"temp_{file_count}.csv"

            with open(filename, 'w', newline='', encoding='utf-8-sig') as temp_f:
                writer = csv.writer(temp_f)
                writer.writerows(section)

            temp_files.append(filename)

        print("Split time:", time.time() - start_time)
        return temp_files, header
