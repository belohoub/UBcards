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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.0
import QtQuick.Window 2.0
import Ubuntu.Content 1.3
import Tagger 0.1

MainView {
    id: mainView

    applicationName: "openstore.tagger"

    Component.onCompleted: i18n.domain = "tagger"

    width: units.gu(40)
    height: units.gu(68)

    PageStack {
        id: pageStack
        Component.onCompleted: {
            pageStack.push(dummyPage)
        }
    }
    Page {
        id: dummyPage
    }

    Timer {
        interval: 1
        running: true
        repeat: false
        onTriggered: {
            if (pageStack.currentPage == dummyPage) {
                pageStack.pop();
                pageStack.push(qrCodeReaderComponent)
            }
        }
    }

    Connections {
        target: qrCodeReader

        onScanningChanged: {
            if (!qrCodeReader.scanning) {
                mainView.decodingImage = false;
            }
        }

        onValidChanged: {
            if (qrCodeReader.valid) {
//                pageStack.pop();
                pageStack.push(resultsPageComponent, {type: qrCodeReader.type, text: qrCodeReader.text, imageSource: qrCodeReader.imageSource});
            }
        }
    }

    Connections {
        target: ContentHub
        onExportRequested: {
            // show content picker
            print("******* transfer requested!");
            pageStack.pop();
            pageStack.push(generateCodeComponent, {transfer: transfer})
        }
        onImportRequested: {
            print("**** import Requested")
            var filePath = String(transfer.items[0].url).replace('file://', '')
            qrCodeReader.processImage(filePath);
        }

        onShareRequested: {
            print("***** share requested", transfer)
            var filePath = String(transfer.items[0].url).replace('file://', '')
            qrCodeReader.processImage(filePath);
        }
    }

    property list<ContentItem> importItems
    property var activeTransfer: null
    property bool decodingImage: false
    ContentPeer {
        id: picSourceSingle
        contentType: ContentType.Pictures
        handler: ContentHandler.Source
        selectionType: ContentTransfer.Single
    }
    ContentTransferHint {
        id: importHint
        anchors.fill: parent
        activeTransfer: mainView.activeTransfer
        z: 100
    }
    Connections {
        target: mainView.activeTransfer
        onStateChanged: {
            switch (mainView.activeTransfer.state) {
            case ContentTransfer.Charged:
                print("should process", activeTransfer.items[0].url)
                mainView.decodingImage = true;
                qrCodeReader.processImage(activeTransfer.items[0].url);
                mainView.activeTransfer = null;
                break;
            case ContentTransfer.Aborted:
                mainView.activeTransfer = null;
                break;
            }
        }
    }

    onDecodingImageChanged: {
        if (!decodingImage && !qrCodeReader.valid) {
            pageStack.push(errorPageComponent)
        }
    }

    Component {
        id: errorPageComponent
        Page {
            title: i18n.tr("Error")
            Column {
                anchors {
                    left: parent.left;
                    right: parent.right;
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    anchors { left: parent.left; right: parent.right }
                    horizontalAlignment: Text.AlignHCenter
                    // TRANSLATORS: Displayed after a picture has been scanned and no code was found in it
                    text: i18n.tr("No code found in image")
                }
            }
        }
    }

    Component {
        id: qrCodeReaderComponent

        PageWithBottomEdge {
            id: qrCodeReaderPage
            // TRANSLATORS: Title of the main page of the app, when the camera is active and scanning for codes
            signal codeParsed(string type, string text)

            property var aboutPopup: null

            header: PageHeader {
                title: i18n.tr("Scan code")
                leadingActionBar.actions: []
                trailingActionBar.actions: [
                    Action {
                        text: i18n.tr("Generate code")
                        iconName: "compose"
                        onTriggered: pageStack.push(generateCodeComponent)
                    },
                    Action {
                        // TRANSLATORS: Name of an action in the toolbar to import pictures from other applications and scan them for codes
                        text: i18n.tr("Import image")
                        iconName: "insert-image"
                        onTriggered: {
                            mainView.activeTransfer = picSourceSingle.request()
                            print("transfer request", mainView.activeTransfer)
                        }
                    }
                ]
            }

            Component.onCompleted: {
                qrCodeReader.scanRect = Qt.rect(mainView.mapFromItem(videoOutput, 0, 0).x, mainView.mapFromItem(videoOutput, 0, 0).y, videoOutput.width, videoOutput.height)
            }

            bottomEdgeTitle: i18n.tr("Previously scanned")

            bottomEdgePageComponent: Component {
                Page {
                    header: PageHeader {
                        id: previouslyScannedHeader
                        title: i18n.tr("Previously scanned")
                    }
                    ListView {
                        anchors.fill: parent
                        anchors.topMargin: previouslyScannedHeader.height
                        model: qrCodeReader.history

                        delegate: ListItem {
                            height: units.gu(10)

                            leadingActions: ListItemActions {
                                actions: [
                                    Action {
                                        iconName: "delete"
                                        onTriggered: {
                                            qrCodeReader.history.remove(index)
                                        }
                                    }
                                ]
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                UbuntuShape {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    image: Image {
                                        anchors.fill: parent
                                        source: model.imageSource
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Label {
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        text: model.text
                                        maximumLineCount: 2
                                    }
                                    Label {
                                        Layout.fillWidth: true
                                        text: model.type + " - " + model.timestamp
                                    }
                                }
                            }

                            onClicked: {
                                pageStack.push(resultsPageComponent, {type: model.type, text: model.text, imageSource: model.imageSource})
                            }
                        }
                    }
                }
            }

            Camera {
                id: camera

//                flash.mode: torchButton.active ? Camera.FlashTorch : Camera.FlashOff
//                flash.mode: Camera.FlashTorch

                focus.focusMode: Camera.FocusContinuous
                focus.focusPointMode: Camera.FocusPointAuto

                /* Use only digital zoom for now as it's what phone cameras mostly use.
                       TODO: if optical zoom is available, maximumZoom should be the combined
                       range of optical and digital zoom and currentZoom should adjust the two
                       transparently based on the value. */
                property alias currentZoom: camera.digitalZoom
                property alias maximumZoom: camera.maximumDigitalZoom

                function startAndConfigure() {
                    start();
                    focus.focusMode = Camera.FocusContinuous
                    focus.focusPointMode = Camera.FocusPointAuto
                }
            }

            Connections {
                target: Qt.application
                onActiveChanged: if (Qt.application.active) camera.startAndConfigure()
            }

            Timer {
                id: captureTimer
                interval: 2000
                repeat: true
                running: pageStack.depth == 1
                         && qrCodeReaderPage.aboutPopup == null
                         && !mainView.decodingImage
                         && mainView.activeTransfer == null
                         && qrCodeReaderPage.isCollapsed
                onTriggered: {
                    if (!qrCodeReader.scanning && qrCodeReaderPage.isCollapsed) {
//                        print("capturing");
                        qrCodeReader.grab();
                    }
                }

                onRunningChanged: {
                    if (running) {
                        camera.startAndConfigure();
                    } else {
                        camera.stop();
                    }
                }
            }

            VideoOutput {
                id: videoOutput
                anchors {
                    fill: parent
                }
                fillMode: Image.PreserveAspectCrop

                orientation: {
                    var angle = Screen.primaryOrientation == Qt.PortraitOrientation ? -90 : 0;
                    angle += Screen.orientation == Qt.InvertedLandscapeOrientation ? 180 : 0;
                    return angle;
                }
                source: camera
                focus: visible
                visible: pageStack.depth == 1 && !mainView.decodingImage
            }
            PinchArea {
                id: pinchy
                anchors.fill: parent

                property real initialZoom
                property real minimumScale: 0.3
                property real maximumScale: 3.0
                property bool active: false

                onPinchStarted: {
                    print("pinch started!")
                    active = true;
                    initialZoom = camera.currentZoom;
                }
                onPinchUpdated: {
                    print("pinch updated")
                    var scaleFactor = MathUtils.projectValue(pinch.scale, 1.0, maximumScale, 0.0, camera.maximumZoom);
                    camera.currentZoom = MathUtils.clamp(initialZoom + scaleFactor, 1, camera.maximumZoom);
                }
                onPinchFinished: {
                    active = false;
                }
            }

            Icon {
                id: torchButton
                height: units.gu(6)
                width: height
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: units.gu(2)
                }
                name: camera.flash.mode === Camera.FlashVideoLight ? "torch-off" : "torch-on"
                color: "white"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        print("torch is", camera.flash.mode)
                        print("set to", (camera.flash.mode === Camera.FlashVideoLight ? Camera.FlashOff : Camera.FlashVideoLight))
                        camera.flash.mode = (camera.flash.mode === Camera.FlashVideoLight ? Camera.FlashOff : Camera.FlashVideoLight)
                        print("is now:", camera.flash.mode)
                    }
                }
            }

            ActivityIndicator {
                anchors.centerIn: parent
                running: mainView.decodingImage
            }
            Label {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: units.gu(5)
                text: i18n.tr("Decoding image")
                visible: mainView.decodingImage
            }
        }
    }

    Component {
        id: resultsPageComponent
        Page {
            id: resultsPage
            property string type
            property string text
            property string imageSource

            property bool isUrl: resultsPage.text.match(/^[a-z]+:\//)
            property bool isPhoneNumber: resultsPage.text.indexOf("tel:") == 0
            property bool isVCard: resultsPage.text.indexOf("BEGIN:VCARD") == 0

            header: PageHeader {
                id: resultsHeader
                visible: !exportVCardPeerPicker.visible
                title: i18n.tr("Results")
            }

            Item {
                anchors.fill: parent
                anchors.topMargin: resultsHeader.height
                clip: true

                Flickable {
                    id: resultsFlickable
                    anchors.fill: parent
                    contentHeight: resultsColumn.implicitHeight + units.gu(4)
                    interactive: contentHeight > height

                    GridLayout {
                        id: resultsColumn
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: units.gu(2)
                        }

                        columnSpacing: units.gu(1)
                        rowSpacing: units.gu(1)
                        columns: resultsPage.width > resultsPage.height ? 3 : 1

                        Row {
                            Layout.fillWidth: true
                            spacing: units.gu(1)
                            Item {
                                id: imageItem
                                width: units.gu(10)
                                height: portrait ? width : imageShape.height
                                property bool portrait: resultsImage.height > resultsImage.width

                                UbuntuShape {
                                    id: imageShape
                                    anchors.centerIn: parent
                                    // ssh : ssw = h : w
                                    height: imageItem.portrait ? parent.height : resultsImage.height * width / resultsImage.width
                                    width: imageItem.portrait ? resultsImage.width * height / resultsImage.height : parent.width
                                    image: Image {
                                        id: resultsImage
                                        source: resultsPage.imageSource
                                    }
                                }
                            }

                            Column {
                                width: (parent.width - parent.spacing) / 2
                                Label {
                                    text: i18n.tr("Code type")
                                    font.bold: true
                                }
                                Label {
                                    text: resultsPage.type
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                }
                                Item {
                                    width: parent.width
                                    height: units.gu(1)
                                }

                                Label {
                                    text: i18n.tr("Content length")
                                    font.bold: true
                                }
                                Label {
                                    text: resultsPage.text.length
                                }
                            }

                        }
                        Column {
                            Layout.fillWidth: true
                            Layout.columnSpan: resultsColumn.columns == 1 ? 1 : 2
                            spacing: units.gu(1)
                            Label {
                                text: i18n.tr("Code content")
                                font.bold: true
                            }
                            UbuntuShape {
                                width: parent.width
                                height: resultsLabel.height + units.gu(2)
                                color: "white"

                                Label {
                                    id: resultsLabel
                                    text: resultsPage.text
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    width: parent.width - units.gu(2)
                                    anchors.centerIn: parent
                                    color: resultsPage.isUrl ? "blue" : "black"
                                }
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: i18n.tr("Open URL")
                            visible: resultsPage.isUrl
                            color: UbuntuColors.green
                            onClicked: Qt.openUrlExternally(resultsPage.text)
                        }
                        ComboButton {
                            text: i18n.tr("Search online")
                            Layout.fillWidth: true
                            visible: !resultsPage.isUrl && !resultsPage.isVCard
                            color: UbuntuColors.green
                            z: 2

                            onClicked: Qt.openUrlExternally("https://www.google.de/search?q=" + resultsPage.text)

                            Rectangle {
                                height: units.gu(20)
                                color: mainView.backgroundColor
                                ListView {
                                    anchors.fill: parent
                                    model: ListModel {
                                        ListElement { text: "Google"; query: "https://www.google.de/search?q=" }
                                        ListElement { text: "DuckDuckGo"; query: "https://duckduckgo.com/?q=" }
                                        ListElement { text: "Baidu"; query: "https://www.baidu.com/s?wd=" }
                                        ListElement { text: "Yahoo"; query: "https://search.yahoo.com/yhs/search?p=" }
                                        ListElement { text: "Bing"; query: "https://www.bing.com/search?q=" }
                                        ListElement { text: "Wikipedia"; query: "https://wikipedia.org/wiki/Special:Search?search=" }
                                        ListElement { text: "Amazon"; query: "http://www.amazon.com/s?field-keywords=" }
                                        ListElement { text: "ebay"; query: "http://www.ebay.com/sch/i.html?_nkw=" }
                                    }

                                    delegate: Standard {
                                        text: model.text
                                        onClicked: {
                                            Qt.openUrlExternally(model.query + resultsPage.text)
                                        }
                                    }
                                }
                            }
                        }
                        Button {
                            Layout.fillWidth: true
                            text: i18n.tr("Call number")
                            visible: resultsPage.isPhoneNumber
                            color: UbuntuColors.green
                            onClicked: {
                                Qt.openUrlExternally("tel:///" + resultsPage.text)
                            }
                        }
                        Button {
                            Layout.fillWidth: true
                            text: i18n.tr("Save contact")
                            visible: resultsPage.isVCard
                            color: UbuntuColors.green
                            onClicked: {
                                print("should save contact")
                                exportVCardPeerPicker.visible = true
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: i18n.tr("Copy to clipboard")
                            color: UbuntuColors.green
                            onClicked: Clipboard.push(resultsPage.text)
                        }

                        Button {
                            Layout.fillWidth: true
                            text: i18n.tr("Generate QR code")
                            color: UbuntuColors.green
                            onClicked: {
                                pageStack.push(generateCodeComponent, {textData: resultsPage.text})
                            }
                        }
                    }
                }
            }

            ContentItem {
                id: exportItem
                name: i18n.tr("Contact")
            }

            ContentPeerPicker {
                id: exportVCardPeerPicker
                visible: false
                contentType: ContentType.Contacts
                handler: ContentHandler.Destination
                anchors.fill: parent

                onPeerSelected: {
                    var transfer = peer.request();
                    if (transfer.state === ContentTransfer.InProgress) {
                        var items = new Array()
                        var path = fileHelper.saveToFile(resultsPage.text, "vcf")
                        exportItem.url = path
                        items.push(exportItem);
                        transfer.items = items;
                        transfer.state = ContentTransfer.Charged;
                    }
                    exportVCardPeerPicker.visible = false
                }
                onCancelPressed: exportVCardPeerPicker.visible = false
            }
        }
    }

    Component {
        id: generateCodeComponent
        Page {
            id: generateCodePage
            property alias textData: dataTextField.text
            property var transfer: null

            header: PageHeader {
                id: generateQRCodeHeader
                title: i18n.tr("Generate QR code")
                visible: !contentPeerPicker.visible

                leadingActionBar.actions: [
                    Action {
                        iconName: "back"
                        onTriggered: {
                            if (transfer == null) {
                                pageStack.pop()
                            } else {
                                transfer.state = ContentTransfer.Aborted
                            }
                        }
                    }
                ]

                trailingActionBar.actions: [
                    Action {
                        iconName: "tick"
                        onTriggered: {
                            var items = new Array()
                            var path = generator.generateCode("export.png", dataTextField.text)
                            exportItem.url = path
                            items.push(exportItem);
                            transfer.items = items;
                            transfer.state = ContentTransfer.Charged;
                        }
                        visible: transfer != null
                    },
                    Action {
                        iconName: "share"
                        onTriggered: {
                            Qt.inputMethod.hide();
                            contentPeerPicker.visible = true;
                        }
                        visible: transfer == null && dataTextField.text
                    }
                ]
            }


            ContentItem {
                id: exportItem
                name: i18n.tr("QR-Code")
            }

            QRCodeGenerator {
                id: generator
            }

            GridLayout {
                anchors {
                    fill: parent
                    margins: units.gu(1)
                    topMargin: generateQRCodeHeader.height + units.gu(1)
                }
                columnSpacing: units.gu(1)
                rowSpacing: units.gu(1)
                columns: width > height ? 2 : 1

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: units.gu(1)
                    Label {
                        text: i18n.tr("Code content")
                    }
                    TextArea {
                        id: dataTextField
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }


                Image {
                    id: qrCodeImage
                    Layout.preferredWidth: Math.min(parent.width, parent.height)
                    Layout.preferredHeight: width
                    fillMode: Image.PreserveAspectFit
                    source: dataTextField.text.length > 0 ? "image://qrcode/" + dataTextField.text : ""
                    onStatusChanged: print("status changed", status)
                    MouseArea {
                        anchors.fill: parent
                        onClicked: dataTextField.focus = false
                    }
                }
            }

            ContentPeerPicker {
                id: contentPeerPicker
                visible: false
                contentType: ContentType.Pictures
                handler: ContentHandler.Share
                anchors.fill: parent

                onPeerSelected: {
                    var transfer = peer.request();
                    if (transfer.state === ContentTransfer.InProgress) {
                        var items = new Array()
                        var path = generator.generateCode("export.png", dataTextField.text)
                        exportItem.url = path
                        items.push(exportItem);
                        transfer.items = items;
                        transfer.state = ContentTransfer.Charged;
                    }
                    contentPeerPicker.visible = false
                }
                onCancelPressed: contentPeerPicker.visible = false
            }
        }
    }

    Component {
        id: aboutDialogComponent
        Dialog {
            id: aboutDialog
            title: "Tagger 0.5"
            text: "Michael Zanetti\nmichael_zanetti@gmx.net"

            signal closed()

            Item {
                width: parent.width
                height: units.gu(40)
                Column {
                    id: contentColumn
                    anchors.fill: parent
                    spacing: units.gu(1)

                    UbuntuShape {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(6)
                        width: units.gu(6)
                        radius: "medium"
                        image: Image {
                            source: "images/tagger.svg"
                        }
                    }

                    Flickable {
                        width: parent.width
                        height: parent.height - y - (closeButton.height + parent.spacing) * 3
                        contentHeight: gplLabel.implicitHeight
                        clip: true
                        Label {
                            id: gplLabel
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: "This program is free software: you can redistribute it and/or modify " +
                                  "it under the terms of the GNU General Public License as published by " +
                                  "the Free Software Foundation, either version 3 of the License, or " +
                                  "(at your option) any later version.\n\n" +

                                  "This program is distributed in the hope that it will be useful, " +
                                  "but WITHOUT ANY WARRANTY; without even the implied warranty of " +
                                  "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the " +
                                  "GNU General Public License for more details.\n\n" +

                                  "You should have received a copy of the GNU General Public License " +
                                  "along with this program.  If not, see http://www.gnu.org/licenses/."
                        }
                    }
                    Button {
                        id: closeButton
                        width: parent.width
                        text: i18n.tr("Close")
                        onClicked: {
                            aboutDialog.closed()
                            PopupUtils.close(aboutDialog)
                        }
                    }
                }
            }
        }
    }
}
