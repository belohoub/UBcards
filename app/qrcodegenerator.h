/*****************************************************************************
 * Copyright: 2013 Michael Zanetti <michael_zanetti@gmx.net>                 *
 *                                                                           *
 * This file is part of tagger                                               *
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

#ifndef QRCODEGENERATOR_H
#define QRCODEGENERATOR_H

#include <QObject>
#include <QImage>

class QRCodeGenerator : public QObject
{
    Q_OBJECT
public:
    explicit QRCodeGenerator(QObject *parent = 0);

    Q_INVOKABLE QImage generateCode(const QString &text);
    Q_INVOKABLE QString generateCode(const QString &fileName, const QString &text);
signals:

public slots:

};

#endif // QRCODEGENERATOR_H
