#include <QApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>

#include "mainwindow.h"

int main(int argc, char *argv[])
{
    Q_INIT_RESOURCE(application);  // 强制初始化资源文件 application.qrc

    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("QtProject");
    QCoreApplication::setApplicationName("Application Example");
    QCoreApplication::setApplicationVersion(QT_VERSION_STR);
    QCommandLineParser parser;
    parser.setApplicationDescription(QCoreApplication::applicationName());  // 设置应用程序描述，可通过helpText()获取
    parser.addHelpOption();  // 添加帮助选项(-h, --help and -? on Windows)
    parser.addVersionOption();
    parser.addPositionalArgument("file", "The file to open.");
    parser.process(app);

    MainWindow mainWin;
    if (!parser.positionalArguments().isEmpty()) {
        mainWin.loadFile(parser.positionalArguments().first());
    }
    mainWin.show();
    return app.exec();
}
