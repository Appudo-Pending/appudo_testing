#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QMouseEvent>
#include <QWebView>

class DebugWebPage : public QWebPage
{
public:
    DebugWebPage()
        : QWebPage()
    {

    }

    virtual void javaScriptConsoleMessage( const QString & message, int lineNumber, const QString & sourceID)
    {
        (void)lineNumber;
        (void)sourceID;
        fprintf(stderr, "%s:%i - %s\n", sourceID.toUtf8().data(), lineNumber, message.toUtf8().data());
    }

};

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

    void load(bool isGo = false);
    bool loadInitial(QString initial);
    void setCommands(QString commands);
    void setNoSteps(bool nosteps);
    void setJsOut(bool isout);
private slots:
    void on_loadButton_clicked();
    void on_lpatchButton_clicked();
    void on_patchButton_clicked();
    void on_recordButton_clicked();

private:
    void handle(bool kill = true);
    void tryPatch(bool kill);
    void record();
    bool equal(QString A, QString B);
    bool patch(QString input, QByteArray diff, QString &out);
    void doPatch();
    void setFocus();
    void gotoLine(int line);
    void gotoColumn(int col);
    void randomLinesToCipboard(int num);
    void doProcess();
    void doExit(bool error = true);
    bool waitChanged(bool v = true);
    bool waitChanged(bool v, int timeout);
    void doWait();
    QByteArray getDiff();
    QString getDiffText();
    QString getText();
    bool setText(QString txt);
    void sendMouseEvent(QObject* targetObj, QMouseEvent::Type type, const QPoint& pnt) const;
    void sendMouseClick(QObject* targetObj, const QPoint& pnt) const;
    void emulateMouseClick(const QPoint& pnt) const;

    void emulateKeyPress(const int key, Qt::KeyboardModifier modifier = Qt::NoModifier) const;
    void sendKeyEvent(QObject* targetObj, QEvent::Type type, const int key, Qt::KeyboardModifier modifier = Qt::NoModifier) const;
    void sendKeyPress(QObject* targetObj, const int key, Qt::KeyboardModifier modifier = Qt::NoModifier) const;

    int getKey(QString s, QStringList& keys, bool &wait);
    Qt::KeyboardModifier getModifier(QString s, QStringList& modifiers);

    bool keyToString(QKeyEvent *kev, QString& out);
    bool modifierToString(QKeyEvent* kev, QString& out);
    bool eventToString(QKeyEvent* kev, QString& out);

    bool eventFilter(QObject * watched, QEvent * event);

    QString encode(QString txt);

    Ui::MainWindow *ui;
    QWebView       *webView;
    QString         commands;
    QString         initial;
    QString         orig;
    QFile           file;
    QTextStream     erecord;
    bool            nosteps = false;
};

#endif // MAINWINDOW_H
