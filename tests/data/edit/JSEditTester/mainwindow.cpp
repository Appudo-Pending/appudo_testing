#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QWebView>
#include <QWebFrame>
#include <QKeyEvent>
#include <QTimer>
#include <QFileInfo>
#include <QClipboard>
#include <syscall.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

#ifndef MFD_CLOEXEC
#define MFD_CLOEXEC 0x0001u
#endif
#ifndef MFD_ALLOW_SEALING
#define MFD_ALLOW_SEALING 0x0002u
#endif

#ifndef __NR_memfd_create
#if defined(__x86_64__)
#define __NR_memfd_create 319
#elif defined(__aarch64__)
#define __NR_memfd_create 279
#endif
#endif

extern "C" int xdelta3_patch(int32_t s, int32_t i, int32_t o);

extern "C"
{
    int memfd_create(const char *__name, unsigned int __flags)
    {
        return syscall(__NR_memfd_create, __name, __flags);
    }
}

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),
    file((QFileInfo("./record.txt").absoluteFilePath())),
    erecord(&file)
{
    ui->setupUi(this);
    webView = findChild<QWebView*>("webView");
    webView->installEventFilter(this);
    file.open(QIODevice::ReadWrite);
    webView->setPage(new DebugWebPage());
}

MainWindow::~MainWindow()
{
    delete ui;
}

int MainWindow::getKey(QString s, QStringList& keys, bool& wait)
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

Qt::KeyboardModifier MainWindow::getModifier(QString s, QStringList& modifiers)
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

void MainWindow::handle(bool kill)
{
    setFocus();
    orig = getText();
    QFile commands(QFileInfo(this->commands).absoluteFilePath());
    if(!commands.open(QIODevice::ReadOnly))
    {
        qCritical() << "Failed to open command file.";
        doExit(false);
    }

    int step = 0;
    int theLine;
    QStringList keys;
    QStringList modifiers;
    keys << "UP" << "DOWN" << "LEFT" << "RIGHT" << "TAB" << "RETURN" << "DEL" << "BACKSPACE" << "POS1" << "END" << "PAGEUP" << "PAGEDOWN";
    modifiers << "CTRL" << "SHIFT" << "ALT" << "GOLN" << "GOCL" << "RDLN" << "STEP";
    QTextStream in(&commands);
    NEXT_STEP:
    theLine = 0;
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
            int k = getKey(first, keys, wait);
            Qt::KeyboardModifier m = getModifier(second, modifiers);

            if(m > 0x10 || m == 0)
            {
                emulateKeyPress(k, m);
                if(m == Qt::ControlModifier)
                {
                    switch(k)
                    {
                    case 'S':
                        waitChanged(false);
                        break;;
                    case 'V': {
                        QClipboard* cb = QApplication::clipboard();
                        QString txt = cb->text();
                        if(txt.size())
                        {
                            waitChanged();
                        }
                        break;
                    }
                    case 'X':
                    case 'Y':
                    case 'Z':
                        usleep(50000);
                        waitChanged(true, 200);
                        break;
                    default:
                        break;
                    }
                }
                else
                if(wait)
                {
                    waitChanged();
                }
                doWait();
            }
            else
            {
                switch(static_cast<int>(m))
                {
                case 1:
                    gotoLine(first.toInt());
                    doWait();
                    break;
                case 2:
                    gotoColumn(first.toInt());
                    doWait();
                    break;
                case 4:
                    randomLinesToCipboard(first.toInt());
                    break;
                case 8:
                    if(theLine > step && !this->nosteps)
                    {
                        doPatch();
                        tryPatch(true);
                        setText(initial);
                        step = theLine;
                        qInfo() << "STEP: " << first;
                        goto NEXT_STEP;
                    }
                    break;
                default:
                    break;
                }
            }
        }
        theLine++;
    }
    commands.close();
    tryPatch(kill);
}

void MainWindow::doExit(bool error)
{
    if(error)
    {
        QTimer::singleShot(0,[](){
            qApp->exit(EXIT_FAILURE);
        });
    }
    else
    {
        QTimer::singleShot(0,[](){
            qApp->exit(EXIT_SUCCESS);
        });
    }
    /*
    while(true)
    {
        doProcess();
        sleep(1);
    }
        */
}

void stringToFile(QString name, QString data)
{
    QFile qFile(QFileInfo(name).absoluteFilePath());
    if(qFile.open(QIODevice::ReadWrite))
    {
        qFile.resize(0);
        QTextStream qStream(&qFile);
        qStream << data;
    }
}

void MainWindow::tryPatch(bool kill)
{
    QString result1 = getText();
    QByteArray diff = getDiff();
    QString result2;
    bool p = patch(orig, diff, result2);
    bool r = equal(result1, result2);

    if(!p || !r)
    {
        qCritical() << "Diff failed:";
        qCritical() << "##########";
        qCritical() << result1;
        qCritical() << "####vs####";
        qCritical() << result2;
        qCritical() << "###with###";
        qCritical() << getDiffText();
        qCritical() << "##########";

        stringToFile("./result1.txt", result1);
        stringToFile("./result2.txt", result2);

        if(kill)
        {
            doExit();
        }
    }
}

bool MainWindow::keyToString(QKeyEvent* kev, QString& out)
{
    if(kev->key() < 255)
    {
        if(kev->key() == 0x0A)
            goto RETURN;

        if(kev->modifiers() == Qt::ControlModifier)
        {
            out = QString(kev->key());
        }
        else
        {
            out = kev->text().toUtf8();
        }
        return true;
    }
    else
    {
        switch(kev->key())
        {
        case Qt::Key_Up:
            out = "UP";
            break;
        case Qt::Key_Down:
            out = "DOWN";
            break;
        case Qt::Key_Left:
            out = "LEFT";
            break;
        case Qt::Key_Right:
            out = "RIGHT";
            break;
        case Qt::Key_Tab:
            out = "TAB";
            break;
        case Qt::Key_Return:
            RETURN:
            out = "RETURN";
            break;
        case Qt::Key_Delete:
            out = "DEL";
            break;
        case Qt::Key_Backspace:
            out = "BACKSPACE";
            break;
        case Qt::Key_Home:
            out = "POS1";
            break;
        case Qt::Key_End:
            out = "END";
            break;
        case Qt::Key_PageUp:
            out = "PAGEUP";
            break;
        case Qt::Key_PageDown:
            out = "PAGEDOWN";
            break;
        default:
            return false;
        }
    }
    return true;
}

bool MainWindow::modifierToString(QKeyEvent* kev, QString& out)
{
    switch(kev->modifiers())
    {
    case Qt::ControlModifier:
        out = "CTRL";
        break;
    case Qt::ShiftModifier:
        out = "SHIFT";
        break;
    case Qt::AltModifier:
        out = "ALT";
        break;
    default:
        return false;
    }
    return true;
}

bool MainWindow::eventToString(QKeyEvent* kev, QString& out)
{
    QString kv;
    out = "";
    if(keyToString(kev, kv))
    {
        out += kv;
        if(modifierToString(kev, kv))
        {
            out += "+";
            out += kv;
        }
        return true;
    }
    return false;
}

bool MainWindow::eventFilter(QObject * watched, QEvent * event)
{
    if(watched == webView && event->type() == QEvent::KeyPress)
    {
        QKeyEvent* kev = static_cast<QKeyEvent*>(event);

        QString txt = "";
        if(eventToString(kev, txt))
        {
            erecord << txt << endl;
        }

    }

    return watched->eventFilter(watched, event);
}

void MainWindow::record()
{
    erecord.seek(0);
    file.resize(0);
}

void MainWindow::on_recordButton_clicked()
{
    record();
}

void MainWindow::on_loadButton_clicked()
{
    handle(false);
}

void MainWindow::on_lpatchButton_clicked()
{
    handle();
}

void MainWindow::on_patchButton_clicked()
{
    doPatch();
    QString result1 = getText();
    QByteArray diff = getDiff();
    QString result2;
    bool p = patch(this->orig, diff, result2);
    bool r = equal(result1, result2);

    if(!p || !r)
    {
        qCritical() << "Diff failed:";
        qCritical() << "##########";
        qCritical() << result1;
        qCritical() << "####vs####";
        qCritical() << result2;
        qCritical() << "##########";
        erecord.flush();

        stringToFile("./result1.txt", result1);
        stringToFile("./result2.txt", result2);

        doExit();
    }
    this->orig = getText();
    record();
}

void MainWindow::doProcess()
{
    qApp->processEvents();
}

bool MainWindow::waitChanged(bool v, int timeout)
{
    int start  = QDateTime::currentMSecsSinceEpoch();
    while(true)
    {
        doProcess();
        QVariant data = webView->page()->mainFrame()->evaluateJavaScript("isChanged()");

        if(data.toBool() == v)
            return true;

        if(timeout < QDateTime::currentMSecsSinceEpoch() - start)
            return false;
    }

    return false;
}

bool MainWindow::waitChanged(bool v)
{
    while(true)
    {
        doProcess();
        QVariant data = webView->page()->mainFrame()->evaluateJavaScript("isChanged()");

        if(data.toBool() == v)
            return true;
    }

    return false;
}

void MainWindow::doWait()
{
    webView->page()->mainFrame()->evaluateJavaScript("beginWait()");

    while(true)
    {
        doProcess();
        QVariant data = webView->page()->mainFrame()->evaluateJavaScript("endWait()");

        if(data.toBool() == true)
            break;
    }

}

bool MainWindow::setText(QString txt)
{
    webView->setFocus();
    QVariant data = webView->page()->mainFrame()->evaluateJavaScript("setText(\"" + txt + "\")");
    return data.toBool();
}

void MainWindow::setFocus()
{
    webView->setFocus();
    webView->page()->mainFrame()->evaluateJavaScript("setFocus()");
}

void MainWindow::randomLinesToCipboard(int num)
{
    QString txt;
    for(int i = 0; i < num; i++)
    {
        char tmp[32];
        sprintf(tmp, "%s%li\n", "random", random());
        txt += tmp;
    }

    QClipboard* cb = QApplication::clipboard();
    cb->setText(txt);
}

void MainWindow::gotoLine(int line)
{
    QString num;
    num.setNum(line);
    webView->page()->mainFrame()->evaluateJavaScript("gotoLine(" + num + ")");
    emulateKeyPress(Qt::Key_End);
    /*
    while(true)
    {
    	doProcess();
        QVariant data = webView->page()->mainFrame()->evaluateJavaScript("getLine()");
        if(data.toInt() == line)
            break;
    }
    */
}

void MainWindow::gotoColumn(int col)
{
    QString num;
    num.setNum(col);
    webView->page()->mainFrame()->evaluateJavaScript("gotoColumn(" + num + ")");
    /*
    while(true)
    {
        doProcess();
        QVariant data = webView->page()->mainFrame()->evaluateJavaScript("getColumn()");
        if(data.toInt() == col)
            break;
    }
    */
}

QString MainWindow::getText()
{
    QVariant data = webView->page()->mainFrame()->evaluateJavaScript("getText()");
    return data.toString();
}

bool MainWindow::equal(QString A, QString B)
{
    return A.compare(B) == 0;
}

void MainWindow::doPatch()
{
    emulateKeyPress('S', Qt::ControlModifier);
    waitChanged(false);
}

bool MainWindow::patch(QString input, QByteArray diff, QString& out)
{
    bool res = false;
    int inputFd = ::memfd_create("in", MFD_CLOEXEC);
    int outFd = ::memfd_create("out", MFD_CLOEXEC);
    int diffFd = ::memfd_create("diff", MFD_CLOEXEC);
    if(outFd == -1 || inputFd == -1 || diffFd == -1)
        goto END;

    {
        QFile qFile;
        if(!qFile.open(diffFd, QIODevice::ReadWrite, QFileDevice::DontCloseHandle))
            goto END;

        {
            QDataStream qStream(&qFile);
            qStream.writeRawData(diff.constData(), diff.size());
        }
    }


    {
        QFile qFile;
        if(!qFile.open(inputFd, QIODevice::ReadWrite, QFileDevice::DontCloseHandle))
            goto END;

        {
            QTextStream qStream(&qFile);
            qStream << input;
        }
    }

    if(xdelta3_patch(inputFd, diffFd, outFd) != 0)
        goto END;

    lseek(outFd, 0, SEEK_SET);

    {
        QFile qFile;
        if(!qFile.open(outFd, QIODevice::ReadWrite, QFileDevice::DontCloseHandle))
            goto END;

        {
            QTextStream qStream(&qFile);
            out = qStream.readAll();
        }
    }

    res = true;

    END:

    if(outFd != -1)
        ::close(outFd);

    if(inputFd != -1)
        ::close(inputFd);

    if(diffFd != -1)
        ::close(diffFd);

    return res;
}

QString MainWindow::getDiffText()
{
    QVariant data = webView->page()->mainFrame()->evaluateJavaScript("getDiff()");
    return data.toString();
}

QByteArray MainWindow::getDiff()
{
    QByteArray bytes;
    bytes.insert(0, getDiffText());
    return QByteArray::fromBase64(bytes);
}

void MainWindow::setCommands(QString commands)
{
    this->commands = commands;
}

void MainWindow::setNoSteps(bool nosteps)
{
    this->nosteps = nosteps;
}

void MainWindow::setJsOut(bool isout)
{
    webView->setPage(isout ? new DebugWebPage() : new QWebPage());
}

QString MainWindow::encode(QString txt)
{
    QString a;
    QString result;
    foreach(QChar current, txt)
    {
        if(current.unicode() > 254)
            goto UNICODE;
        switch(current.toLatin1())
        {
        case 0x00:
        case 0x01:
        case 0x02:
        case 0x03:
        case 0x04:
        case 0x05:
        case 0x06:
        case 0x07:
        case 0x08:
        case 0x09:
        case 0x0A:
        case 0x0B:
        case 0x0C:
        case 0x0D:
        case 0x0E:
        case 0x0F:
        case 0x7F:
        case '\\':
        case '"':
            UNICODE:
            a.setNum(current.unicode(), 16);
            for(uint32_t i = a.size(); i < 4; i++)
            {
                a.prepend("0");
            }
            a.prepend("\\u");
            result += a;
            break;
        default:
            result += current.toLatin1();
            break;
        }
    }
    return result;
}

bool MainWindow::loadInitial(QString initial)
{
    QFile file(QFileInfo(initial).absoluteFilePath());
    if(!file.open(QIODevice::ReadOnly))
        return false;
    this->initial = encode(file.readAll());
    return true;
}

void MainWindow::load(bool isGo)
{
    webView->load(QUrl::fromLocalFile(QFileInfo("./index.html").absoluteFilePath()));
    while(!setText(this->initial))
    {
        doProcess();
    }
    if(isGo)
    {
        handle();
        doExit(false);
    }
}

void MainWindow::emulateMouseClick(const QPoint& pnt) const
{
    sendMouseClick(webView, pnt);
}

void MainWindow::emulateKeyPress(const int key, Qt::KeyboardModifier modifier) const
{
    sendKeyPress(webView, key, modifier);
}


void MainWindow::sendKeyEvent(QObject* targetObj, QEvent::Type type, const int key, Qt::KeyboardModifier modifier) const
{
    char out[2];
    out[0] = key > 255 ? 0 : key;
    out[1] = '\0';

    QKeyEvent event(type, key, modifier, QString(out), false, 1);
    QApplication::sendEvent(targetObj, &event);
}

void MainWindow::sendMouseEvent(QObject* targetObj, QMouseEvent::Type type, const QPoint& pnt) const
{
    QMouseEvent event(type, pnt, Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);
    QApplication::sendEvent(targetObj, &event);
}

void MainWindow::sendKeyPress(QObject* targetObj, const int key, Qt::KeyboardModifier modifier) const
{
    sendKeyEvent(targetObj, QEvent::KeyPress, key, modifier);
    sendKeyEvent(targetObj, QEvent::KeyRelease, key, modifier);
}

void MainWindow::sendMouseClick(QObject* targetObj, const QPoint& pnt) const
{
    sendMouseEvent(targetObj, QMouseEvent::MouseMove, pnt);
    sendMouseEvent(targetObj, QMouseEvent::MouseButtonPress, pnt);
    sendMouseEvent(targetObj, QMouseEvent::MouseButtonRelease, pnt);
}
