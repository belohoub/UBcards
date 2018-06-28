#ifndef HISTORYMODEL_H
#define HISTORYMODEL_H

#include <QAbstractListModel>
#include <QSettings>
#include <QQuickImageProvider>

class HistoryModel: public QAbstractListModel, public QQuickImageProvider
{
    Q_OBJECT
public:
    enum Roles {
        RoleText,
        RoleType,
        RoleImageSource,
        RoleTimestamp
    };

    HistoryModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void add(const QString &text, const QString &type, const QImage &image);
    Q_INVOKABLE void remove(int index);

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    QString m_cacheLocation;
    mutable QSettings m_settings;
};

#endif
