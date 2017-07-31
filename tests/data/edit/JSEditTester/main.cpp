#include "mainwindow.h"
#include <QApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>

void msgs(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    (void)context;
    QByteArray localMsg = msg.toLocal8Bit();
    switch (type) {
    case QtCriticalMsg:
    case QtDebugMsg:
        fprintf(stderr, "%s\n", localMsg.constData());
        break;
    case QtInfoMsg:
        fprintf(stdout, "%s\n", localMsg.constData());
        break;
    case QtWarningMsg:
        break;
    case QtFatalMsg:
        fprintf(stderr, "%s\n", localMsg.constData());
        abort();
    }
}

int main(int argc, char *argv[])
{
    qInstallMessageHandler(msgs); // Install the handler
    QApplication a(argc, argv);
    MainWindow w;
    QCommandLineParser parser;
    QCommandLineOption js("c", QCoreApplication::translate("main", "Print javascript output to stderr"));
    QCommandLineOption go("g", QCoreApplication::translate("main", "Start running"));
    QCommandLineOption ignore("s", QCoreApplication::translate("main", "Ignore steps"));
    parser.addPositionalArgument("commands", QCoreApplication::translate("main", "The command file to use"));
    parser.addOption(go);
    parser.addOption(js);
    parser.addOption(ignore);
    parser.addHelpOption();
    QCommandLineOption initial(QStringList() << "i" << "initial-text",
            QCoreApplication::translate("main", "The initial text file"),
            QCoreApplication::translate("main", "initial"));
    parser.addOption(initial);


    parser.process(a);
    const QStringList args = parser.positionalArguments();

    bool isGo = parser.isSet(go);
    QString commands = args.length() == 0 ? "" : args.at(0);
    if(commands.size() == 0)
    {
        commands = "./commands.txt";
    }


    if(parser.isSet(initial))
    {
        if(!w.loadInitial(parser.value(initial)))
        {
            qCritical() << "Failed to load initial text file.";
            return EXIT_FAILURE;
        }
    }

    w.setJsOut(parser.isSet(js));
    w.setNoSteps(parser.isSet(ignore));
    w.setCommands(commands);
    w.show();
    w.load(isGo);

    return a.exec();
}
