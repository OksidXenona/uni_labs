import csv
import random

# Города
cities = [
    "Москва", "Санкт-Петербург","Казань", "Новосибирск", "Екатеринбург",
    "Нижний Новгород", "Самара", "Ростов-на-Дону", "Краснодар", "Владивосток",

    "Берлин", "Гамбург", "Мюнхен", "Кёльн", "Париж", "Лондон", "Мадрид",
    "Рим", "Вена", "Прага", "Амстердам", "Брюссель", "Нью-Йорк", "Лос-Анджелес",
    "Чикаго", "Сан-Франциско", "Лас-Вегас", "Токио", "Сеул", "Пекин", "Дубай"
]

# Артисты
perfomers = [
    "Rammstein", "Taylor Swift", "Drake", "Adele", "Ed Sheeran",
    "Billie Eilish", "The Weeknd", "Dua Lipa", "Imagine Dragons",
    "Coldplay", "Bruno Mars", "Post Malone", "Kanye West",

    "Баста", "Скриптонит", "Моргенштерн", "Земфира",
    "Би-2", "Сплин", "Кино", "ДДТ", "Ленинград",
    "Егор Крид", "Полина Гагарина", "LOBODA",
    "Макс Корж", "Oxxxymiron", "Noize MC",
    "Artik & Asti", "Zivert", "Мияги & Эндшпиль",

    "Metallica", "Nirvana", "Linkin Park", "Queen",
    "Arctic Monkeys", "Red Hot Chili Peppers",
    "Pink Floyd", "AC/DC"
]

def is_leap(year):
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

def generate_random_date():
    year = random.randint(2020, 2026)
    month = random.randint(1, 12)

    if month in [1, 3, 5, 7, 8, 10, 12]:
        max_day = 31
    elif month in [4, 6, 9, 11]:
        max_day = 30
    else:
        if is_leap(year):
            max_day = 29
        else:
            max_day = 28

    day = random.randint(1, max_day)

    return f"{year:04d}-{month:02d}-{day:02d}"

def generate_data(filename, size=1):
    bytes = size * 1024**3 # Гигабайты в байты
    curr_size = 0

    with open(filename, 'w', newline='', encoding='utf-8-sig') as f:
        text = csv.writer(f)
        text.writerow(["дата", "город", "артист"])

        while curr_size < bytes:
            row = [
                generate_random_date(),
                random.choice(cities),
                random.choice(perfomers)
            ]

            line = ",".join(row) + "\n"
            text.writerow(row)

            curr_size += len(line.encode('utf-8'))

generate_data("data.csv", 1)