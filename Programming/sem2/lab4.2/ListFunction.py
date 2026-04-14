class Node:
    def __init__(self, data):
        self.data = data #значение элемента
        self.next = None #следующий узел
        self.prev = None #предыдущий узел


class DoublyLinkedList:
    def __init__(self):
        self.head = None
        self.tail = None

    #Проверка на пустоту
    def is_empty(self):
        return self.head is None

    #Количество элементов
    def get_length(self):
        count = 0
        current = self.head

        while current is not None:
            count += 1
            current = current.next

        return count

    #Добавление в конец
    def add_to_end(self, data):
        new_node = Node(data)

        if self.head is None:
            self.head = new_node
            self.tail = new_node
        else:
            new_node.prev = self.tail
            self.tail.next = new_node
            self.tail = new_node

    #Вставка по индексу
    def insert_by_index(self, index, data):
        if index < 0 or index > self.get_length():
            return False

        new_node = Node(data)

        if index == 0:
            if self.head is None:
                self.head = new_node
                self.tail = new_node
            else:
                new_node.next = self.head
                self.head.prev = new_node
                self.head = new_node
            return True

        if index == self.get_length():
            new_node.prev = self.tail
            if self.tail is not None:
                self.tail.next = new_node
            self.tail = new_node
            if self.head is None:
                self.head = new_node
            return True

        current = self.head
        i = 0

        while current is not None and i < index:
            current = current.next
            i += 1

        if current is None:
            return False

        new_node.prev = current.prev
        new_node.next = current

        if current.prev is not None:
            current.prev.next = new_node

        current.prev = new_node

        return True

    #Удаление по индексу
    def delete_by_index(self, index):
        if index < 0 or index >= self.get_length():
            return False

        current = self.head
        i = 0

        while current is not None and i < index:
            current = current.next
            i += 1

        if current is None:
            return False

        if current == self.head and current == self.tail:
            self.head = None
            self.tail = None
        elif current == self.head:
            self.head = current.next
            if self.head is not None:
                self.head.prev = None
        elif current == self.tail:
            self.tail = current.prev
            if self.tail is not None:
                self.tail.next = None
        else:
            current.prev.next = current.next
            current.next.prev = current.prev

        return True

    #Получить элемент по индексу
    def get_by_index(self, index):
        if index < 0 or index >= self.get_length():
            return None

        current = self.head
        i = 0

        while current is not None and i < index:
            current = current.next
            i += 1

        if current is None:
            return None

        return current.data

    #Очистка списка
    def clear(self):
        self.head = None
        self.tail = None

    #Преобразование в обычный список
    def to_list(self):
        result = []
        current = self.head

        while current is not None:
            result.append(current.data)
            current = current.next

        return result