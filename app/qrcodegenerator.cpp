#include "qrcodegenerator.h"

#include "qrencode.h"

#include <QDebug>
#include <QPainter>
#include <QStandardPaths>
#include <QDir>

QRCodeGenerator::QRCodeGenerator(QObject *parent) :
    QObject(parent)
{
}

QImage QRCodeGenerator::generateCode(const QString &text)
{
    QRcode *code = QRcode_encodeString(text.toLatin1().data(), 0, QR_ECLEVEL_Q, QR_MODE_8, 1);
    if (code) {
        QImage img = QImage((code->width + 2) * 10, (code->width + 2) * 10, QImage::Format_ARGB32);
        img.fill(Qt::white);
        QPainter painter(&img);
        painter.setPen(Qt::NoPen);

        for (int i = 0; i < code->width; ++i) {
            for (int j = 0; j < code->width; ++j) {
                bool black = code->data[i * code->width + j] % 2 == 1;
                painter.setBrush(QBrush(black ? Qt::black : Qt::white));
                painter.drawRect(QRect((j+1) * 10, (i+1) * 10, 10, 10));
            }
        }
        return img;
    }
    return QImage();
}

QString QRCodeGenerator::generateCode(const QString &fileName, const QString &text)
{
    QImage img = generateCode(text);
    QString path = QStandardPaths::standardLocations(QStandardPaths::CacheLocation).first() + "/";
    QDir cacheDir(path);
    if (!cacheDir.exists()) {
        cacheDir.mkpath(path);
    }
    qDebug() << "storing to" << path + fileName;
    qDebug() << img.save(path + fileName);
    return path + fileName;
}
