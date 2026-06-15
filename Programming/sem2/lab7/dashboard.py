import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
import os

# глобальные переменные
df_raw = None # исходная таблица
df_work = None # рабочая таблица
fig = plt.Figure(figsize=(9, 5.5), dpi=100) # чистый холст для графиков
canvas = None
current_chart = "line" # выбранный график

# переменные интерфейса
var_zone = None
var_thermal = None
var_agg = None
var_roll = None

# настройка шрифтов
plt.rcParams['font.sans-serif'] = ['Arial', 'DejaVu Sans', 'Segoe UI']
plt.rcParams['axes.unicode_minus'] = False # корректное отображение минуса

# загрузка и добавлеие категорий
def load_and_prepare_data():
    global df_raw, df_work

    if not os.path.exists('step10.npy'):
        messagebox.showerror("Ошибка", "Файл step10.npy не найден!")
        return

    data = np.load('step10.npy', allow_pickle=True)
    df_raw = pd.DataFrame(data) # набор чисел в таблицу

    # добавление категорий:

    # дата замеров
    df_raw['timestamp'] = pd.to_datetime(df_raw['ts'], unit='s')

    # зона шарнира
    def get_joint_zone(jid):
        if jid == 255:
            return "прочие/редкие"
        if jid <= 0:
            return "неизвестно"
        remainder = jid % 6
        if remainder == 1:
            return "база/поворот"
        elif remainder == 2:
            return "плечо"
        elif remainder == 3:
            return "локоть"
        elif remainder in [4, 5]:
            return "запястье"
        elif remainder == 0:
            return "схват/кисть"
        return "неизвестно"

    id_col = 'joint_id_compressed' if 'joint_id_compressed' in df_raw.columns else 'joint_id'
    df_raw['joint_zone'] = df_raw[id_col].apply(get_joint_zone).astype('category')

    # режим нагрузки
    torque_col = 'torque_iqr_cleaned' if 'torque_iqr_cleaned' in df_raw.columns else 'torque'
    conditions = [
        (df_raw[torque_col] < 15.0),
        (df_raw[torque_col] >= 15.0) & (df_raw[torque_col] < 35.0)
    ]
    choices = ['холостой ход', 'рабочий']
    df_raw['load_mode'] = np.select(conditions, choices, default='пиковая нагрузка')
    df_raw['load_mode'] = df_raw['load_mode'].astype('category')

    # тепловой статус
    df_raw['thermal_status'] = pd.cut(
        df_raw['temp'],
        bins=[-np.inf, 40.0, 55.0, np.inf],
        labels=['норма', 'предупреждение', 'перегрев']
    ).astype('category')

    # первичная фильтрация
    df_work = df_raw.query("cur >= 0 and angle >= -180 and angle <= 180").copy()

    print(f"данные загружены. строк: {len(df_work)}")


def clean_data():
    global df_work
    df = df_work.copy()

    # производный признак: эффективность
    df['efficiency'] = df['torque'] / (df['cur'] + 1e-8) # момент / ток

    # обрезка выбросов по IQR
    q1 = df.groupby('joint_zone')['torque'].transform('quantile', 0.25)
    q3 = df.groupby('joint_zone')['torque'].transform('quantile', 0.75)
    iqr = q3 - q1
    df['torque_cleaned'] = df['torque'].clip(lower=q1 - 1.5 * iqr, upper=q3 + 1.5 * iqr)

    # оптимизация категорий
    for col in ['joint_zone', 'load_mode', 'thermal_status']:
        if col in df.columns:
            df[col] = df[col].cat.remove_unused_categories() # убираем неиспользованные категории

    df_work = df
    print("данные очищены и признаки созданы.")


def get_filtered_data():
    df = df_work.copy()

    # фильтр по зоне
    zone = var_zone.get() # читаем выбор пользователя
    if zone != "все":
        df = df.query("joint_zone == @zone")

    # фильтр по статусу
    thermal = var_thermal.get()
    if thermal != "все":
        df = df.query("thermal_status == @thermal")

    # агрегация по дням
    df = df.set_index('timestamp') # делаем время главным столбцом
    agg_rules = {
        'torque': 'mean',
        'torque_cleaned': 'mean',
        'cur': 'mean',
        'temp': 'mean',
        'angle': 'mean',
        'efficiency': 'mean',
        'joint_zone': 'first',
        'load_mode': 'first',
        'thermal_status': 'first'
    }
    valid_agg = {k: v for k, v in agg_rules.items() if k in df.columns} # перебирает пары, если есть такой столбец, включает пару
    df = df.resample('D').agg(valid_agg).dropna() # группируем данные по дням; считаем среднее
                                                  # или берем первое значение для категорий; удаляем дни без данных
    df = df.reset_index()

    # скользящее среднее
    window = var_roll.get()
    df['temp_smooth'] = df['temp'].rolling(window=window, min_periods=1).mean()

    # биннинг температуры
    df['temp_level'] = pd.cut(df['temp'], bins=3, labels=["низкий", "средний", "высокий"])
    return df

# функция для стирания графика
def clear_and_prepare_plot():
    fig.clear()

# линейный график
def plot_line():
    clear_and_prepare_plot() # стирает старый график
    df = get_filtered_data() # получаем свежие данные
    if df.empty: # если данных нет, выходим
        return

    # группируем по времени, считаем среднюю температуру по всем зонам
    df_line = df.groupby('timestamp')['temp_smooth'].mean().reset_index()

    sns.lineplot(data=df_line, x='timestamp', y='temp_smooth',  # строим график
                 ax=fig.add_subplot(111), # 1 строка, 1 столбец, 1 подграфик
                 color='steelblue', linewidth=1)
    plt.title("Средняя температура по дням (все зоны)")
    plt.ylabel("Температура, °C")
    plt.xlabel("Время")
    fig.tight_layout() # чтобы текст не обрезался
    canvas.draw_idle() # ставит задачу в очередь событий tkinter

# столбчатый график
def plot_bar():
    clear_and_prepare_plot() # стираем старый график
    df = get_filtered_data() # получаем свежие данные
    if df.empty:
        return

    agg_method = var_agg.get() # читаем выбор агрегации

    # используем абсолютное значение момента
    df_plot = df.copy()
    df_plot['torque_abs'] = df_plot['torque_cleaned'].abs()

    df_grouped = df_plot.groupby('joint_zone')['torque_abs'].agg(agg_method).reset_index()

    sns.barplot(
        data=df_grouped,
        x='joint_zone',
        y='torque_abs',
        ax=fig.add_subplot(111),
        errorbar=None
    )
    plt.title(f"Абсолютный крутящий момент по зонам ({agg_method})")
    plt.ylabel("Момент (абс.), Нм")
    plt.xlabel("Зона шарнира")
    fig.tight_layout()
    canvas.draw_idle()

# точечный график
def plot_scatter():
    clear_and_prepare_plot() # чистим график
    df = get_filtered_data() # получаем данные
    if df.empty:
        return

    sns.scatterplot(
        data=df,
        x='torque',
        y='cur',
        hue='thermal_status', # цвет точки определяется значение теплового статуса
        ax=fig.add_subplot(111),
        palette=['green', 'orange', 'red'],  # норма=зелёный, предупреждение=оранжевый, перегрев=красный
        alpha=0.6, # полупрозрачность
        s=30 # размер точек
    )
    plt.title("Момент vs Ток (по тепловому статусу)")
    plt.ylabel("Ток, А")
    plt.xlabel("Крутящий момент, Нм")
    fig.tight_layout()
    canvas.draw_idle()

# тепловая карта
def plot_heatmap():
    clear_and_prepare_plot() # очищаем график
    df = get_filtered_data() # получаем данные
    if df.empty:
        return

    pivot = df.pivot_table(
        values='temp', # ячейки содержат температуру
        index='joint_zone', # строки - зоны шарниров
        columns='load_mode', # столбцы - режимы нагрузки
        aggfunc='median' # если значений несколько, берем медиану
    )

    sns.heatmap(pivot, annot=True, cmap='coolwarm', fmt='.1f', ax=fig.add_subplot(111))
    plt.title("Медианная температура: зона * режим нагрузки")
    fig.tight_layout()
    canvas.draw_idle()

# определяет какой тип графика выбран
def on_filter_change(event=None):
    global current_chart
    if current_chart == "line":
        plot_line()
    elif current_chart == "bar":
        plot_bar()
    elif current_chart == "scatter":
        plot_scatter()
    elif current_chart == "heatmap":
        plot_heatmap()

# меняет глобальную переменную на переданное значение
def change_chart_type(new_type):
    global current_chart
    current_chart = new_type
    on_filter_change()

# открывает диалоговое окно "Сохранить как..."
def export_image():
    path = filedialog.asksaveasfilename(defaultextension=".png", filetypes=[("PNG", "*.png")])
    if path:
        fig.savefig(path, dpi=300, bbox_inches='tight')
        messagebox.showinfo("Успех", "График сохранен!")


def build_interface():
    global var_zone, var_thermal, var_agg, var_roll, canvas

    root = tk.Tk()
    root.title("Дашборд: Робототехника (Вариант 18)")
    root.geometry("1000x700")

    # верхняя панель с фильтрами
    top_frame = tk.Frame(root, bg="#e0e5ec", pady=10)
    top_frame.pack(fill=tk.X, padx=10)

    # 1. выпадающий список: зона шарнира
    tk.Label(top_frame, text="зона шарнира:", bg="#e0e5ec").pack(side=tk.LEFT, padx=5)
    var_zone = tk.StringVar(value="все")
    zones = ["все"] + list(df_work['joint_zone'].cat.categories.tolist()) # список игдексов уникальных категорий
    combo_zone = ttk.Combobox(top_frame, textvariable=var_zone, values=zones, state="readonly")
    combo_zone.pack(side=tk.LEFT, padx=5)
    combo_zone.bind("<<ComboboxSelected>>", on_filter_change)

    # 2. выпадающий список: тепловой статус
    tk.Label(top_frame, text="статус:", bg="#e0e5ec").pack(side=tk.LEFT, padx=(15, 5))
    var_thermal = tk.StringVar(value="все")
    thermals = ["все"] + list(df_work['thermal_status'].cat.categories.tolist())
    combo_thermal = ttk.Combobox(top_frame, textvariable=var_thermal, values=thermals, state="readonly")
    combo_thermal.pack(side=tk.LEFT, padx=5)
    combo_thermal.bind("<<ComboboxSelected>>", on_filter_change)

    # 3. переключатели: тип агрегации
    tk.Label(top_frame, text="метрика:", bg="#e0e5ec").pack(side=tk.LEFT, padx=(20, 5))
    var_agg = tk.StringVar(value="mean")
    for val, text in [("mean", "среднее"), ("sum", "сумма"), ("median", "медиана")]:
        ttk.Radiobutton(top_frame, text=text, variable=var_agg, value=val,
                        command=on_filter_change).pack(side=tk.LEFT)

    # 4. ползунок: размер окна сглаживания
    tk.Label(top_frame, text="сглаживание (дней):", bg="#e0e5ec").pack(side=tk.LEFT, padx=(20, 5))
    var_roll = tk.IntVar(value=7)
    scale = ttk.Scale(top_frame, from_=1, to=30, variable=var_roll, orient=tk.HORIZONTAL)
    scale.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5)
    scale.bind("<ButtonRelease-1>", on_filter_change)

    # область графика
    plot_frame = tk.Frame(root, bg="white", relief=tk.SUNKEN, bd=1)
    plot_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)

    canvas = FigureCanvasTkAgg(fig, master=plot_frame) # встраивает фигуру в tkinter
    canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

    toolbar = NavigationToolbar2Tk(canvas, plot_frame)
    toolbar.update()

    # нижняя панель кнопок
    btn_frame = tk.Frame(root, pady=10)
    btn_frame.pack(fill=tk.X)

    tk.Button(btn_frame, text="линейный", command=lambda: change_chart_type("line"), width=12).pack(side=tk.LEFT, padx=5)
    tk.Button(btn_frame, text="столбчатый", command=lambda: change_chart_type("bar"), width=12).pack(side=tk.LEFT, padx=5)
    tk.Button(btn_frame, text="точечный", command=lambda: change_chart_type("scatter"), width=12).pack(side=tk.LEFT, padx=5)
    tk.Button(btn_frame, text="тепловая карта", command=lambda: change_chart_type("heatmap"), width=15).pack(side=tk.LEFT, padx=5)

    tk.Button(btn_frame, text="экспорт", command=export_image, width=12).pack(side=tk.RIGHT, padx=5)

    return root


if __name__ == "__main__":
    load_and_prepare_data()
    clean_data()
    app = build_interface()
    plot_line()
    app.mainloop()
