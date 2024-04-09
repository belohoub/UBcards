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

#ifndef CARDSTORAGE_H
#define CARDSTORAGE_H

#include "cardstoragemodel.h"

#include <QObject>
#include <QQuickWindow>
#include <QThread>
#include <QQuickImageProvider>
#include <QUuid>

class CardStorage : public QObject, public QQuickImageProvider
{
    Q_OBJECT
    Q_PROPERTY(CardStorageModel* storage READ storage CONSTANT)

public:
    explicit CardStorage(QObject *parent = 0);
    
    CardStorageModel* storage() const;

    Q_INVOKABLE void insertCard(const QString &code, const QString &type, const QString &name, const QString &category);
    Q_INVOKABLE void setCardById(const QString &id, const QString &text, const QString &type, const QString &name, const QString &category);
    
public slots:
    
signals:
    
private slots:
    
private:
    QQuickWindow *m_mainWindow;
    
    CardStorageModel *m_storageModel;
};


#endif // CARDSTORAGE_H
