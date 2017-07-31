#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QDebug>
#include <QCoreApplication>
#include <QFileInfo>
#include <QIODevice>
#include <assert.h>

enum class NodeType : uint32_t
{
    NONE,
    CHANGE,
    _INSERT,
    _DEL,
    UNDO,
    REDO
};

class Node
{
public:
    Node()
        : prev(NULL)
        , next(NULL)
        , type(NodeType::NONE)
        , after(0)
        , range(0)
        , dist(0)
    {
    }

    void remove(Node*& first)
    {
        if(prev)
            prev->next = next;
        if(next)
            next->prev = prev;

        if(first == this)
            first = next;
    }

    void insertBefore(Node*& first, Node* n)
    {
        n->next = this;
        n->prev = prev;
        if(prev)
            prev->next = n;

        prev = n;

        if(first == this)
            first = n;
    }

    void insertAfter(Node* n)
    {
        n->prev = this;
        n->next = next;
        if(next)
            next->prev = n;

        next = n;
    }

    void print()
    {
        char t = '\0';
        switch(type)
        {
        case NodeType::NONE:
            t = 'n';
            break;
        case NodeType::CHANGE:
            t = 'a';
            break;
        default:
            break;
        }
        fprintf(stderr, "[%c, %i, %i, %i]", t, after, range, dist);
    }

    bool equal(const Node* n)
    {
        return n->type == type && n->range == range && n->after == after && n->dist == dist;
    }

    Node* prev;
    Node* next;
    NodeType type;
    uint32_t after;
    uint32_t range;
    uint32_t dist;
};

class Check
{
public:
    Check()
        : head(NULL)
        , tail(NULL)
    {

    }
    bool pop(Node& n)
    {
        Node* res = head;
        if(res != NULL)
            head = head->next;
        else
            tail = NULL;
        if(res != NULL)
        {
            n = *res;
            delete res;
        }
        return res != NULL;
    }
    void push(NodeType type, uint32_t after, uint32_t range, uint32_t dist = 0)
    {
        Node* n = new Node();
        n->type = type;
        n->range = range;
        n->after = after;
        n->dist = dist;

        if(head == NULL)
        {
            head = tail = n;
        }
        else
        {
            tail->insertAfter(n);
            tail = n;
        }
    }

    void clear()
    {
        head = tail = NULL;
    }
    Node* head;
    Node* tail;
};

class Change
{
public:
    Change(uint32_t max)
        : check()
        , max_pos(max)
        , first(NULL)
        , current(NULL)
        , current_pos(0)
    {
        clear();
    }

    ~Change()
    {
        clear();
        delete first;
    }

    uint32_t nextPos(Node* start, Node* next)
    {
        return current_pos + start->range + start->dist;

    }

    uint32_t prevPos(Node* start, Node* prev)
    {
        return current_pos - prev->range - prev->dist;
    }

    void moveRight()
    {
        Node* start = current;
        Node* next = start->next;
        if(next == NULL)
            return;
        current = next;
        current_pos = nextPos(start, next);
    }

    void moveLeft()
    {
        Node* start = current;
        Node* prev = start->prev;
        if(prev == NULL)
            return;
        current = prev;
        current_pos = prevPos(start, prev);
    }

    void findPos(uint32_t pos)
    {
        Node* start = current;

        if(start != NULL)
        {
            while(pos > current_pos)
            {
                Node* next = start->next;
                if(next == NULL)
                    goto END;
                uint32_t next_pos = nextPos(start, next);
                if(next_pos >= pos)
                    goto END;
                start = next;
                current = start;
                current_pos = next_pos;
            }

            while(pos <= current_pos)
            {
                Node* prev = start->prev;
                if(prev == NULL)
                    goto END;
                uint32_t prev_pos = prevPos(start, prev);
                start = prev;
                current = start;
                current_pos = prev_pos;
            }

            END:
            {
            }
        }
    }

    void insertAt(uint32_t line, uint32_t range)
    {
        findPos(line);
        Node* c = current;
        uint32_t cp = current_pos;
        uint32_t endPos = cp + c->range;
        uint32_t insertPos = endPos + c->dist;

        /* before first */
        if(line <= cp)
        {

        }
        /* hit */
        else
        if(line <= endPos)
        {
            /* split node */
            Node* n = new Node();
            n->type = c->type;
            n->range = endPos - line + 1;
            n->dist = c->dist;
            c->dist = range;
            c->range -= n->range;
            n->after = c->after + c->range;
            c->insertAfter(n);

            if(c->range == 0)
            {
                Node* prev = c->prev;
                if(prev)
                {
                    if(prev->after + prev->range == c->after)
                    {
                        moveLeft();
                        prev->dist += c->dist;
                        c->remove(first);
                        delete c;
                    }
                    else
                    {
                        moveLeft();
                        uint32_t r = c->after - prev->after + prev->range;
                        /* TODO insert to change in del */
                    }
                }
            }
        }
        /* insert */
        else
        if(line <= insertPos)
        {
            goto AFTER;
        }
        /* after last */
        else
        {
            AFTER:
            c->dist += range;
        }
    }

    bool del(uint32_t& line, uint32_t& range)
    {
        Node* c = current;
        uint32_t cp = current_pos;
        uint32_t endPos = cp + c->range;
        uint32_t insertPos = endPos + c->dist;
        /* before first */
        if(line <= cp)
        {
        }
        /* hit */
        else
        if(line <= endPos)
        {
            uint32_t o = range;
            uint32_t end = line + range - 1;
            uint32_t ov = 0;

            if(end > endPos && c->dist != 0)
            {
                uint32_t r = end - endPos;
                r = r > c->dist ? c->dist : r;
                range -= r;
                c->dist -= r;
            }

            if(end > insertPos)
                ov = end - insertPos;

            /* split end */
            if(end < endPos)
            {
                uint32_t r = endPos - end;
                Node* n = new Node();
                n->type = c->type;
                n->range = r;
                c->range -= r;
                n->after = c->after + c->range;
                n->dist = c->dist;
                c->dist = 0;
                c->insertAfter(n);
            }

            uint32_t r = range - ov;
            r = c->range > r ? r : c->range;
            c->range -= r;
            range -= r;

            line = insertPos + 1 - (o - range);

            goto REM;
        }
        /* insert */
        else
        if(line <= insertPos)
        {
            uint32_t r = insertPos - line + 1;
            uint32_t o = range;
            range = r > range ? 0 : range - r;
            c->dist -= (o - range);

            line = insertPos + 1 - r;

            goto REM;
        }
        /* after last */
        else
        {
            range = 0;
        }

        return true;

        REM:

        if(c->range == 0 && c->dist == 0)
        {
            Node* n = c->prev;
            Node* next = c->next;
            bool res = true;
            if(!n)
            {
                current = next;
                current_pos = 0;

                res = false;
            }
            else
            {
                moveLeft();
            }
            c->remove(first);
            delete c;
            return res;
        }

        return true;
    }

    void deleteAt(uint32_t line, uint32_t range)
    {
        findPos(line);

        while(range != 0)
        {
            bool m = del(line, range);
            if(m && range != 0)
                moveRight();
        }
    }

    void change(uint32_t& line, uint32_t& range)
    {
        Node* c = current;
        uint32_t cp = current_pos;
        uint32_t endPos = cp + c->range;
        uint32_t insertPos = endPos + c->dist;
        /* before first */
        if(line <= cp)
        {

        }
        /* hit */
        else
        if(line <= endPos)
        {
            Node* nn = NULL;
            if(c->type != NodeType::CHANGE)
            {
                bool se = line + range - 1 < endPos;
                if(line == cp + 1)
                {
                    c->type = NodeType::CHANGE;
                    nn = c;
                }
                else
                {
                    /* split front */
                    Node* n = new Node();
                    uint32_t r = endPos - line + 1;
                    c->range -= r;
                    n->dist = c->dist;
                    c->dist = 0;
                    n->type = NodeType::CHANGE;
                    n->range = r;
                    n->after = c->after + c->range;

                    c->insertAfter(n);
                    nn = n;

                    Node* next = n->next;
                    if(!se && next && n->dist == 0 && next->type == NodeType::CHANGE && n->after + n->range == next->after)
                    {
                        n->dist = next->dist;
                        n->range += next->range;
                        next->remove(first);
                        delete next;
                    }
                    else
                    {
                        moveRight();
                    }

                }

                if(se)
                {
                    /* split end */
                    Node* n = new Node();
                    n->type = NodeType::NONE;
                    n->range = endPos - line - range + 1;
                    nn->range -= n->range;
                    n->after = nn->after + nn->range;
                    n->dist = nn->dist;
                    nn->dist = 0;
                    nn->insertAfter(n);
                    moveRight();


                    Node* prev = nn->prev;
                    if(prev && prev->dist == 0 && prev->type == NodeType::CHANGE && prev->after + prev->range == nn->after)
                    {
                        prev->range += nn->range;
                        nn->remove(first);
                        delete nn;
                    }
                    else
                    {
                        moveRight();
                    }

                }
            }
            else
            {
            }
            goto INSERT;
        }
        /* insert */
        else
        if(line <= insertPos)
        {
            INSERT:
            uint32_t r = insertPos - line + 1;
            uint32_t o = range;
            range = r > range ? 0 : range - r;
            line += (o - range);
        }
        /* after last */
        else
        {
            range = 0;
        }
    }

    void changeAt(uint32_t line, uint32_t range)
    {
        findPos(line);

        while(range != 0)
        {
            change(line, range);
            if(range != 0)
                moveRight();
        }
    }

    void addCheck(NodeType type, uint32_t after, uint32_t range, uint32_t dist = 0)
    {
        check.push(type, after, range, dist);
    }

    void checkIt()
    {
        Node* start = first;
        Node c;

        while(start != NULL && check.pop(c))
        {
            if(!start->equal(&c))
                assert(false);
            start = start->next;
        };
        assert(start == NULL && check.pop(c) == false);
    }

    void clear()
    {
        check.clear();
        Node* start = first;
        while(start != NULL)
        {
            Node* prev = start;
            start = start->next;
            delete prev;
        };
        current_pos = 0;
        Node* n = new Node();
        n->type = NodeType::NONE;
        n->range = max_pos;
        first = n;
        current = n;
    }

    void print()
    {
        fprintf(stderr, "print change: \n");
        bool f = true;
        Node* start = first;
        while(start != NULL)
        {
            if(f)
                f = false;
            else
                fprintf(stderr, ", ");
            start->print();
            start = start->next;
        };
        fprintf(stderr, "\n");
    }

    Check check;
    uint32_t max_pos;
    Node* first;
    Node* current;
    uint32_t current_pos;
};

class Doc
{
    class Item
    {
    public:
        Item()
            : pos(0)
            , type(NodeType::NONE)
        {

        }
        uint32_t pos;
        NodeType type;
    };
public:
    Doc(uint32_t size)
        : change(size)
        , del(NULL)
        , items(NULL)
        , num_items(size)
        , num_doc(size)
    {
        clear();
    }

    ~Doc()
    {
        clear();
        free(items);
        free(del);
    }

    void insertAt(uint32_t line, uint32_t range)
    {
        assert(line > 0);
        assert(num_items >= line - 1);
        uint32_t pos = line - 1;
        uint32_t n = num_items - pos;
        num_items += range;
        items = (Item*)realloc(items, num_items * sizeof(Item));
        assert(items != NULL);
        memmove(items + num_items - n, items + pos, n * sizeof(Item));
        for(uint32_t i = pos; i < pos + range; i++)
            items[i].type = NodeType::_INSERT;

        change.insertAt(line, range);
    }

    void deleteAt(uint32_t line, uint32_t range)
    {
        assert(line > 0);
        assert(num_items >= line);
        assert(num_items >= line + range - 1);

        uint32_t pos = line - 1;
        for(uint32_t i = pos; i < pos + range; i++)
        {
            if(items[i].type == NodeType::NONE ||
               items[i].type == NodeType::CHANGE)
                del[items[i].pos] = true;
        }

        uint32_t n = num_items - pos - range;
        memmove(items + pos, items + num_items - n, n * sizeof(Item));
        num_items -= range;
        items = (Item*)realloc(items, num_items * sizeof(Item));
        assert(items != NULL);

        change.deleteAt(line, range);
    }

    void changeAt(uint32_t line, uint32_t range)
    {
        assert(line > 0);
        assert(num_items >= line);
        assert(num_items >= line + range - 1);
        uint32_t pos = line - 1;
        for(uint32_t i = pos; i < pos + range; i++)
            if(items[i].type == NodeType::NONE)
                items[i].type = NodeType::CHANGE;

        change.changeAt(line, range);
    }

    bool compare(Doc* d)
    {
        if(d->num_items != num_items)
            return false;

        for(uint32_t i = 0; i < num_items; i++)
        {
            if(items[0].type != d->items[0].type)
                return false;
        }
        return true;
    }

    void print(NodeType type, uint32_t after, uint32_t range)
    {
        char t = '\0';
        switch(type)
        {
        case NodeType::_INSERT:
            t = 'i';
            break;
        case NodeType::CHANGE:
            t = 'a';
            break;
        case NodeType::NONE:
            t = 'n';
            break;
        default:
            break;
        }
        fprintf(stderr, "[%c, %i, %i]", t, after, range);
    }

    void print()
    {
        fprintf(stderr, "print doc: \n");
        bool f = true;
        if(items == NULL)
            return;
        NodeType t = items[0].type;
        uint32_t start = 0;
        uint32_t range = 0;
        for(uint32_t i = 0; i < num_items; i++)
        {
            if(items[i].type != t)
            {
                if(t != NodeType::NONE)
                {
                    if(f)
                        f = false;
                    else
                        fprintf(stderr, ", ");
                    print(t, start, range);
                }
                t = items[i].type;
                start = i;
                range = 0;
            }
            range++;
        }

        if(t != NodeType::NONE)
        {
            if(!f)
                fprintf(stderr, ", ");
            print(t, start, range);
        }
        fprintf(stderr, "\n");
    }

    void validate()
    {
        if(items == NULL)
            return;
#ifdef PRINT
        fprintf(stderr, "validate doc: \n");
        print();
        change.print();
#endif

        Node* s = change.first;
        uint32_t cp = 0;
        uint32_t pr = 0;

        Item* c = (Item*)malloc(Size()* sizeof(Item));
        bool * d = (bool*)calloc(num_doc, sizeof(bool));
        assert(c != NULL);
        assert(d != NULL);
        memcpy(c, items, Size()* sizeof(Item));
        memcpy(d, del, num_doc* sizeof(bool));

        while(s)
        {
            NodeType t = s->type;
            for(uint32_t i = 0; i < s->range; i++)
            {
                assert(c[cp + i].type == t);
                c[cp + i].type = NodeType::NONE;
            }

            if(s->dist)
            {
                for(uint32_t i = s->range; i < s->range + s->dist; i++)
                {
                    assert(c[cp + i].type == NodeType::_INSERT);
                    c[cp + i].type = NodeType::NONE;
                }
            }

            if(s->after > pr)
            {
                uint32_t n = s->after - pr;
                for(uint32_t i = pr; i < pr + n; i++)
                {
                    assert(d[i] != false);
                    d[i] = false;

                }
            }
            pr = s->after + s->range;
            cp += s->range + s->dist;
            s = s->next;
        }

        for(uint32_t i = 0; i < num_doc; i++)
            assert(d[i] == false);

        for(uint32_t i = 0; i < Size(); i++)
            assert(c[i].type == NodeType::NONE);

        free(c);
        free(d);
    }

    void clear()
    {
        change.clear();
        if(del != NULL)
        {
            free(del);
            del = NULL;
        }
        if(items != NULL)
        {
            free(items);
            items = NULL;
        }
        num_items = num_doc;
        items = (Item*)malloc(num_doc* sizeof(Item));
        del = (bool*)calloc(num_doc, sizeof(bool));
        assert(items != NULL);
        assert(del != NULL);
        for(uint32_t i = 0; i < num_doc; i++)
        {
            items[i].pos = i;
            items[i].type = NodeType::NONE;
        }
    }

    uint32_t Size()
    {
        return num_items;
    }

    Change change;
    bool* del;
    Item* items;
    uint32_t num_items;
    uint32_t num_doc;
};

void handle(QFile& file)
{
    uint32_t max = 100;
    uint32_t step = 0;

    QTextStream out(&file);
    Doc docA(max);

    // TODO write out commands

    uint32_t max_ops = 50;
#ifdef PRINT
    fprintf(stderr, "start run %i:\n", j);
#endif
    uint32_t ops = (random() % max_ops) + 1;

    for(uint32_t i = 0; i < ops; i++)
    {
        RETRY:
        uint32_t op = (random() + 1) % 6;
        uint32_t line = (random() % docA.Size()) + 1;
        uint32_t range = (random() % docA.Size()) + 1;

        if(line + range >= docA.Size())
        {
            if(docA.Size() < 5)
            {
#ifdef PRINT
                fprintf(stderr, "docA.clear();\n");
#endif
                docA.clear();
            }
            goto RETRY;
        }

        switch((NodeType)op)
        {
        case NodeType::UNDO:
            out << "Z+CTRL" << endl;
            break;
        case NodeType::REDO:
            out << "Y+CTRL" << endl;
            break;
        case NodeType::NONE:
            goto RETRY;
        case NodeType::_INSERT:
            if(range > 2000)
                goto RETRY;
#ifdef PRINT
            fprintf(stderr, "docA.insertAt(%i, %i);\n", line, range);
#endif
            docA.insertAt(line, range);
            out << step << "+STEP" << endl;
            out << range << "+RDLN" << endl;
            out << line << "+GOLN" << endl;
            out << "V+CTRL" << endl;
            step++;
            break;
        case NodeType::CHANGE:
#ifdef PRINT
            fprintf(stderr, "docA.changeAt(%i, %i);\n", line, range);
#endif
            docA.changeAt(line, range);
            out << step << "+STEP" << endl;
            out << line << "+GOLN" << endl;
            for(uint32_t i = 0; i < range; i++)
            {
                out << "DOWN+SHIFT" << endl;
            }
            out << range << "+RDLN" << endl;
            out << "V+CTRL" << endl;
            step++;
            break;
        case NodeType::_DEL:
#ifdef PRINT
            fprintf(stderr, "docA.deleteAt(%i, %i);\n", line, range);
#endif
            docA.deleteAt(line, range);
            out << step << "+STEP" << endl;
            out << line << "+GOLN" << endl;
            for(uint32_t i = 0; i < range; i++)
            {
                out << "DOWN+SHIFT" << endl;
            }
            out << "X+CTRL" << endl;
            step++;
            break;
        default:
            break;

        }
    }

    docA.validate();
    docA.clear();
    out << step << "+STEP" << endl;
    out << "0+GOLN" << endl;
    out << "a" << endl;
    out << "S+CTRL" << endl;

}

int getKey(QString s, QStringList& keys, bool& wait)
{
    if(s.size() > 1)
    {
        wait = false;
        switch(keys.indexOf(s))
        {
        case 0:
            return Qt::Key_Up;
        case 1:
            return Qt::Key_Down;
        case 2:
            return Qt::Key_Left;
        case 3:
            return Qt::Key_Right;
        case 4:
            return Qt::Key_Tab;
        case 5:
            wait = true;
            return 0x0A;
        case 6:
            wait = true;
            return Qt::Key_Delete;
        case 7:
            wait = true;
            return Qt::Key_Backspace;
        case 8:
            return Qt::Key_Home;
        case 9:
            return Qt::Key_End;
        case 10:
            return Qt::Key_PageUp;
        case 11:
            return Qt::Key_PageDown;
        default:
            break;
        }
    }

    wait = true;
    return s.constData()[0].toLatin1();
}

Qt::KeyboardModifier getModifier(QString s, QStringList& modifiers)
{
    if(s.size() == 0)
        return Qt::NoModifier;
    switch(modifiers.indexOf(s))
    {
    case 0:
        return Qt::ControlModifier;
    case 1:
        return Qt::ShiftModifier;
    case 2:
        return Qt::AltModifier;
    case 3:
        return static_cast<Qt::KeyboardModifier>(1);
    case 4:
        return static_cast<Qt::KeyboardModifier>(2);
    case 5:
        return static_cast<Qt::KeyboardModifier>(4);
    case 6:
        return static_cast<Qt::KeyboardModifier>(8);
    default:
        break;
    }

    return Qt::NoModifier;
}

void reduceFile(QFile& inFile, QFile& outFile, int32_t target, int nomerge)
{
    QStringList keys;
    QStringList modifiers;
    QTextStream out(&outFile);
    QTextStream in(&inFile);
    int32_t step = 0;
    bool ignore = false;
    bool down_shift = false;
    bool reduced = false;
    keys << "UP" << "DOWN" << "LEFT" << "RIGHT" << "TAB" << "RETURN" << "DEL" << "BACKSPACE" << "POS1" << "END" << "PAGEUP" << "PAGEDOWN";
    modifiers << "CTRL" << "SHIFT" << "ALT" << "GOLN" << "GOCL" << "RDLN" << "STEP";

    in.seek(0);
    while(!in.atEnd())
    {
        QString line = in.readLine();
        QString first;
        QString second;
        if(line.size() > 2 &&
           line.count('+') &&
           (line.constData()[0] != '+' || line.constData()[1] == '+'))
        {
            if(line.constData()[0] == '+')
            {
                line.data()[0] = 0;
                QStringList l = line.split("+");
                first = "+";
                second = l.at(1);
            }
            else
            {
                QStringList l = line.split("+");
                first = l.at(0);
                second = l.at(1);
            }
        }
        else
        {
            first = line;
        }

        if(first.size() != 0)
        {
            bool wait;
            bool ds;
            int k = getKey(first, keys, wait);
            Qt::KeyboardModifier m = getModifier(second, modifiers);
            ds = k == Qt::Key_Down && m == Qt::ShiftModifier;
            if(nomerge == 0 && down_shift && ds)
            {
                reduced = true;
                continue;
            }
            down_shift = ds;
            if(m == static_cast<Qt::KeyboardModifier>(8))
            {
                if(!ignore)
                {
                    ignore = step == target;
                    reduced |= ignore;
                }
                else
                {
                    ignore = false;
                    target--;
                }
                if(!ignore)
                {
                    out << step << "+STEP" << endl;
                    step++;
                }
            }
            else
            if(!ignore)
            {
                out << line << endl;
            }
            else
            {
                if(m == Qt::ControlModifier && k == 'S')
                {
                    qCritical() << "Cannot remove last step";
                    return;
                }

            }
        }
    }

    if(!reduced)
        qCritical() << "Nothing to reduce";
}

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    QCommandLineParser parser;
    QCommandLineOption nomerge("n", QCoreApplication::translate("main", "Do not merge commands"));
    QCommandLineOption rand("t", QCoreApplication::translate("main", "Create random input files"));
    parser.addPositionalArgument("output", QCoreApplication::translate("main", "The output file to use"));
    QCommandLineOption seed(QStringList() << "s" << "seed",
            QCoreApplication::translate("main", "The seed to use"),
            QCoreApplication::translate("main", "seed"));

    QCommandLineOption reduce(QStringList() << "r" << "reduce",
            QCoreApplication::translate("main", "Remove the first step greater or equal from the input file"),
            QCoreApplication::translate("main", "reduce"));

    parser.addOption(nomerge);
    parser.addOption(rand);
    parser.addOption(reduce);
    parser.addOption(seed);
    parser.addHelpOption();
    parser.process(a);
    if(parser.isSet(seed))
    {
        srandom(parser.value(seed).toInt());
    }

    const QStringList args = parser.positionalArguments();
    QString output = args.length() == 0 ? "" : args.at(0);
    QFile file;

    if(parser.isSet(reduce))
    {
        QFile outfile;
        file.setFileName(QFileInfo(output).absoluteFilePath());
        if(output.size() == 0 || !file.open(QFile::ReadWrite))
        {
            qCritical() << "Failed to open target file.";
            return EXIT_FAILURE;
        }

        outfile.open(1, QFile::WriteOnly);

        reduceFile(file, outfile, parser.value(reduce).toInt(), parser.isSet(nomerge));

        return EXIT_SUCCESS;
    }

    if(output.size() == 0)
    {
        file.open(1, QFile::WriteOnly);
    }
    else
    {
        file.setFileName(QFileInfo(output).absoluteFilePath());
        if(!file.open(QFile::ReadWrite))
        {
            qCritical() << "Failed to open target file.";
            return EXIT_FAILURE;
        }
        file.resize(0);
    }

    if(parser.isSet(rand))
    {
        QTextStream out(&file);
        for(uint32_t i = 0; i < 100; i++)
        {
            char tmp[32];
            sprintf(tmp, "%s%li", "r", random());
            out << tmp << endl;
        }
    }
    else
    {
        handle(file);
    }

    return EXIT_SUCCESS;
}
