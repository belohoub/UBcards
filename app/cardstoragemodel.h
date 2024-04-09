/*****************************************************************************
 * Copyright: 2024 Jan Belohoubek <belik@sfortelem.cz>                       *
 *                                                                           *
 * This file is part of UBCards                                              *
 *                                                                           *
 * This prject is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * This project is distributed in the hope that it will be useful,           *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                           *
 ****************************************************************************/

#ifndef CARDSTORAGE_MODEL_H
#define CARDSTORAGE_MODEL_H

#include <QAbstractListModel>
#include <QSettings>
#include <QQuickImageProvider>

class CardStorageModel: public QAbstractListModel, public QQuickImageProvider
{
    Q_OBJECT
public:
    enum Roles {
        RoleText,
        RoleType,
        RoleName,
        RoleCathegory,
        RoleImageSource,
        RoleUUID,
        RoleTimestamp
    };
    
    CardStorageModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString add(const QString &text, const QString &type, const QString &name, const QString &category, const QImage &image);
    bool setCardById(const QString &id, const QString &text, const QString &type, const QString &name, const QString &category);
    Q_INVOKABLE void remove(QString id);

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    QString m_storageLocation;
    mutable QSettings m_settings;
};

#endif // CARDSTORAGE_MODEL_H
