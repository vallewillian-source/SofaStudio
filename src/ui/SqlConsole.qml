import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import sofa.ui
import sofa.datagrid 1.0

Item {
    id: root
    
    // SplitView for Editor (top) and Results (bottom)
    SplitView {
        anchors.fill: parent
        orientation: Qt.Vertical
        
        // Editor Area
        Rectangle {
            SplitView.preferredHeight: parent.height * 0.4
            SplitView.minimumHeight: 100
            color: Theme.background
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Toolbar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingMedium
                        anchors.rightMargin: Theme.spacingMedium
                        spacing: Theme.spacingMedium
                        
                        AppButton {
                            text: "Run"
                            highlighted: true
                            onClicked: runQuery()
                        }
                        
                        Label {
                            text: "(Cmd+Enter)"
                            color: Theme.textSecondary
                            font.pixelSize: 11
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // Editor
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    TextArea {
                        id: queryEditor
                        font.family: "Monospace" // TODO: Use a proper mono font
                        font.pixelSize: 13
                        color: Theme.textPrimary
                        selectionColor: Theme.accent
                        selectedTextColor: "#FFFFFF"
                        selectByMouse: true
                        background: Rectangle { color: Theme.background }
                        padding: 10
                        text: "SELECT * FROM users LIMIT 10;"
                        
                        Keys.onPressed: (event) => {
                            if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && (event.modifiers & Qt.ControlModifier || event.modifiers & Qt.MetaModifier)) {
                                runQuery();
                                event.accepted = true;
                            }
                        }
                    }
                }
            }
        }
        
        // Results Area
        Rectangle {
            SplitView.fillHeight: true
            color: Theme.background
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                DataGrid {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    engine: gridEngine
                }
                
                // Status Bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        
                        Label {
                            id: statusLabel
                            text: "Ready"
                            color: Theme.textSecondary
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
    
    DataGridEngine {
        id: gridEngine
    }
    
    function runQuery() {
        var query = queryEditor.text;
        if (!query.trim()) return;
        
        statusLabel.text = "Running...";
        
        // Call C++ AppContext
        var result = App.runQuery(query);
        
        if (result.error) {
            statusLabel.text = "Error: " + result.error;
            return;
        }
        
        gridEngine.loadFromVariant(result);
        
        var msg = "Done.";
        if (result.executionTime) {
            msg += " Time: " + result.executionTime + "ms";
        }
        if (result.warning) {
            msg += " Warning: " + result.warning;
        }
        statusLabel.text = msg;
    }
}
