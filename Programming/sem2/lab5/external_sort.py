import csv
import time # для отслеживания времени

import heapq # куча для сортировки
import os # для работы с файлами

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

# функция сортировки
def merge_files(temp_files, output_file, key_index, header):
    start_time = time.time()

    files = [open(f, newline='', encoding='utf-8-sig') for f in temp_files]
    readers = [csv.reader(f) for f in files]

    heap = []

    for i, reader in enumerate(readers):
        row = next(reader, None)
        if row:
            heapq.heappush(heap, (row[key_index], i, row)) # кладем в кучу кортеж

    with open(output_file, 'w', newline='', encoding='utf-8-sig') as res:
        writer = csv.writer(res)
        writer.writerow(header) # записываем заголовок

        while heap:
            _, i, row = heapq.heappop(heap) # ключ, файл (i), строка (row)
            writer.writerow(row)

            next_row = next(readers[i], None)
            if next_row:
                heapq.heappush(heap, (next_row[key_index], i, next_row)) # если строка есть - кладем в кучу

    for f in files:
        f.close()

    for f in temp_files:
        os.remove(f)

    print("Merge time:", time.time() - start_time)

def external_sort(input_file, output_file, key_name):
    key_index = choose_key(key_name)

    temp_files, header = split_file(input_file, key_index)
    merge_files(temp_files, output_file, key_index, header)

external_sort("data.csv", "sorted.csv", "дата")
