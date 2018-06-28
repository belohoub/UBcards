/*****************************************************************************
 * Copyright: 2013 Michael Zanetti <michael_zanetti@gmx.net>                 *
 *                                                                           *
 * This file is part of ubuntu-authenticator                                 *
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

#include "qrcodereader.h"
#include "qrcodegenerator.h"
#include "qrcodeimageprovider.h"
#include "filehelper.h"

#include <QGuiApplication>
#include <QtQuick/QQuickView>
#include <QtQml/QtQml>

#include <libintl.h>

int main(int argc, char *argv[])
{
    QGuiApplication a(argc, argv);

    QQuickView view;

    QRCodeReader reader;
    view.engine()->rootContext()->setContextProperty("qrCodeReader", &reader);

    FileHelper fh;
    qmlRegisterType<QRCodeGenerator>("Tagger", 0, 1, "QRCodeGenerator");
    qmlRegisterUncreatableType<HistoryModel>("Tagger", 0, 1, "HistoryModel", "use qrCodeReader.history");

    view.engine()->addImageProvider(QStringLiteral("qrcode"), new QRCodeImageProvider);
    view.engine()->addImageProvider(QStringLiteral("reader"), &reader);
    view.engine()->addImageProvider(QStringLiteral("history"), reader.history());

    view.engine()->rootContext()->setContextProperty(QStringLiteral("fileHelper"), &fh);

    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl::fromLocalFile("qml/tagger.qml"));
    view.show();

    return a.exec();
}
