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

#ifndef QRCODEIMAGEPROVIDER_H
#define QRCODEIMAGEPROVIDER_H

#include <QQuickImageProvider>

class QRCodeImageProvider : public QQuickImageProvider
{
public:
    QRCodeImageProvider();
    ~QRCodeImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

signals:

public slots:

};

#endif // QRCODEIMAGEPROVIDER_H
