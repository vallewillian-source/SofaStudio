import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Button {
    id: control
    
    // Custom properties
    property bool isPrimary: false
    property color textColor: isPrimary ? "#000000" : Theme.textPrimary
    property string tooltip: ""
    property int iconSize: 16

    // Reset default padding to ensure centering
    padding: 0
    horizontalPadding: 0
    verticalPadding: 0

    ToolTip {
        visible: control.hovered && control.tooltip.length > 0
        text: control.tooltip
        delay: 500
        timeout: 5000
        
        contentItem: Text {
            text: control.tooltip
            font.pixelSize: 12
            color: Theme.textPrimary
        }
        
        background: Rectangle {
            color: Theme.surfaceHighlight
            border.color: Theme.border
            border.width: 1
            radius: 4
        }
    }

    contentItem: RowLayout {
        spacing: textItem.text.length > 0 ? 8 : 0
        
        Item {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            visible: control.icon.source.toString().length > 0
            Layout.preferredWidth: control.iconSize
            Layout.preferredHeight: control.iconSize
            
            Image {
                id: btnIcon
                anchors.fill: parent
                source: control.icon.source
                sourceSize.width: control.iconSize
                sourceSize.height: control.iconSize
                visible: false
                fillMode: Image.PreserveAspectFit
            }
            
            ColorOverlay {
                anchors.fill: btnIcon
                source: btnIcon
                color: control.textColor
                antialiasing: true
            }
        }

        Text {
            id: textItem
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: control.text
            visible: text.length > 0
            font: control.font
            opacity: enabled ? 1.0 : 0.3
            color: control.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        
        // Add a spacer if we want to center the content in the button
        // But RowLayout inside contentItem usually centers itself if we don't force it
    }

    background: Rectangle {
        implicitWidth: {
            // Se tiver texto, calcula baseado no texto + padding
            if (control.text.length > 0) {
                return Math.max(100, (control.icon.source.toString().length > 0 ? 24 : 0) + control.text.length * 8 + 20)
            }
            // Se for apenas ícone, um quadrado
            return Theme.buttonHeight
        }
        implicitHeight: Theme.buttonHeight
        opacity: enabled ? 1 : 0.3
        color: {
            if (control.pressed) return control.isPrimary ? Qt.darker(Theme.accent, 1.1) : Theme.surfaceHighlight
            if (control.hovered) return control.isPrimary ? Theme.accentHover : Theme.surfaceHighlight
            return control.isPrimary ? Theme.accent : Theme.surface
        }
        border.color: control.isPrimary ? "transparent" : Theme.border
        border.width: 1
        radius: Theme.radius
    }
}
