import numpy as np

#1. Загрузка и подготовка типов

dt = np.dtype([
    ('ts', 'int32'), # время замера
    ('joint_id', 'int16'), # ID шарнира
    ('angle', 'float32'), # угол поворота
    ('torque', 'float32'), # крутящийся момент
    ('cur', 'float32'), # потребляемый ток
    ('temp', 'float32') # температура обмотки
])

data = np.genfromtxt(
    '/content/data.csv',
    delimiter=',',
    skip_header=1,
    dtype=dt,
    invalid_raise=False
)

print(f"Количество строк: {len(data)}")
print(f'Объем памяти: {data.nbytes} байт, {(data.nbytes / (1024 ** 2)):.2f} Мбайт')

num_fields = ['angle', 'torque', 'cur', 'temp']
nan_total = 0
inf_total = 0

for field in num_fields:
  nan_total += np.isnan(data[field]).sum()
  inf_total += np.isinf(data[field]).sum()

total = len(data) * 4 # 4 числовых поля потому что :)
percent = (nan_total + inf_total) / total * 100
print(f'NaN: {nan_total}')
print(f'Inf: {inf_total}')

if percent > 3:
  print(f'Предупреждение! Больше 3% пропусков и бесконечностей ({percent:.2f}%).')
else:
  print(f'Всё круто. Пропусков и бесконечностей меньше 3% ({percent:.2f}%).')

np.save('step1.npy', data)
print('Файл сохранён.')

# 2. Векторизованная фильтрация и очистка
# data['angle'][0] = 250.0
# data['cur'][1] = -15.5
# data['torque'][2] = 9999.0

mask_angle = (data['angle'] < -180) | (data['angle'] > 180)
print(f"Угол вне [-180, 180]: {mask_angle.sum()} строк ({mask_angle.sum()/len(data)*100:.2f}%)")

mask_cur = data['cur'] < 0
print(f"Отрицательный ток: {mask_cur.sum()} строк ({mask_cur.sum()/len(data)*100:.2f}%)")

p99_torque = np.nanpercentile(data['torque'], 99)
mask_torque = data['torque'] > p99_torque
print(f"Момент выше 99-го процентиля ({p99_torque:.2f} Нм): {mask_torque.sum()} строк ({mask_torque.sum()/len(data)*100:.2f}%)")

mask_all = mask_angle | mask_cur | mask_torque
print(f"\nВсего строк с аномалиями: {mask_all.sum()} ({mask_all.sum()/len(data)*100:.2f}%)")

data['angle'] = np.clip(data['angle'], -180, 180)
data['cur'] = np.where(data['cur'] < 0, 0.0, data['cur'])
data['torque'] = np.clip(data['torque'], None, p99_torque)

print('\nВсё почистили.')

np.save('step2.npy', data)
print('Файл сохранён.')

# 3. Группировка + Нормализация
unique_joints = np.unique(data['joint_id'])
n_groups = len(unique_joints)
print(f"Количество групп (шарниров): {n_groups}")

dt_extended = np.dtype(data.dtype.descr + [('torque_zscore', 'float32')]) # добавляем столбец
data_normal = np.zeros(len(data), dtype=dt_extended)

for name in data.dtype.names:
    data_normal[name] = data[name]

group_stats = []
for joint_id in unique_joints:
    mask = data['joint_id'] == joint_id # содержит True только для текущего шарнира

    group_size = np.sum(mask)

    torque_group = data['torque'][mask]
    cur_group = data['cur'][mask]

    mean_torque = np.nanmean(torque_group) # среднее
    std_torque = np.nanstd(torque_group) # разброс
    max_cur = np.nanmax(cur_group) # максимум для текущего шарнира

    group_stats.append((joint_id, group_size, mean_torque, max_cur))
    print(f"Шарнир {joint_id:2d}: записей ={group_size:7d} | ср.torque ={mean_torque:7.2f} | макс.cur ={max_cur:7.2f}")

    if std_torque > 0:
        z_scores = (torque_group - mean_torque) / std_torque 
    else:
        z_scores = np.zeros_like(torque_group)

    data_normal['torque_zscore'][mask] = z_scores

print(f"\nНормализация завершена.")
print(f"mean(torque_zscore) ≈ {np.nanmean(data_normal['torque_zscore']):.4f}, std(torque_zscore) ≈ {np.nanstd(data_norm['torque_zscore']):.4f}")

np.save('step3.npy', data_normal)
print('Файл сохранён.')

#3. Скользящее окно и разница
k = 50 # размер окна

dt_step4 = np.dtype(data_normal.dtype.descr + [
    ('torque_moving_avg', 'float32'),
    ('angular_velocity', 'float32')
])

data_step4 = np.zeros(len(data_normal), dtype=dt_step4)

for name in data_normal.dtype.names:
    data_step4[name] = data_normal[name]

torque = data_step4['torque']

c_sum = np.nancumsum(torque) # накопительная сумма
c_cnt = np.nancumsum(~np.isnan(torque)) # накопительное кличество валидных чисел

c_sum = np.concatenate(([0.0], c_sum)) # добавляем 0 в начало
c_cnt = np.concatenate(([0], c_cnt))

sum_window = c_sum[k:] - c_sum[:-k] # вычисляем сумму
cnt_window = c_cnt[k:] - c_cnt[:-k] # и количество внутри окна

moving_avg = np.where(cnt_window > 0, sum_window / cnt_window, np.nan) # делим сумму на количество

data_step4['torque_moving_avg'] = np.concatenate([ # 49 значений приклеиваем в начало
    np.full(k - 1, np.nan, dtype='float32'),       # потому что массив стал меньше
    moving_avg
])

angle = data_step4['angle']
angle_diff_raw = np.diff(angle)

data_step4['angular_velocity'] = np.pad(angle_diff_raw, (1, 0), constant_values=0.0)

print(f"Скользящее среднее (torque, k={k}) и угловая скорость рассчитаны.")

ma_valid = data_step4['torque_moving_avg'][k-1:k+4]
print(f"Первые 5 валидных значений скользящего среднего: {ma_valid}")

av = data_step4['angular_velocity']
print(f"Угловая скорость: min={np.nanmin(av):.2f} | max={np.nanmax(av):.2f} | mean={np.nanmean(av):.4f} град/такт")

np.save('step4.npy', data_step4)
print('Файл сохранён.')

#4. Создание производных признаков (Feature Engineering)

dt_step5 = np.dtype(data_step4.dtype.descr + [
    ('torque_efficiency', 'float32'),
    ('thermal_load_index', 'float32')
])

data_step5 = np.zeros(len(data_step4), dtype=dt_step5)

for name in data_step4.dtype.names:
    data_step5[name] = data_step4[name]

eps = 1e-8

data_step5['torque_efficiency'] = data_step5['torque'] / (np.abs(data_step5['cur']) + eps)
data_step5['thermal_load_index'] = data_step5['temp'] / (np.abs(data_step5['cur']) + eps)

print("Новые признаки рассчитаны.")

for feat in ['torque_efficiency', 'thermal_load_index']:
    col = data_step5[feat]

    col = np.where(np.isinf(col), 0.0, col)
    col = np.where(np.isnan(col), 0.0, col)

    data_step5[feat] = col
    print(f"   {feat}: проблемные значения (Inf/NaN) заменены на 0")

np.save('step5.npy', data_step5)
print('Файл сохранён.')

#5. Условная агрегация по группам

threshold_temp = 75.0
threshold_torque = 50.0

mask_critical = (data_step5['temp'] > threshold_temp) & (data_step5['torque'] > threshold_torque)

print(f"Найдено записей: {np.sum(mask_critical)}")
print(f"(Температура > {threshold_temp} и Момент > {threshold_torque})")

unique_joints = np.unique(data_step5['joint_id'])
n_groups = len(unique_joints)

results = np.zeros((n_groups, 3), dtype='float32') # матрица

print("\nРасчёт статистики тока (cur) только для критических зон:")

for i, joint_id in enumerate(unique_joints):
    mask_group = data_step5['joint_id'] == joint_id
    mask_subset = mask_group & mask_critical # эта группа и критическое условие

    if np.sum(mask_subset) > 0:
        subset_cur = data_step5['cur'][mask_subset]

        mean_val = np.nanmean(subset_cur)
        median_val = np.nanmedian(subset_cur)
        p90_val = np.nanpercentile(subset_cur, 90)

        results[i, 0] = joint_id
        results[i, 1] = mean_val
        results[i, 2] = median_val

        if i < 5:
             print(f"  Шарнир {int(joint_id)}: найдено {np.sum(mask_subset)} крит. точек | "
                   f"Ср. cur={mean_val:.2f}, Мед. cur={median_val:.2f}, P90={p90_val:.2f}")
    else:
        results[i, 0] = joint_id
        results[i, 1] = np.nan
        results[i, 2] = np.nan

print("joint_id | Mean_Cond | Median_Cond)")
print(results)

np.save('conditional_stats.npy', results)
np.save('step6.npy', data_step5)
print('Таблица и файл сохранены.')

#6. Лаговые признаки и анализ временных сдвигов

dt_step7 = np.dtype(data_step5.dtype.descr + [
    ('cur_lag', 'float32'),
    ('cur_diff', 'float32')
])

data_step7 = np.zeros(len(data_step5), dtype=dt_step7)

for name in data_step5.dtype.names:
    data_step7[name] = data_step5[name]

lagged_values = np.roll(data_step7['cur'], 1)
lagged_values[0] = np.nan # исправляем заворачивание последнего элемента в начало

data_step7['cur_lag'] = lagged_values

diff_values = data_step7['cur'] - data_step7['cur_lag'] # считаем разницу
data_step7['cur_diff'] = diff_values

signs = np.sign(diff_values) # смотрим знак

valid_signs = signs[~np.isnan(signs)]

# считаем, сколько раз встретилось каждое значение (-1, 0, 1)
unique_signs, counts = np.unique(valid_signs, return_counts=True)
total_records = len(valid_signs)

print("Распределение изменений тока (cur):")
for sign, count in zip(unique_signs, counts):
    percent = (count / total_records) * 100
    if sign == -1.0:
        status = "ПАДАЛО"
    elif sign == 1.0:
        status = "РОСЛО"
    else:
        status = "НЕ МЕНЯЛОСЬ"

    print(f"  {status:<15}: {count:>6} записей ({percent:.2f}%)")

np.save('step7.npy', data_step7)
print('Файл сохранён.')

#7. Групповая робастная замена выбросов

data = data_step7
unique_joints = np.unique(data['joint_id'])

dt_step8 = np.dtype(data.dtype.descr + [('torque_iqr_cleaned', 'float32')])
data_step8 = np.zeros(len(data), dtype=dt_step8)

for name in data.dtype.names:
    data_step8[name] = data[name]

data_step8['torque_iqr_cleaned'] = data['torque'].copy()

total_replaced = 0
print(f"{'ID шарнира':<12} | {'Q1':<7} | {'Q3':<7} | {'IQR':<7} | {'Ниж. гр.':<8} | {'Вер. гр.':<8} | {'Заменено'}")

for joint_id in unique_joints:
    mask_group = data_step8['joint_id'] == joint_id
    torque_group = data_step8['torque'][mask_group]

    Q1 = np.nanpercentile(torque_group, 25)
    Q3 = np.nanpercentile(torque_group, 75)
    IQR = Q3 - Q1
    median_group = np.nanmedian(torque_group)

    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR

    valid_mask = ~np.isnan(torque_group)
    outlier_mask = valid_mask & ((torque_group < lower_bound) | (torque_group > upper_bound))

    cleaned_torque_group = np.where(outlier_mask, median_group, torque_group)

    data_step8['torque_iqr_cleaned'][mask_group] = cleaned_torque_group

    n_replaced = np.sum(outlier_mask)
    total_replaced += n_replaced

    print(f"{joint_id:<12} | {Q1:<7.2f} | {Q3:<7.2f} | {IQR:<7.2f} | "
          f"{lower_bound:<8.2f} | {upper_bound:<8.2f} | {n_replaced}")

replaced_percent = (total_replaced / len(data_step8)) * 100
print(f"\nВсего заменено выбросов: {total_replaced} ({replaced_percent:.2f}% от общего числа записей)")

np.save('step8.npy', data_step8)
print('Файл сохранён.')

#8. Проверка согласованности и логической целостности

data = data_step8

mask_cur_invalid = data['cur'] < 0
mask_temp_invalid = data['temp'] < 0
mask_angle_invalid = (data['angle'] < -180) | (data['angle'] > 180)
mask_logic_invalid = (np.abs(data['torque']) > 10.0) & (data['cur'] == 0.0)

mask_all_invalid = mask_cur_invalid | mask_temp_invalid | mask_angle_invalid | mask_logic_invalid

n_invalid = np.sum(mask_all_invalid)
total_rows = len(data)
percent_invalid = (n_invalid / total_rows) * 100

print("Результаты проверки согласованности:")
print(f"   Ток < 0                 : {np.sum(mask_cur_invalid)} строк")
print(f"   Температура < 0         : {np.sum(mask_temp_invalid)} строк")
print(f"   Угол вне [-180, 180]    : {np.sum(mask_angle_invalid)} строк")
print(f"   Момент > 10 при токе = 0: {np.sum(mask_logic_invalid)} строк")
print(f"\n Всего строк с нарушениями: {n_invalid} ({percent_invalid:.2f}%)")

data['cur'] = np.where(mask_cur_invalid, 0.0, data['cur'])
data['temp'] = np.where(mask_temp_invalid, 0.0, data['temp'])
data['angle'] = np.clip(data['angle'], -180, 180)
data['torque'] = np.where(mask_logic_invalid, 0.0, data['torque'])

print("\n Некорректные значения заменены на физические границы или 0.")

np.save('step9.npy', data)
print('Файл сохранён.')

#9. Частотный анализ и сжатие редких категорий

data = np.load('step9.npy', allow_pickle=True)
total_rows = len(data)

unique_joints, counts = np.unique(data['joint_id'], return_counts=True)
print(f"Всего уникальных шарниров: {len(unique_joints)}")

threshold = total_rows * 0.01
print(f"Порог редкости (1%): {threshold:.0f} записей")

rare_mask = counts < threshold
rare_joints = unique_joints[rare_mask]

print(f"\nНайдено редких шарниров (< 1%): {len(rare_joints)}")
if len(rare_joints) > 0:
    print(f"Их ID: {rare_joints}")
else:
    print("Редких категорий не обнаружено (все шарниры распределены равномерно).")

dt_final = np.dtype(data.dtype.descr + [('joint_id_compressed', 'int16')])
data_final = np.zeros(total_rows, dtype=dt_final)

for name in data.dtype.names:
    data_final[name] = data[name]

data_final['joint_id_compressed'] = data['joint_id'].copy()
OTHER_CODE = 255

if len(rare_joints) > 0:
    mask_rare = np.isin(data_final['joint_id_compressed'], rare_joints)
    data_final['joint_id_compressed'] = np.where(mask_rare, OTHER_CODE, data_final['joint_id_compressed'])
    n_replaced = np.sum(mask_rare)
    print(f"\nРедкие категории объединены в OTHER (код {OTHER_CODE})")
    print(f"   Перенесено записей: {n_replaced} ({n_replaced / total_rows * 100:.2f}%)")
else:
    print("\nВсе категории достаточно частые. Сжатие не потребовалось.")

print("Финальное распределение категорий:")
final_ids, final_counts = np.unique(data_final['joint_id_compressed'], return_counts=True)

for uid, cnt in zip(final_ids, final_counts):
    label = f"OTHER (код {uid})" if uid == OTHER_CODE else f"Шарнир {uid}"
    print(f"  {label:<20}: {cnt:>6} записей ({cnt / total_rows * 100:.2f}%)")

np.save('step10.npy', data_final)
print('Файл сохранён.')