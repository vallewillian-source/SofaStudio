import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    height: 30
    color: Theme.surface
    border.color: Theme.border
    border.width: 1
    
    signal requestNewConnection()
    signal requestEditConnection(var connectionId)
    signal requestDeleteConnection(var connectionId)

    // Internal model for ComboBox
    ListModel {
        id: comboModel
    }

    function syncModel() {
        var currentId = App.activeConnectionId
        var currentIndexToSet = 0 // Default to "Selecione..."
        
        comboModel.clear()
        
        // 0: Selecione...
        comboModel.append({ "id": -1, "name": "Selecione..", "type": "placeholder" })
        
        // Connections
        var conns = App.connections
        for (var i = 0; i < conns.length; i++) {
            var item = conns[i]
            comboModel.append({ "id": item.id, "name": item.name, "type": "connection" })
            if (item.id === currentId) {
                currentIndexToSet = comboModel.count - 1
            }
        }
        
        // Last: New Connection...
        comboModel.append({ "id": -999, "name": "Nova conexão...", "type": "action" })
        
        connSelector.currentIndex = currentIndexToSet
    }

    Component.onCompleted: {
        syncModel()
    }
    
    Connections {
        target: App
        function onConnectionsChanged() { syncModel() }
        function onConnectionOpened(id) { syncModel() }
    }

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
            model: comboModel
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
                var item = comboModel.get(index)
                if (item.type === "action") {
                    // New Connection
                    root.requestNewConnection()
                    // Reset selection to previous valid or placeholder
                    // For now, let's just let it be, the tab opening will handle focus
                    // But maybe we should revert selection if user cancels?
                    // Let's keep it simple.
                    connSelector.currentIndex = 0 
                } else if (item.type === "connection") {
                    App.openConnection(item.id)
                } else {
                    // Placeholder selected
                    App.closeConnection()
                }
            }
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
