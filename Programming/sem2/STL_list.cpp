#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <list>
#include <string>
#include <vector>
#include <iterator>

namespace py = pybind11;
using namespace std;

class DoublyLinkedList
{
private:
    list<string> data_list;

public:
    DoublyLinkedList()
    {
    }

    void clear()
    {
        data_list.clear();
    }

    int get_length()
    {
        return (int)data_list.size();
    }

    bool is_empty()
    {
        return data_list.empty();
    }

    void add_to_end(const string& value)
    {
        data_list.push_back(value);
    }

    bool insert_by_index(int index, const string& value)
    {
        if (index < 0 || index > (int)data_list.size())
        {
            return false;
        }

        list<string>::iterator it = data_list.begin();
        advance(it, index);
        data_list.insert(it, value);

        return true;
    }

    bool delete_by_index(int index)
    {
        if (index < 0 || index >= (int)data_list.size())
        {
            return false;
        }

        list<string>::iterator it = data_list.begin();
        advance(it, index);
        data_list.erase(it);

        return true;
    }

    string get_by_index(int index)
    {
        if (index < 0 || index >= (int)data_list.size())
        {
            return "";
        }

        list<string>::iterator it = data_list.begin();
        advance(it, index);

        return *it;
    }

    vector<string> to_list()
    {
        vector<string> result;

        list<string>::iterator it = data_list.begin();
        while (it != data_list.end())
        {
            result.push_back(*it);
            ++it;
        }

        return result;
    }
};

PYBIND11_MODULE(stl_list_module, m)
{
    py::class_<DoublyLinkedList>(m, "DoublyLinkedList")
        .def(py::init<>())
        .def("clear", &DoublyLinkedList::clear)
        .def("get_length", &DoublyLinkedList::get_length)
        .def("is_empty", &DoublyLinkedList::is_empty)
        .def("add_to_end", &DoublyLinkedList::add_to_end)
        .def("insert_by_index", &DoublyLinkedList::insert_by_index)
        .def("delete_by_index", &DoublyLinkedList::delete_by_index)
        .def("get_by_index", &DoublyLinkedList::get_by_index)
        .def("to_list", &DoublyLinkedList::to_list);
}