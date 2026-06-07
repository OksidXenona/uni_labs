import csv
import time
import heapq
import os


def choose_key(key_name):
    hat = {
        "дата": 0,
        "город": 1,
        "артист": 2
    }
    return hat[key_name]


max_section_size = 500_000


def split_file(input_file, key_index):
    temp_files = []
    start_time = time.time()

    with open(input_file, newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader)

        section = []
        file_count = 0

        for row in reader:
            section.append(row)

            if len(section) >= max_section_size:
                section.sort(key=lambda x: x[key_index])

                filename = f"temp_{file_count}.csv"
                with open(filename, 'w', newline='', encoding='utf-8') as temp_f:
                    writer = csv.writer(temp_f)
                    writer.writerows(section)

                temp_files.append(filename)
                section = []
                file_count += 1

        if section:
            section.sort(key=lambda x: x[key_index])
            filename = f"temp_{file_count}.csv"

            with open(filename, 'w', newline='', encoding='utf-8') as temp_f:
                writer = csv.writer(temp_f)
                writer.writerows(section)

            temp_files.append(filename)

    split_time = time.time() - start_time
    return temp_files, header, split_time


def merge_files(temp_files, output_file, key_index, header):
    start_time = time.time()

    files = [open(f, newline='', encoding='utf-8') for f in temp_files]
    readers = [csv.reader(f) for f in files]

    heap = []

    for i, reader in enumerate(readers):
        row = next(reader, None)
        if row:
            heapq.heappush(heap, (row[key_index], i, row))

    with open(output_file, 'w', newline='', encoding='utf-8') as res:
        writer = csv.writer(res)
        writer.writerow(header)

        while heap:
            _, i, row = heapq.heappop(heap)
            writer.writerow(row)

            next_row = next(readers[i], None)
            if next_row:
                heapq.heappush(heap, (next_row[key_index], i, next_row))

    for f in files:
        f.close()

    for f in temp_files:
        os.remove(f)

    merge_time = time.time() - start_time
    return merge_time


def external_sort(input_file, output_file, key_name):
    key_index = choose_key(key_name)

    total_start = time.time()

    temp_files, header, split_time = split_file(input_file, key_index)
    merge_time = merge_files(temp_files, output_file, key_index, header)

    total_time = time.time() - total_start

    return {
        "split": split_time,
        "merge": merge_time,
        "total": total_time
    }
