#include <iostream>
#include <fstream>
#include <typeinfo>
#include <cstring>
#include <cmath>

using namespace std;

template<class T>
class LinkedList;
template<class T>
class Stack;
template<class T>
class Queue;
template<class T>
class DoubleLinkedStack;
template<class T>
class MyStack;

class Exception : public std::exception {
protected:
    std::string message_;
public:
    explicit Exception(const std::string& message) : message_{message} {
        message_ = message;
    }

    const char* what() {
        return message_.c_str();
    }
};

template<class T>
class Element {
protected:
    Element<T> *next;
    Element<T> *prev;
    T info;
    friend class LinkedList<T>;
    friend class DoubleLinkedStack<T>;
    friend class Stack<T>;
    friend class Queue<T>;
    friend class Queue<T>;
    friend class MyStack<T>;
public:
    explicit Element(T data) {
        next = prev = nullptr;
        info = data;
    }

    Element(Element<T> *Next, Element<T> *Prev, T data) {
        next = Next;
        prev = Prev;
        info = data;
    }

    Element(const Element<T> &el) {
        next = el.next;
        prev = el.prev;
        info = el.info;
    }

    template<class T1>
    friend ostream &operator<<(ostream &s, Element<T1> &el);
};

template<class T1>
ostream& operator<<(ostream& s, Element<T1>& el)
{
    s << el.info;
    return s;
}

template<class T>
class LinkedList {
protected:
    Element<T> *head;
    Element<T> *tail;
    int count;
public:
    LinkedList() {
        head = tail = nullptr;
        count = 0;
    }

    int getCount() const {
        return count;
    }

    virtual Element<T> *pop() = 0;

    virtual Element<T> *push(T value) = 0;

    virtual Element<T> &operator[](int index) {
        auto curr = head;
        while (index--) {
            curr = curr->next;
        }
        return *curr;
    }

    virtual bool isEmpty() {
        return (LinkedList<T>::count == 0);
    }

    template<class T1>
    friend ostream &operator<<(ostream &s, LinkedList<T1> &el);

    virtual ~LinkedList() {
        cout << "\nBase class destructor";

        auto current = head;
        while (current != nullptr) {
            auto prev = current;
            current = current->next;
            delete prev;
        }
        head = NULL;
        tail = NULL;
    }

    template<class F>
    void for_each(F f) const {
        auto current = head;
        while (current != nullptr) {
            f(current->info);
            current = current->next;
        }
    }
};

template<class T1>
ostream& operator<<(ostream& s, LinkedList<T1>& el)
{
    el.for_each([&s](auto a) { s << a << " "; });
    return s;
}

// Я так и не понял, зачем тут int N, поэтому убрал его для простоты.
template<class T>
class Stack : virtual public LinkedList<T> {
public:
    using LinkedList<T>::count;
    using LinkedList<T>::head;
    using LinkedList<T>::tail;
    using LinkedList<T>::isEmpty;
    Stack() {}

    explicit Stack<T>(int N) : LinkedList<T>() {
        if (N > 0)
            for (int i = 0; i < N; i++)
                push(0); // Maybe unsafe
    }

    virtual Element<T> *push(T value) {
        if(isEmpty())
        {
            //пустой список
            head = tail = new Element<T>(value);
        } else {
            //элементы уже есть
            tail->next = new Element<T>(value);
            //LinkedList<T>::tail->next->prev = LinkedList<T>::tail;
            tail = tail->next;
        }
        count++;
        return tail;
    }

    virtual Element<T> *pop() {
        if (isEmpty()) {
            throw std::out_of_range("Stack is empty");
        }
        Element<T> *res = tail;
        //один элемент
        if (head == tail)
            head = tail = NULL; // TODO test for memory leak
        else {
            Element<T> *current; // После цикла будет предпоследним.
            for (
                    current = head;
                    current->next != tail;
                    current = current->next
                    );
            tail = current;
            tail->next = NULL;
        }
        count--;
        return res;
    }

    virtual ~Stack() { cout << "\nStack class destructor"; }
};


template<class T>
class Queue : virtual public LinkedList<T> {
    using LinkedList<T>::count;
    using LinkedList<T>::head;
    using LinkedList<T>::tail;
    using LinkedList<T>::isEmpty;
public:
    Element<T> *pop() override {
        if (head == NULL /*length == 0*/) {
            throw Exception("error calling pop() on empty LinkedList");
        }
        T res = head->data();
        head = head->next();
        return res;
    }

    Element<T> *push(T value) override {
        auto element = new Element<T>(value);

        if (tail == nullptr)
            head = tail = element;
        else {
            tail->next = element;
            tail = element;
        }
        return element;
    }
};

template <class T>
class StackQueue : virtual protected Stack<T>, virtual protected Queue<T> {
public:
    StackQueue() : Stack<T>(), Queue<T>() {};

    T pop() {
        return Stack<T>::pop();
    }

    Element<T> *push(T value) {
        return Stack<T>::push(value);
    }

    Element<T>* pushFront(T value) {
        auto *newElemPtr = new Element<T>(value);
        if (Stack<T>::head == NULL) {
            Stack<T>::head = Stack<T>::tail = newElemPtr;
        } else {
            newElemPtr->next() = Stack<T>::head;
            Stack<T>::head = newElemPtr;
        }
        Stack<T>::length++;
        return Stack<T>::head;
    }

    T popFront() {
        return Queue<T>::pop();
    }

    Element<T> *pushBack(T value) {
        return Stack<T>::push(value);
    }

    T popBack() {
        return Stack<T>::pop();
    }


    virtual ~StackQueue() {
        std::cout << "dealloc StackQueue()\n";

        if (LinkedList<T>::head == NULL)
            return;
        auto *previous = LinkedList<T>::head;
        auto *current = LinkedList<T>::head->next();
        while (current != NULL) {
            delete previous;
            previous = current;
            current = current->next();
        }
        delete LinkedList<T>::tail;
        LinkedList<T>::head = LinkedList<T>::tail = NULL;
    }
};

template<class T>
class DoubleLinkedStack : public Stack<T> {
public:
    using LinkedList<T>::count;
    using LinkedList<T>::head;
    using LinkedList<T>::tail;
    using LinkedList<T>::isEmpty;

    DoubleLinkedStack() : Stack<T>() {}

    Element<T> *push(T value) override {
        auto elem = new Element<T>(value);
        if (isEmpty()) {
            //пустой список
            head = tail = elem;
        } else {
            //элементы уже есть
            tail->next = elem;
            elem->prev = tail;
            tail = elem;
        }
        count++;
        return tail;
    }

    Element<T> *pop() override {
        if (isEmpty())
            throw Exception("Empty Stack.");
        auto res = tail;
        auto newTail = tail->prev;
        newTail->next = nullptr;
        tail = newTail;
        return res;
    }

    void insert(Element<T> *after, T value) {
        auto elem = new Element<T>(value);
        if (after == nullptr) {
            elem->next = head;
            head->prev = elem;
            head = elem;
        } else {
            auto before = after->next;

            elem->next = head;
            head->prev = elem;

            before->prev = elem;
            elem->next = before;
        }
    }

    void remove(Element<T> *node) {
        if (node == head && head == tail) {
            head = tail = nullptr;
        }
        if (node->prev != nullptr) {
            if (node->next != nullptr) {
                node->prev->next = node->next;
                node->next->prev = node->prev;
                return;
            }
            node->prev->next = nullptr;
        } else {
            node->next->prev = nullptr;
        }
    }

    Element<T> *find(const T &value) {
        for (auto it = head; it != nullptr; it = it->next) {
            if (value == it->info)
                return it;
        }
        return nullptr;
    }

    DoubleLinkedStack<T> filter(auto predicate) {
        DoubleLinkedStack<T> res;
        auto cur = head;
        while (cur != nullptr) {
            if (predicate(cur->info)) {
                res.push(cur->info);
            }
            cur = cur->next;
        }
        return res;
    }

    DoubleLinkedStack<T> filterRec(auto predicate, Element<T> * current = nullptr) {
        if (current == nullptr)
            return filterRec(predicate, tail);
        auto res = current->prev ? filterRec(current->prev) : DoubleLinkedStack<T>();
        if (predicate(current->info))
            res.push(current->info);
        return res;
    }
};

class Patient {
public:
    friend ostream &operator<<(ostream &os, const Patient &patient) {
        return os << "surname: " << patient.surname << " name: " << patient.name << " date: " << patient.date << " phone: "
           << patient.phone << " address: " << patient.address << " card: " << patient.card << " blood: "
           << patient.blood;
    }

    string surname, name, date, phone, address, card, blood;
};

template<class T>
class MyStack : protected DoubleLinkedStack<T> {
    using Stack<T>::head;
    using Stack<T>::tail;
    using Stack<T>::isEmpty;
    using Stack<T>::count;
public:
    T* find(auto predicate) {
        auto cur = head;
        while (cur != nullptr) {
            if (predicate(cur->info)) {
                return &cur->info;
            }
            cur = cur->next;
        }
        return nullptr;
    }

    MyStack<T> myFilter(auto predicate) {
        MyStack res;
        auto cur = head;
        while (cur != nullptr) {
            if (predicate(cur->info)) {
                res.push(cur->info);
            }
            cur = cur->next;
        }
        return res;
    }

    Element<T> *push(T value) override {
        auto elem = new Element<T>(value);
        if (isEmpty()) {
            //пустой список
            head = tail = elem;
        } else {
            //элементы уже есть
            head->prev = elem;
            elem->next = head;
            head = elem;
        }
        count++;
        return head;
    }
    // pop старый


    T* findByFamily(string family) {
        return find([&family](auto value) { return value.surname == family; });
    }

    MyStack<T> bloodTypeFilter(string bloodType) {
        return myFilter([&bloodType](auto value) { return value.blood == bloodType; });
    }
};

template<class T>
void save(const LinkedList<T> & lst, const string & filename) {
    ofstream out(filename);
    out << lst.getCount() << "\n";
    lst.for_each([&out](auto i) { out << i << " "; });
    out.close();
}

template<class T>
DoubleLinkedStack<T> load(const string & filename) {
    DoubleLinkedStack<T> res;
    ifstream in(filename);
    int cnt;
    in >> cnt;
    for (int i = 0; i < cnt; ++i) {
        T f;
        in >> f;
        res.push(f);
    }
    in.close();
    return res;
}

ostream& my_manip2(ostream& out) {
    return out << hex;
}

int main() {
    LinkedList<int>* example = new DoubleLinkedStack<int>();
    for (int i = 0; i < 32; ++i) {
        example->push(i);
    }
    save(*example, "out.txt");
    auto another = load<int>("out.txt");
    my_manip2(cout) << another << "\n";
    if (auto it = dynamic_cast<DoubleLinkedStack<int>*>(example)) {
        cout << "cast successful\n";
    }
    /*
    if (true) {
        Stack<double> S;
        for (int i = 0; i < 10; i++)
            S.push(i);
        S.insert(3.5, S[3]);
        cout << S;
        cout << "\n";
//cout<<S.Find_R(5.5, S.head);
    }*/
    delete example;
    return 0;
}