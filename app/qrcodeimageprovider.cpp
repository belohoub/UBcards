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

#include "qrcodeimageprovider.h"

#include "qrcodegenerator.h"

QRCodeImageProvider::QRCodeImageProvider() :
    QQuickImageProvider(QQmlImageProviderBase::Image)
{

}

QRCodeImageProvider::~QRCodeImageProvider()
{

}

QImage QRCodeImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QRCodeGenerator generator;
    QImage result = generator.generateCode(id).scaled(requestedSize);
    if (size) {
        *size = result.size();
    }
    return generator.generateCode(id);
}
