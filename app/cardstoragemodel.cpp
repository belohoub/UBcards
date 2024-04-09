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

#include "cardstoragemodel.h"
#include <QStandardPaths>
#include <QImage>
#include <QDebug>
#include <QUuid>
#include <QFile>
#include <QDateTime>

CardStorageModel::CardStorageModel(QObject *parent):
    QAbstractListModel(parent),
    QQuickImageProvider(QQuickImageProvider::Image),
    m_storageLocation(QStandardPaths::standardLocations(QStandardPaths::HomeLocation).first() + "/.local/share/ubcards/"),
    m_settings(m_storageLocation + "wallet.ini", QSettings::IniFormat)
{
    qDebug() << "Storage in file: " << m_settings.fileName();
}

int CardStorageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_settings.value("all").toStringList().count();
}

QVariant CardStorageModel::data(const QModelIndex &index, int role) const
{
    QVariant ret;
    QString id = m_settings.value("all").toStringList().at(index.row());
    m_settings.beginGroup(id);
    switch (role) {
    case RoleText:
        ret = m_settings.value("text");
        break;
    case RoleType:
        ret = m_settings.value("type");
        break;
    case RoleUUID:
        ret = id;
        break;
    case RoleName:
        ret = m_settings.value("name");
        break;
    case RoleCathegory:
        ret = m_settings.value("category");
        break;
    case RoleImageSource:
        ret = "image://history/" + id;
        break;
    case RoleTimestamp:
        ret = m_settings.value("timestamp").toDateTime().toString();
        break;
    }

    m_settings.endGroup();
    return ret;
}


QHash<int, QByteArray> CardStorageModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleText, "text");
    roles.insert(RoleType, "type");
    roles.insert(RoleName, "name");
    roles.insert(RoleUUID, "uuid");
    roles.insert(RoleCathegory, "category");
    roles.insert(RoleImageSource, "imageSource");
    roles.insert(RoleTimestamp, "timestamp");
    return roles;
}

QString CardStorageModel::add(const QString &text, const QString &type, const QString &name, const QString &category, const QImage &image)
{
    QString id = QUuid::createUuid().toString().remove(QRegExp("[{}]"));
    if (!image.isNull()) {
        image.save(m_storageLocation + id + ".jpg");
    }

    qDebug() << "Adding new entry: " << id;
    
    beginInsertRows(QModelIndex(), 0, 0);

    QStringList all = m_settings.value("all").toStringList();
    all.prepend(id);
    m_settings.setValue("all", all);

    m_settings.beginGroup(id);
    m_settings.setValue("name", name);
    m_settings.setValue("category", category);
    m_settings.setValue("text", text);
    m_settings.setValue("type", type);
    m_settings.setValue("timestamp", QDateTime::currentDateTime());
    m_settings.endGroup();
    endInsertRows();
    
    return id;
}

void CardStorageModel::remove(QString id)
{
    if (!m_settings.value("all").toStringList().contains(id)) {
        qDebug() << "Requested invalid entry: " << id;
        return;
    }
    
    qDebug() << "Removing entry: " << id;
    
    QStringList all = m_settings.value("all").toStringList();
    int index = all.indexOf(id);
    
    beginRemoveRows(QModelIndex(), index, index);
    
    qDebug() << "Removing"  << id << "";
    
    all.removeAt(index);
    m_settings.remove(id);
    m_settings.setValue("all", all);
     
    QFile f(m_storageLocation + id + ".jpg");
    f.remove();
    
    endRemoveRows();
}


void CardStorageModel::setCardById(const QString &id, const QString &text, const QString &type, const QString &name, const QString &category)
{
    if (!m_settings.value("all").toStringList().contains(id)) {
        qDebug() << "Requested invalid entry: " << id << ", " << name;
        return;
    }
    
    qDebug() << "Updating entry: " << id;
    
    m_settings.beginGroup(id);
    
    m_settings.setValue("text", text);
    m_settings.setValue("type", type);
    m_settings.setValue("name", name);
    m_settings.setValue("category", category);
    m_settings.setValue("timestamp", QDateTime::currentDateTime());
    
    m_settings.endGroup();
}

QImage CardStorageModel::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QImage image(m_storageLocation + id + ".jpg");
    if (requestedSize.isValid()) {
        image = image.scaled(requestedSize);
        size->setWidth(requestedSize.width());
        size->setHeight(requestedSize.height());
    }
    return image;
}
