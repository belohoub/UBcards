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

    /* No image */
    m_image = QImage();
    m_imageID = "";
    
    /* TODO add signals/slots */
    
}

/**
 * Prepare an image to save image
 * 
 * When ID is empty string, image for the ID is NOT updated
 * 
 */
void CardStorage::updateImage(const QString &id, const QImage &image) {
    m_image = image;
    m_imageID = id;
}

void CardStorage::updateCard(const QString &id, const QString &text, const QString &type, const QString &name, const QString &category) {
    if (!m_storageModel->setCardById(id, text, type, name, category)) {
        /* In case of invalid ID, insert a new card */
        QString newId = m_storageModel->add(text, type, name, category, m_image);
    }
    
    /* No image - the Image has been already used */
    m_image = QImage();
    m_imageID = "";
        
    
    /* emit signal with added ID */
    emit cardUpdated();
}

CardStorageModel *CardStorage::storage() const
{
    qDebug() << "Storage model items " << m_storageModel->rowCount(QModelIndex()) << "rows requested.";
    return m_storageModel;
}
