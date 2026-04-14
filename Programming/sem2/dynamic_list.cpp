#include <cstring>
#include <string>
#include <vector>

using namespace std;

struct Node
{
    char data[256];
    Node* next;
    Node* prev;
};

static Node* head = nullptr;
static Node* tail = nullptr;

extern "C"
{
    __declspec(dllexport) void clear()
    {
        Node* current = head;

        while (current != nullptr)
        {
            Node* next_node = current->next;
            delete current;
            current = next_node;
        }

        head = nullptr;
        tail = nullptr;
    }

    __declspec(dllexport) int is_empty()
    {
        if (head == nullptr)
        {
            return 1;
        }
        return 0;
    }

    __declspec(dllexport) int get_length()
    {
        int count = 0;
        Node* current = head;

        while (current != nullptr)
        {
            count++;
            current = current->next;
        }

        return count;
    }

    __declspec(dllexport) void add_to_end(const char* value)
    {
        if (value == nullptr)
        {
            return;
        }

        Node* new_node = new Node;
        strcpy(new_node->data, value);
        new_node->next = nullptr;
        new_node->prev = tail;

        if (tail == nullptr)
        {
            head = new_node;
            tail = new_node;
        }
        else
        {
            tail->next = new_node;
            tail = new_node;
        }
    }

    __declspec(dllexport) int insert_by_index(int index, const char* value)
    {
        if (value == nullptr)
        {
            return 0;
        }

        int length = get_length();

        if (index < 0 || index > length)
        {
            return 0;
        }

        Node* new_node = new Node;
        strcpy(new_node->data, value);
        new_node->next = nullptr;
        new_node->prev = nullptr;

        if (index == 0)
        {
            new_node->next = head;

            if (head != nullptr)
            {
                head->prev = new_node;
            }
            else
            {
                tail = new_node;
            }

            head = new_node;
            return 1;
        }

        if (index == length)
        {
            new_node->prev = tail;

            if (tail != nullptr)
            {
                tail->next = new_node;
            }
            else
            {
                head = new_node;
            }

            tail = new_node;
            return 1;
        }

        Node* current = head;
        int i = 0;

        while (current != nullptr && i < index)
        {
            current = current->next;
            i++;
        }

        if (current == nullptr)
        {
            delete new_node;
            return 0;
        }

        new_node->next = current;
        new_node->prev = current->prev;

        if (current->prev != nullptr)
        {
            current->prev->next = new_node;
        }

        current->prev = new_node;

        return 1;
    }

    __declspec(dllexport) int delete_by_index(int index)
    {
        int length = get_length();

        if (index < 0 || index >= length)
        {
            return 0;
        }

        Node* current = head;
        int i = 0;

        while (current != nullptr && i < index)
        {
            current = current->next;
            i++;
        }

        if (current == nullptr)
        {
            return 0;
        }

        if (current == head && current == tail)
        {
            head = nullptr;
            tail = nullptr;
        }
        else if (current == head)
        {
            head = current->next;
            if (head != nullptr)
            {
                head->prev = nullptr;
            }
        }
        else if (current == tail)
        {
            tail = current->prev;
            if (tail != nullptr)
            {
                tail->next = nullptr;
            }
        }
        else
        {
            current->prev->next = current->next;
            current->next->prev = current->prev;
        }

        delete current;
        return 1;
    }

    __declspec(dllexport) const char* get_by_index(int index)
    {
        static char result[256];

        int length = get_length();

        if (index < 0 || index >= length)
        {
            return nullptr;
        }

        Node* current = head;
        int i = 0;

        while (current != nullptr && i < index)
        {
            current = current->next;
            i++;
        }

        if (current == nullptr)
        {
            return nullptr;
        }

        strcpy(result, current->data);
        return result;
    }
}