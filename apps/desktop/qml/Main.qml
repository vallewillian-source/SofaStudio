import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import sofa.ui
import sofa.datagrid 1.0

ApplicationWindow {
    width: 1024
    height: 768
    visible: true
    title: qsTr("Sofa Studio")
    color: Theme.background
    
    ListModel {
        id: tabModel
        ListElement { 
            title: "Home"
            type: "home"
            schema: ""
            tableName: ""
        }
    }
    
    function openTable(schema, tableName) {
        var title = "Table: " + schema + "." + tableName
        console.log("\u001b[36m📌 Abrindo aba\u001b[0m", title)
        // Check if already open
        for (var i = 0; i < tabModel.count; i++) {
            if (tabModel.get(i).title === title) {
                appTabs.currentIndex = i
                return
            }
        }
        tabModel.append({ "title": title, "type": "table", "schema": schema, "tableName": tableName })
        appTabs.currentIndex = tabModel.count - 1
    }

    function openSqlConsole() {
        tabModel.append({ "title": "SQL Console", "type": "sql" })
        appTabs.currentIndex = tabModel.count - 1
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left Sidebar
        AppSidebar {
            Layout.fillHeight: true
            Layout.preferredWidth: Theme.sidebarWidth
        }

        // Database Explorer
        DatabaseExplorer {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            visible: App.activeConnectionId !== -1
            onTableClicked: function(schema, tableName) {
                openTable(schema, tableName)
            }
            onNewQueryClicked: openSqlConsole()
        }

        // Main Content Area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Top Tabs
            AppTabs {
                id: appTabs
                Layout.fillWidth: true
                tabsModel: tabModel
            }
            
            // Content Area
            StackLayout {
                currentIndex: appTabs.currentIndex
                Layout.fillWidth: true
                Layout.fillHeight: true
                onCurrentIndexChanged: console.log("\u001b[35m🥞 StackLayout\u001b[0m", "index=" + currentIndex)
                
                Repeater {
                    model: tabModel
                    
                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        property string itemType: model.type || "home"
                        property string itemSchema: model.schema || "public"
                        property string itemTable: model.tableName || ""
                        
                        sourceComponent: itemType === "home" ? homeComponent : (itemType === "table" ? tableComponent : sqlComponent)
                        
                        onLoaded: {
                            console.log("\u001b[36m🧭 Loader\u001b[0m", "index=" + index, "type=" + itemType, "schema=" + itemSchema, "table=" + itemTable)
                            if (item && itemType === "table") {
                                item.schema = itemSchema
                                item.tableName = itemTable
                                item.loadData()
                            }
                        }
                        
                        onItemTypeChanged: console.log("Loader type changed:", index, itemType)
                    }
                }
            }
        }
    }
    
    Component {
        id: sqlComponent
        SqlConsole {
            
        }
    }

    Component {
        id: homeComponent
        Rectangle {
            color: Theme.background
            Column {
                anchors.centerIn: parent
                spacing: 20
                Text {
                    text: qsTr("Boot OK")
                    font.pixelSize: 24
                    color: Theme.textPrimary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                AppButton {
                    text: "Test Command"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        App.executeCommand("test.hello")
                    }
                }
            }
        }
    }
    
    Component {
        id: tableComponent
        Rectangle {
            id: tableRoot
            property string schema: "public"
            property string tableName: ""
            property string errorMessage: ""
            color: Theme.background
            
            DataGridEngine {
                id: gridEngine
            }

            DataGrid {
                anchors.fill: parent
                engine: gridEngine
            }

            Text {
                visible: tableRoot.errorMessage.length > 0
                text: tableRoot.errorMessage
                color: Theme.error
                font.pixelSize: 14
                anchors.centerIn: parent
            }

            function loadData() {
                tableRoot.errorMessage = ""
                if (tableName) {
                    console.log("\u001b[34m📥 Buscando dados\u001b[0m", schema + "." + tableName)
                    var data = App.getDataset(schema, tableName, 100, 0)
                    console.log("\u001b[32m✅ Dataset recebido\u001b[0m", "colunas=" + (data.columns ? data.columns.length : 0) + " linhas=" + (data.rows ? data.rows.length : 0))
                    if (data.rows && data.rows.length > 0) {
                        console.log("\u001b[35m🧪 Dataset primeira linha\u001b[0m", JSON.stringify(data.rows[0]))
                    }
                    if (data.error) {
                        console.error("\u001b[31m❌ Dataset\u001b[0m", data.error)
                        tableRoot.errorMessage = data.error
                        gridEngine.clear()
                        return
                    }
                    if (!data.columns || data.columns.length === 0) {
                        tableRoot.errorMessage = "Falha ao carregar dados da tabela."
                        gridEngine.clear()
                        return
                    }
                    gridEngine.loadFromVariant(data)
                } else {
                    tableRoot.errorMessage = "Tabela inválida."
                    gridEngine.clear()
                }
            }
        }
    }
}
