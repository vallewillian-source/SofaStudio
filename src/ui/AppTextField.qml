import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

TextField {
    id: control
    
    placeholderTextColor: Theme.textSecondary
    color: Theme.textPrimary
    property color accentColor: Theme.accent
    selectionColor: accentColor
    selectedTextColor: "#FFFFFF"
    font.pixelSize: 14
    leftPadding: 10
    rightPadding: 10
    topPadding: 6
    bottomPadding: 6
    
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: Theme.buttonHeight
        color: Theme.surface
        border.color: control.activeFocus ? control.accentColor : Theme.border
        border.width: 1
        radius: Theme.radius
    }
}
