import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    height: 30 // Keeping it slim as requested (close to 25px but usable)
    color: Theme.surface
    border.color: Theme.border
    border.width: 1
    
    signal requestNewConnection()
    signal requestEditConnection(var connectionId)
    signal requestDeleteConnection(var connectionId)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMedium
        anchors.rightMargin: Theme.spacingMedium
        spacing: Theme.spacingMedium
        
        Text {
            text: "Sofa Studio"
            font.bold: true
            color: Theme.textPrimary
            font.pixelSize: 12
        }
        
        Rectangle { width: 1; height: 15; color: Theme.border }

        ComboBox {
            id: connSelector
            Layout.preferredWidth: 200
            Layout.preferredHeight: 22
            model: App.connections
            textRole: "name"
            valueRole: "id"
            
            background: Rectangle {
                implicitWidth: 120
                implicitHeight: 22
                color: Theme.background
                border.color: Theme.border
                radius: Theme.radius
            }
            
            contentItem: Text {
                leftPadding: 10
                rightPadding: 10
                text: connSelector.displayText
                font: connSelector.font
                color: Theme.textPrimary
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            
            onActivated: (index) => {
                // model is an array-like object from C++
                // We need to access the object at index
                // Since it's a QList<QObject*>, QML sees it as a list
                var item = connSelector.model[index]
                if (item) {
                    App.openConnection(item.id)
                }
            }
            
            Connections {
                target: App
                function onConnectionOpened(id) {
                    // Sync ComboBox
                    for (var i = 0; i < connSelector.model.length; i++) {
                        if (connSelector.model[i].id === id) {
                            connSelector.currentIndex = i
                            return
                        }
                    }
                }
            }
        }
        
        AppButton {
            text: "+"
            Layout.preferredHeight: 22
            Layout.preferredWidth: 22
            onClicked: root.requestNewConnection()
            ToolTip.visible: hovered
            ToolTip.text: "New Connection"
        }

        AppButton {
            text: "✎"
            Layout.preferredHeight: 22
            Layout.preferredWidth: 22
            visible: App.activeConnectionId !== -1
            onClicked: root.requestEditConnection(App.activeConnectionId)
            ToolTip.visible: hovered
            ToolTip.text: "Edit Connection"
        }

        AppButton {
            text: "✖"
            Layout.preferredHeight: 22
            Layout.preferredWidth: 22
            visible: App.activeConnectionId !== -1
            onClicked: root.requestDeleteConnection(App.activeConnectionId)
            ToolTip.visible: hovered
            ToolTip.text: "Delete Connection"
        }
        
        // Error Message Display
        Text {
            text: App.lastError
            color: Theme.error
            visible: App.lastError.length > 0
            font.pixelSize: 11
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        
        Item { Layout.fillWidth: true } // Spacer
    }
}
