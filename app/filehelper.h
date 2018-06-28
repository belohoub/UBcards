#include <QObject>

class FileHelper: public QObject
{
    Q_OBJECT
public:
    explicit FileHelper(QObject *parent = 0);


    Q_INVOKABLE QString saveToFile(const QString &content, const QString &extension);
};
