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

#ifndef QRCODEREADER_H
#define QRCODEREADER_H

#include <QObject>
#include <QQuickWindow>
#include <QThread>
#include <QQuickImageProvider>
#include <QUuid>

class QRCodeReader : public QObject, public QQuickImageProvider
{
    Q_OBJECT
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(QString type READ type NOTIFY validChanged)
    Q_PROPERTY(QString text READ text NOTIFY validChanged)
    Q_PROPERTY(QString name READ name NOTIFY validChanged)
    Q_PROPERTY(QString category READ category NOTIFY validChanged)
    Q_PROPERTY(QImage image READ image NOTIFY validChanged)
    Q_PROPERTY(QRect scanRect READ scanRect WRITE setScanRect NOTIFY scanRectChanged)
    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged)

public:
    explicit QRCodeReader(QObject *parent = 0);

    bool valid() const;
    QString type() const;
    QString text() const;
    QString name() const;
    QString category() const;
    QImage image() const;
    QRect scanRect() const;
    void setScanRect(const QRect &rect);
    bool scanning() const;

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

public slots:
    void grab(const QString &name, const QString &category);
    void processImage(const QUrl &url, const QString &name, const QString &category);

signals:
    void validChanged();
    void scanRectChanged();
    void scanningChanged();

private slots:
    void handleResults(const QString &type, const QString &text, const QString &name, const QString &category, const QImage &codeImage);

private:
    QQuickWindow *m_mainWindow;

    QString m_type;
    QString m_text;
    QString m_name;
    QString m_category;
    QImage m_image;
    QUuid m_imageUuid;
    QRect m_scanRect;

    QThread m_readerThread;
};

class Reader : public QObject
{
    Q_OBJECT

public slots:
    void doWork(const QImage &image, const QString &name, const QString &category, bool invert);

signals:
    void resultReady(const QString &type, const QString &text, const QString &name, const QString &category, const QImage &codeImage);
    void finished();
};

#endif // QRCODEREADER_H
