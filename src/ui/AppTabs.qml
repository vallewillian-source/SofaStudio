import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

TabBar {
    id: control
    property var tabsModel: null // ListModel
    signal requestCloseTab(int index)
    
    background: Rectangle {
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        // Border only bottom
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
            anchors.bottom: parent.bottom
        }
    }

    Repeater {
        model: control.tabsModel
        
        TabButton {
            id: tabBtn
            width: implicitWidth + 20
            
            contentItem: RowLayout {
                spacing: 8
                
                Text {
                    text: model.title
                    font: tabBtn.font
                    opacity: tabBtn.enabled ? 1.0 : 0.3
                    color: tabBtn.checked ? Theme.textPrimary : Theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    Layout.maximumWidth: 200
                }
                
                // Close Button
                Rectangle {
                    width: 16
                    height: 16
                    radius: 2
                    color: closeMouseArea.containsMouse ? Theme.surfaceHighlight : "transparent"
                    visible: model.type !== "home" // Home tab cannot be closed
                    
                    Text {
                        anchors.centerIn: parent
                        text: "×" // Multiplication sign looks better than X
                        color: tabBtn.checked ? Theme.textPrimary : Theme.textSecondary
                        font.pixelSize: 14
                    }
                    
                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            control.requestCloseTab(index)
                        }
                    }
                }
            }

            background: Rectangle {
                implicitHeight: Theme.tabBarHeight
                color: parent.checked ? Theme.background : "transparent"
                
                // Top highlight line for active tab
                Rectangle {
                    width: parent.width
                    height: 2
                    color: Theme.accent
                    anchors.top: parent.top
                    visible: parent.parent.checked
                }
            }
        }
    }
}
