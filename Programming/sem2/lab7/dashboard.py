import tkinter as tk
from tkinter import ttk, messagebox
import csv
import subprocess
import time
import File_Generator
import external_sort
import threading
import os

def clear_table():
    for item in tree.get_children():
        tree.delete(item)

def load_file(filename):
    clear_table()
    try:
        with open(filename, "r", encoding="utf-8") as f:
            reader = csv.reader(f)

            # читаем заголовок
            headers = next(reader)
            tree["columns"] = headers
            tree["show"] = "headings"

            for col in headers:
                tree.heading(col, text=col)
                tree.column(col, width=150)

            # читаем только первые 100 строк для проверки
            for i, row in enumerate(reader):
                tree.insert("", "end", values=row)
                if i >= 100:
                    break

    except Exception as e:
        messagebox.showerror("Ошибка", str(e))

def generate():
    def task():
        set_status("Генерация data.csv (1 ГБ)... Это займет время.")
        start = time.time()

        File_Generator.generate_data("data.csv", size=1)

        load_file("data.csv")
        end = time.time()
        set_status(f"Готово | генерация за {round(end - start, 2)} сек")

    threading.Thread(target=task, args=()).start()

def sort_python():
    def task():
        set_status("Python: сортировка...")
        start = time.time()

        stats = external_sort.external_sort("data.csv", "sorted_py.csv", combo.get())

        load_file("sorted_py.csv")

        end = time.time()
        set_status(
            f"Python готово | split: {round(stats['split'], 2)}s | "
            f"merge: {round(stats['merge'], 2)}s | total: {round(stats['total'], 2)}s"
        )

    threading.Thread(target=task, args=()).start()

def sort_cpp():
    def task():
        set_status("C++: сортировка...")
        start = time.time()

        exe_name = "sort_cpp.exe" if os.name == "nt" else "./sort_cpp"

        process = subprocess.run(
            [exe_name],
            input=combo.get() + "\n",
            text=True,
            capture_output=True,
            encoding="utf-8"
        )

        load_file("sorted.txt")

        end = time.time()
        set_status(f"C++ готово за {round(end - start, 2)} сек. Результат в sorted.txt")

    threading.Thread(target=task, args=()).start()

window = tk.Tk()
window.title("Лабораторная 5.1: Внешняя сортировка")
window.geometry("900x600")

# Выбор ключа
tk.Label(window, text="Ключ сортировки:", font=("Arial", 10, "bold")).pack(pady=5)
combo = ttk.Combobox(
    window,
    values=["дата", "город", "артист"],
    width=20,
    state="readonly"
)
combo.current(0)
combo.pack(pady=5)

# Кнопки управления
frame_buttons = tk.Frame(window)
frame_buttons.pack(pady=10)

tk.Button(frame_buttons, text="1. Сгенерировать data.csv", command=generate, width=25, bg="#e0e0e0").grid(row=0, column=0, padx=5, pady=5)
tk.Button(frame_buttons, text="2. Сортировать (Python)", command=sort_python, width=25, bg="#d4edda").grid(row=0, column=1, padx=5, pady=5)
tk.Button(frame_buttons, text="3. Сортировать (C++)", command=sort_cpp, width=25, bg="#d1ecf1").grid(row=0, column=2, padx=5, pady=5)

# Таблица для просмотра
frame_table = tk.Frame(window)
frame_table.pack(fill="both", expand=True, padx=10, pady=5)

scroll_x = tk.Scrollbar(frame_table, orient="horizontal")
scroll_y = tk.Scrollbar(frame_table)

tree = ttk.Treeview(frame_table, yscrollcommand=scroll_y.set, xscrollcommand=scroll_x.set)

scroll_y.config(command=tree.yview)
scroll_x.config(command=tree.xview)

scroll_y.pack(side="right", fill="y")
scroll_x.pack(side="bottom", fill="x")
tree.pack(fill="both", expand=True)

# Статус бар
status = tk.Label(window, text="Готово к работе", bd=1, relief=tk.SUNKEN, anchor="w", font=("Arial", 9))
status.pack(side="bottom", fill="x")

def set_status(text):
    # after(0, ...) гарантирует обновление GUI из другого потока
    window.after(0, lambda: status.config(text=text))

if __name__ == "__main__":
    window.mainloop()
