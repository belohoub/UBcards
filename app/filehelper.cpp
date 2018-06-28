#include "filehelper.h"

#include <QFile>
#include <QStandardPaths>
#include <QDebug>

FileHelper::FileHelper(QObject *parent):
    QObject(parent)
{

}

QString FileHelper::saveToFile(const QString &content, const QString &extension)
{
    QString path = QStandardPaths::standardLocations(QStandardPaths::CacheLocation).first() + "/exportFile." + extension;
    QFile f(path);
    if (!f.open(QFile::WriteOnly | QFile::Truncate)) {
        qDebug() << "Error opening file:" << path;
        return QString();
    }
    f.write(content.toUtf8());
    f.close();
    return path;
}
