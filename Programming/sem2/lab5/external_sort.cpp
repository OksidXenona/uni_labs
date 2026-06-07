#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <queue>
#include <algorithm>
#include <cstdio>
#include <chrono>

struct Record {
    std::string date;
    std::string city;
    std::string performer;
};

int choose_key(const std::string& key) {
    if (key == "дата") return 0;
    if (key == "город") return 1;
    if (key == "артист") return 2;

    return 0;
}

const int section_size = 500000;

int current_key_index = 0;

std::vector<std::string> split_file(const std::string& input_file, int key_index) {

    std::ifstream file(input_file);
    std::string line;

    std::vector<Record> section;
    std::vector<std::string> temp_files;

    int f_count = 0;

    // пропускаем заголовок
    std::getline(file, line);

    while (std::getline(file, line)) {

        std::stringstream ss(line);

        Record r;

        std::getline(ss, r.date, ',');
        std::getline(ss, r.city, ',');
        std::getline(ss, r.performer, ',');

        section.push_back(r);

        if (section.size() >= section_size) {

            std::sort(
                section.begin(),
                section.end(),
                [key_index](const Record& a, const Record& b) {

                    if (key_index == 0) return a.date < b.date;
                    if (key_index == 1) return a.city < b.city;

                    return a.performer < b.performer;
                }
            );

            std::string filename =
                "temp_" + std::to_string(f_count++) + ".txt";

            std::ofstream out(filename);

            for (const Record& r : section) {
                out << r.date << ","
                    << r.city << ","
                    << r.performer << "\n";
            }

            temp_files.push_back(filename);

            section.clear();
        }
    }

    // если остались строки
    if (!section.empty()) {

        std::sort(
            section.begin(),
            section.end(),
            [key_index](const Record& a, const Record& b) {

                if (key_index == 0) return a.date < b.date;
                if (key_index == 1) return a.city < b.city;

                return a.performer < b.performer;
            }
        );

        std::string filename =
            "temp_" + std::to_string(f_count++) + ".txt";

        std::ofstream out(filename);

        for (const Record& r : section) {
            out << r.date << ","
                << r.city << ","
                << r.performer << "\n";
        }

        temp_files.push_back(filename);
    }

    return temp_files;
}

struct Node {
    Record record;
    int file_index;
};

struct Compare {

    bool operator()(const Node& a, const Node& b) const {

        if (current_key_index == 0)
            return a.record.date > b.record.date;

        if (current_key_index == 1)
            return a.record.city > b.record.city;

        return a.record.performer > b.record.performer;
    }
};

void merge_files(const std::vector<std::string>& files,
                 const std::string& output_file,
                 int key_index) {

    current_key_index = key_index;

    std::vector<std::ifstream> streams;

    std::priority_queue<
        Node,
        std::vector<Node>,
        Compare
    > pq;

    std::ofstream out(output_file);

    // открываем все временные файлы
    for (const std::string& f : files) {
        streams.emplace_back(f);
    }

    std::string line;

    // читаем первую строку каждого файла
    for (int i = 0; i < streams.size(); i++) {

        if (std::getline(streams[i], line)) {

            std::stringstream ss(line);

            Record r;

            std::getline(ss, r.date, ',');
            std::getline(ss, r.city, ',');
            std::getline(ss, r.performer, ',');

            pq.push({r, i});
        }
    }

    while (!pq.empty()) {

        Node cur = pq.top();
        pq.pop();

        out << cur.record.date << ","
            << cur.record.city << ","
            << cur.record.performer << "\n";

        if (std::getline(streams[cur.file_index], line)) {

            std::stringstream ss(line);

            Record r;

            std::getline(ss, r.date, ',');
            std::getline(ss, r.city, ',');
            std::getline(ss, r.performer, ',');

            pq.push({r, cur.file_index});
        }
    }

    // закрываем файлы
    for (auto& stream : streams) {
        stream.close();
    }

    // удаляем временные файлы
    for (const std::string& f : files) {
        std::remove(f.c_str());
    }
}

int main() {

    std::string key;

    std::cout << "Введите ключ сортировки (дата/город/артист): ";
    std::cin >> key;

    int key_index = choose_key(key);

    auto total_start = std::chrono::high_resolution_clock::now();

    auto split_start = std::chrono::high_resolution_clock::now();
    std::vector<std::string> temp_files = split_file("data.csv", key_index);
    auto split_end = std::chrono::high_resolution_clock::now();

    double split_time = std::chrono::duration<double>(split_end - split_start).count();
    std::cout << "Split time: " << split_time << " sec\n";

    auto merge_start = std::chrono::high_resolution_clock::now();
    merge_files(temp_files, "sorted.txt", key_index);
    auto merge_end = std::chrono::high_resolution_clock::now();

    double merge_time = std::chrono::duration<double>(merge_end - merge_start).count();
    std::cout << "Merge time: " << merge_time << " sec\n";

    auto total_end = std::chrono::high_resolution_clock::now();
    double total_time = std::chrono::duration<double>(total_end - total_start).count();
    std::cout << "Total time: " << total_time << " sec\n";

    std::cout << "Сортировка завершена.\n";

    return 0;
}
