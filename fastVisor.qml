import QtQuick
import QtQuick.Window
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel 2.15

Window {
    id: win
    flags: Qt.FramelessWindowHint | Qt.Window
    visible: true
    color: "transparent"
    title: "visor"
    width: 500 + (400 * Math.ceil(finalRatio - 1))
    height: width / finalRatio

    property var args:          Qt.application.arguments
    property string rutaImagen: args.length > 1 ? args[2] : ""
    property url pathImages:    ""
    property var fullImages:    []
    property double finalRatio: 1
    property bool pinned:       false
    property int currentIndex:  0

    function loadImage(path) {
        rutaImagen     = path
        fullImg.source = ""
        thumb.source   = path
    }

    function goNext() { if (fullImages.length) { currentIndex = (currentIndex + 1) % fullImages.length;                      loadImage(fullImages[currentIndex]) } }
    function goPrev() { if (fullImages.length) { currentIndex = (currentIndex - 1 + fullImages.length) % fullImages.length;  loadImage(fullImages[currentIndex]) } }

    Component.onCompleted: {
        if (!rutaImagen) return
            var bar = rutaImagen.lastIndexOf("/")
            if (bar > 0) pathImages = rutaImagen.substring(0, bar + 1)
                thumb.source = rutaImagen
    }

    // ── Precarga silenciosa de la siguiente imagen ──
    Image {
        id: preload
        visible: false
        asynchronous: true
        cache: true
        sourceSize.width:  win.width  * Screen.devicePixelRatio
        sourceSize.height: win.height * Screen.devicePixelRatio
    }

    FolderListModel {
        id: imagesModel
        nameFilters: ["*.jpg","*.jpeg","*.png","*.gif","*.bmp","*.webp","*.svg","*.tiff","*.tif"]
        folder: pathImages
        showDirs: false
        onStatusChanged: {
            fullImages = []
            for (var t = 0; t < count; t++) fullImages.push(get(t, "filePath"))
                for (var i = 0; i < fullImages.length; i++) {
                    if (fullImages[i] === rutaImagen) { currentIndex = i; break }
                }
        }
    }

    RectangularShadow {
        anchors.fill: backd
        offset.x: 1; offset.y: 2
        radius: backd.radius
        blur: 6; spread: 4; opacity: 0.5
        color: Qt.darker("black", 1.6)
    }

    Rectangle {
        id: backd
        color: "black"; opacity: 0.5
        width: parent.width - 16; height: parent.height - 16
        anchors.centerIn: parent
        radius: 12
    }

    Rectangle {
        id: mask
        color: "black"; anchors.fill: backd; radius: backd.radius; visible: false
    }

    // ── Thumb: síncrono 4px → ratio instantáneo ──
    Image {
        id: thumb
        anchors.fill: backd
        asynchronous: false
        sourceSize.width: 4; sourceSize.height: 4
        fillMode: Image.PreserveAspectFit
        opacity: fullImg.status === Image.Ready ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 200 } }
        layer.enabled: true
        layer.effect: OpacityMask { maskSource: mask }
        onStatusChanged: {
            if (status !== Image.Ready) return
                finalRatio = implicitWidth / implicitHeight
                win.width  = 500 + (400 * Math.ceil(finalRatio - 1))
                win.height = win.width / finalRatio
                fullImg.source = rutaImagen
        }
    }

    // ── Full: asíncrona, fade-in al estar lista ──
    Image {
        id: fullImg
        anchors.fill: backd
        asynchronous: true
        sourceSize.width:  win.width  * Screen.devicePixelRatio
        sourceSize.height: win.height * Screen.devicePixelRatio
        opacity: status === Image.Ready ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        layer.enabled: true
        layer.effect: OpacityMask { maskSource: mask }
        onStatusChanged: {
            if (status !== Image.Ready || fullImages.length === 0) return
                preload.source = fullImages[(currentIndex + 1) % fullImages.length]
        }
    }

    MouseArea {
        id: rootArea
        anchors.fill: backd
        propagateComposedEvents: true
        onPressed: win.startSystemMove()
        onWheel: (w) => w.angleDelta.y > 0 ? goPrev() : goNext()
    }

    // ── Toolbar hover ──
    Rectangle {
        z: 10
        anchors { top: backd.top; right: backd.right; topMargin: 8; rightMargin: 8 }
        width: row.width + 12; height: 28; radius: 8; color: "#CC000000"
        //opacity: hov.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        MouseArea { id: hov; anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true }

        Row {
            id: row; anchors.centerIn: parent; spacing: 6

            Rectangle {
                width: 22; height: 22; radius: 11
                color: pma.containsMouse ? "#44FFFFFF" : "transparent"
                Text { anchors.centerIn: parent; text: win.pinned ? "📌" : "📍"; font.pixelSize: 13 }
                MouseArea { id: pma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: win.pinned = !win.pinned }
            }

            Rectangle {
                width: 22; height: 22; radius: 11
                color: cma.containsMouse ? "#88FF3333" : "transparent"
                Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 13; color: "white" }
                MouseArea { id: cma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Qt.quit() }
            }
        }
    }

    // ── Flechas laterales ──
    Rectangle {
        z: 10; anchors { left: backd.left; verticalCenter: backd.verticalCenter; leftMargin: 8 }
        width: 28; height: 28; radius: 14; color: "#CC000000"
        opacity: lma.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
        Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 20; color: "white" }
        MouseArea { id: lma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: goPrev() }
    }

    Rectangle {
        z: 10; anchors { right: backd.right; verticalCenter: backd.verticalCenter; rightMargin: 8 }
        width: 28; height: 28; radius: 14; color: "#CC000000"
        opacity: rma.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
        Text { anchors.centerIn: parent; text: "›"; font.pixelSize: 20; color: "white" }
        MouseArea { id: rma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: goNext() }
    }

    // ── Bordes decorativos ──
    Rectangle { z: 5; anchors.fill: backd; color: "transparent"; radius: backd.radius; opacity: 0.5; border { width: 1; color: "black" } }
    Rectangle { z: 5; width: backd.width - 2; height: backd.height - 2; anchors.centerIn: parent; radius: backd.radius; color: "transparent"; border { width: 1; color: "#1AFFFFFF" } }

    Item {
        anchors.fill: parent; focus: true
        Keys.onPressed: (e) => {
            if      (e.key === Qt.Key_Right || e.key === Qt.Key_Down || e.key === Qt.Key_Space) goNext()
                else if (e.key === Qt.Key_Left  || e.key === Qt.Key_Up)                             goPrev()
                    else if (e.key === Qt.Key_Escape)                                                   Qt.quit()
                        else if (e.key === Qt.Key_P)                                                        win.pinned = !win.pinned
        }
    }

    onActiveChanged: if (!active && !pinned) Qt.quit()
}
