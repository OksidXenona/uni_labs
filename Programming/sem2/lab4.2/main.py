from tkinter import *
from tkinter import ttk
from tkinter import messagebox
from ListFunction import DoublyLinkedList

dll = DoublyLinkedList()

root = Tk()
root.title('Lab_4.2 | Doubly Linked List')
root.geometry("900x650")
root.minsize(800, 600)

#Цветовая палитра
dark_bg = '#1E1E1E'
widget_bg = '#2D2D2D'
text_color = '#E0E0E0'
accent_color = '#00ADB5'
accent_hover = '#008C93'
border_color = '#3D3D3D'

root.configure(bg=dark_bg)

#Шрифты
usual_font = ('Segoe UI', 11)
title_font = ('Segoe UI', 18, 'bold')
btn_font = ('Segoe UI', 10, 'bold')

#Стили
style = ttk.Style()
style.theme_use('clam')

style.configure('enter.TEntry',
                font=usual_font,
                foreground=text_color,
                fieldbackground=widget_bg,
                bordercolor=accent_color,
                lightcolor=widget_bg,
                darkcolor=widget_bg,
                padding=8,
                insertcolor=accent_color)

style.configure('button.TButton',
                background=widget_bg,
                foreground=text_color,
                bordercolor=border_color,
                focuscolor=accent_color,
                font=btn_font,
                padding=10)

style.map('button.TButton',
          background=[('active', widget_bg), ('pressed', widget_bg)],
          foreground=[('active', accent_color), ('pressed', accent_color)],
          bordercolor=[('active', accent_color), ('pressed', accent_color)])

#Заголовок
header_frame = Frame(root, bg=dark_bg)
header_frame.pack(side=TOP, fill=X)

label_title = Label(
    header_frame,
    text="Двусвязный список",
    justify=CENTER,
    bg=dark_bg,
    fg=accent_color,
    pady=20,
    font=title_font
)
label_title.pack(side=TOP, fill=X)

#Разделительная линия под заголовком
separator = Frame(header_frame, bg=accent_color, height=2)
separator.pack(side=TOP, fill=X, padx=40)

#Область с элементами
list_container = Frame(root, bg=dark_bg)
list_container.pack(side=TOP, fill=BOTH, expand=True, padx=30, pady=20)

#Рамка вокруг списка
list_border = Frame(list_container, bg=border_color, padx=1, pady=1)
list_border.pack(side=TOP, fill=BOTH, expand=True)

canvas = Canvas(list_border, bg=dark_bg, highlightthickness=0)
scrollbar = ttk.Scrollbar(list_border, orient=VERTICAL, command=canvas.yview)

scrollbar_frame = Frame(canvas, bg=dark_bg)

canvas_window = canvas.create_window((0, 0), window=scrollbar_frame, anchor="n")
canvas.configure(yscrollcommand=scrollbar.set)

canvas.pack(side=LEFT, fill=BOTH, expand=True)
scrollbar.pack(side=RIGHT, fill=Y)

#Обновление области прокрутки
def on_frame_configure(event):
    canvas.configure(scrollregion=canvas.bbox("all"))
    canvas.itemconfig(canvas_window, width=event.width)

scrollbar_frame.bind("<Configure>", on_frame_configure)

cards_list = []

#Нижняя панель управления
bottom_frame = Frame(root, bg=widget_bg, pady=20)
bottom_frame.pack(side=BOTTOM, fill=X)

#Поля ввода
input_frame = Frame(bottom_frame, bg=widget_bg)
input_frame.pack(fill=X, padx=40, pady=(0, 20))

label_inputs = Label(
    input_frame,
    text="Управление данными:",
    bg=widget_bg,
    fg=text_color,
    font=usual_font
)
label_inputs.pack(anchor="w", pady=(0, 10))

entry_value = ttk.Entry(input_frame, style='enter.TEntry')
entry_value.pack(side=LEFT, fill=X, expand=True, padx=(0, 15))
entry_value.insert(0, "Значение элемента")

entry_index = ttk.Entry(input_frame, style='enter.TEntry', width=15)
entry_index.pack(side=LEFT, padx=0)
entry_index.insert(0, "Индекс")

#Счётчик
counter_label = Label(
    bottom_frame,
    text="Элементов: 0",
    bg=widget_bg,
    fg=accent_color,
    font=('Segoe UI', 12, 'bold'),
    pady=10
)
counter_label.pack(side=RIGHT, padx=40)

#Обновление счётчика
def update_counter():
    count = dll.get_length()
    counter_label.configure(text="Элементов: " + str(count))

#Обновление списка
def refresh_list_visuals():
    global cards_list

    for card in cards_list:
        card.destroy()

    cards_list = []

    data_list = dll.to_list()

    for item in data_list:
        card = create_card_widget(item)
        cards_list.append(card)

    for card in cards_list:
        card.pack(pady=5, anchor="center", fill=X, padx=40)
        card.pack_propagate(False)


#Создание карточки
def create_card_widget(text_content):
    card = Frame(scrollbar_frame, bg=border_color, width=600, height=60)
    card.pack_propagate(False)

    accent_strip = Frame(card, bg=accent_color, width=6)
    accent_strip.pack(side=LEFT, fill=Y)

    inner_frame = Frame(card, bg=widget_bg)
    inner_frame.pack(side=LEFT, fill=BOTH, expand=True)

    card_label = Label(
        inner_frame,
        text=text_content,
        bg=widget_bg,
        fg=text_color,
        font=usual_font,
        anchor=CENTER,
        pady=10
    )
    card_label.pack(fill=BOTH, expand=True)

    return card

#Подсказки в полях ввода
def on_focus_in_value(event):
    if entry_value.get() == "Значение элемента":
        entry_value.delete(0, END)
        entry_value.configure(foreground=text_color)


def on_focus_out_value(event):
    if entry_value.get() == "":
        entry_value.insert(0, "Значение элемента")
        entry_value.configure(foreground=text_color)


def on_focus_in_index(event):
    if entry_index.get() == "Индекс":
        entry_index.delete(0, END)
        entry_index.configure(foreground=text_color)


def on_focus_out_index(event):
    if entry_index.get() == "":
        entry_index.insert(0, "Индекс")
        entry_index.configure(foreground=text_color)


#Привязка событий к полям ввода
entry_value.bind("<FocusIn>", on_focus_in_value)
entry_value.bind("<FocusOut>", on_focus_out_value)
entry_index.bind("<FocusIn>", on_focus_in_index)
entry_index.bind("<FocusOut>", on_focus_out_index)

#Добавить элемент в конец
def add_item_action(event=None):
    text = entry_value.get()

    if text == "Значение элемента" or text == "":
        messagebox.showwarning("Внимание", "Введите значение элемента!")
        return

    dll.add_to_end(text)

    refresh_list_visuals()
    update_counter()

    entry_value.delete(0, END)
    entry_value.focus()

#Вставить элемент по индексу
def insert_item_action():
    text = entry_value.get()
    index_text = entry_index.get()

    if text == "Значение элемента" or text == "":
        messagebox.showwarning("Внимание", "Введите значение элемента!")
        return

    if index_text == "Индекс" or index_text == "":
        messagebox.showwarning("Внимание", "Введите индекс для вставки!")
        return

    try:
        index = int(index_text) - 1

        if dll.insert_by_index(index, text):
            refresh_list_visuals()
            update_counter()

            entry_value.delete(0, END)
            entry_index.delete(0, END)
            entry_value.focus()
        else:
            messagebox.showerror("Ошибка!", "Неверный индекс!")
    except ValueError:
        messagebox.showerror("Ошибка!", "Индекс должен быть числом!")

#Удалить элемент по индексу
def delete_item_action():
    index_text = entry_index.get()

    if index_text == "Индекс" or index_text == "":
        messagebox.showwarning("Ошибка!", "Введите индекс элемента для удаления!")
        return

    try:
        index = int(index_text) - 1

        if dll.delete_by_index(index):
            refresh_list_visuals()
            update_counter()
            entry_index.delete(0, END)
        else:
            messagebox.showerror("Ошибка!", "Индекс вне диапазона!")
    except ValueError:
        messagebox.showerror("Ошибка!", "Индекс должен быть числом!")

#Найти элемент по индексу
def get_item_action():
    index_text = entry_index.get()

    if index_text == "Индекс" or index_text == "":
        messagebox.showwarning("Ошибка!", "Введите индекс элемента!")
        return

    try:
        index = int(index_text) - 1

        if index < 0 or index >= dll.get_length():
            messagebox.showerror("Ошибка!", "Индекс вне диапазона!")
            return

        item_text = dll.get_by_index(index)
        messagebox.showinfo("Информация", "Индекс: " + str(index + 1) + "\nЗначение: " + item_text)
        entry_index.delete(0, END)
    except ValueError:
        messagebox.showerror("Ошибка!", "Индекс должен быть числом!")


#Фрейм для кнопок
buttons_frame = Frame(bottom_frame, bg=widget_bg)
buttons_frame.pack(fill=X, padx=40)

add_btn = ttk.Button(buttons_frame,
                     text='Добавить в конец',
                     style='button.TButton',
                     command=add_item_action)
add_btn.grid(row=0, column=0, sticky="ew", padx=5, pady=5)

insert_btn = ttk.Button(buttons_frame,
                        text='Вставить по индексу',
                        style='button.TButton',
                        command=insert_item_action)
insert_btn.grid(row=0, column=1, sticky="ew", padx=5, pady=5)

del_btn = ttk.Button(buttons_frame,
                     text='Удалить по индексу',
                     style='button.TButton',
                     command=delete_item_action)
del_btn.grid(row=1, column=0, sticky="ew", padx=5, pady=5)

get_btn = ttk.Button(buttons_frame,
                     text='Найти по индексу',
                     style='button.TButton',
                     command=get_item_action)
get_btn.grid(row=1, column=1, sticky="ew", padx=5, pady=5)

buttons_frame.grid_columnconfigure(0, weight=1)
buttons_frame.grid_columnconfigure(1, weight=1)

#Привязка кнопки энтер к полю ввода значения
entry_value.bind('<Return>', add_item_action)

root.mainloop()