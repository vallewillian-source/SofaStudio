import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Sofa Studio")

    Text {
        anchors.centerIn: parent
        text: qsTr("Boot OK")
        font.pixelSize: 24
    }
}
