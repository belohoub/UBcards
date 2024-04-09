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

#include "cardstorage.h"

#include <QGuiApplication>
#include <QWindow>
#include <QDebug>
#include <QUrlQuery>
#include <QQuickItem>
#include <QSettings>
#include <QStandardPaths>

CardStorage::CardStorage(QObject *parent) :
    QObject(parent),
    QQuickImageProvider(QQmlImageProviderBase::Image),
    m_mainWindow(0)
{
    QGuiApplication *app = qobject_cast<QGuiApplication*>(qApp);

    qDebug() << "constructing storage" << app;
    foreach (QWindow *win, app->allWindows()) {
        qDebug() << "got win" << win;
        QQuickWindow *quickWin = qobject_cast<QQuickWindow*>(win);
        if (quickWin) {
            m_mainWindow = quickWin;
        }
    }

    m_storageModel = new CardStorageModel(this);

    /* TODO add signals/slots */
    
}

/* Insert card to the storage */
void CardStorage::insertCard(const QString &code, const QString &type, const QString &name, const QString &category) {
    /* Direct insertion with an empty image */
    QString newId = m_storageModel->add(code, type, name, category, QImage());
    /* TODO emit signal with added ID */
}

void CardStorage::setCardById(const QString &id, const QString &text, const QString &type, const QString &name, const QString &category) {
    m_storageModel->setCardById(id, text, type, name, category);
}

CardStorageModel *CardStorage::storage() const
{
    qDebug() << "Storage model items " << m_storageModel->rowCount(QModelIndex()) << "rows requested.";
    return m_storageModel;
}
