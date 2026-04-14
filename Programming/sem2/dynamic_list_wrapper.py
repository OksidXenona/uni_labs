import ctypes

dll = ctypes.CDLL('./dynamic_list.dll')

dll.clear.restype = None

dll.is_empty.restype = ctypes.c_int

dll.get_length.restype = ctypes.c_int

dll.add_to_end.argtypes = [ctypes.c_char_p]
dll.add_to_end.restype = None

dll.insert_by_index.argtypes = [ctypes.c_int, ctypes.c_char_p]
dll.insert_by_index.restype = ctypes.c_int

dll.delete_by_index.argtypes = [ctypes.c_int]
dll.delete_by_index.restype = ctypes.c_int

dll.get_by_index.argtypes = [ctypes.c_int]
dll.get_by_index.restype = ctypes.c_char_p


class DoublyLinkedList:
    def __init__(self):
        dll.clear()

    def clear(self):
        dll.clear()

    def is_empty(self):
        result = dll.is_empty()
        if result == 1:
            return True
        return False

    def get_length(self):
        return dll.get_length()

    def add_to_end(self, value):
        dll.add_to_end(value.encode('utf-8'))

    def insert_by_index(self, index, value):
        result = dll.insert_by_index(index, value.encode('utf-8'))
        if result == 1:
            return True
        return False

    def delete_by_index(self, index):
        result = dll.delete_by_index(index)
        if result == 1:
            return True
        return False

    def get_by_index(self, index):
        result = dll.get_by_index(index)
        if result is None:
            return None
        return result.decode('utf-8')

    def to_list(self):
        result = []
        length = self.get_length()
        i = 0

        while i < length:
            item = self.get_by_index(i)
            result.append(item)
            i += 1

        return result