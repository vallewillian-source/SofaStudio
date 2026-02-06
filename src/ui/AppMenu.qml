import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Controls.Menu {
    id: control
    
    // Custom background
    background: Rectangle {
        implicitWidth: 160
        implicitHeight: 40
        color: Theme.surfaceHighlight
        border.color: Theme.border
        border.width: 1
        radius: Theme.radius
    }

    // Custom delegate (menu item style)
    delegate: Controls.MenuItem {
        id: menuItem
        
        contentItem: Text {
            text: menuItem.text
            font.pixelSize: 11 // Smaller font size
            color: menuItem.highlighted ? Theme.textPrimary : Theme.textSecondary
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            leftPadding: 12
            rightPadding: 12
        }

        background: Rectangle {
            implicitWidth: 160
            implicitHeight: 28 // Smaller item height
            color: menuItem.highlighted ? Theme.border : "transparent" // Subtle hover effect
            radius: 2
            
            // Margins for the background (so it doesn't touch the menu borders)
            anchors.fill: parent
            anchors.margins: 2
        }
    }
    
    // Remove padding/margins from the menu itself to make it compact
    padding: 2
}
