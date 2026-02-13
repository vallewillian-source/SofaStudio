import QtQuick
import QtQuick.Controls
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import sofa.ui
import "PostgresDdl.js" as PgDdl

Item {
    id: root
    focus: true

    property string schema: "public"
    property string tableName: ""
    property color accentColor: {
        var id = App.activeConnectionId
        if (id === -1) return Theme.accent
        var conns = App.connections
        for (var i = 0; i < conns.length; i++) {
            if (conns[i].id === id) {
                return Theme.getConnectionColor(conns[i].name, conns[i].color)
            }
        }
        return Theme.accent
    }

    property bool loading: false
    property bool ddlRunning: false
    property string errorMessage: ""
    property string requestTag: ""
    property string ddlBaseTag: ""
    property string ddlActiveTag: ""
    property var ddlStatements: []
    property int ddlIndex: -1
    property var ddlOnSuccess: null
    property var ddlOnError: null

    readonly property int colNameWidth: 220
    readonly property int colMethodWidth: 120
    readonly property int colUniqueWidth: 90
    readonly property int colKeysMinWidth: 280
    readonly property int colPredicateMinWidth: 220
    readonly property int colActionsWidth: 72
    readonly property int colSpacing: Theme.spacingMedium
    readonly property int indexesTableMinWidth: (Theme.spacingLarge * 2)
        + colNameWidth
        + colMethodWidth
        + colUniqueWidth
        + colKeysMinWidth
        + colPredicateMinWidth
        + colActionsWidth
        + (colSpacing * 5)

    signal requestReloadTableData(string schema, string tableName)

    ListModel { id: indexesModel }

    function loadIndexes() {
        if (!schema || !tableName) return
        loading = true
        errorMessage = ""
        requestTag = "indexes:" + schema + "." + tableName + ":" + Date.now()
        var ok = App.getTableIndexesAsync(schema, tableName, requestTag)
        if (!ok) {
            loading = false
            errorMessage = App.lastError
        }
    }

    function refreshAfterDDL() {
        loadIndexes()
        requestReloadTableData(schema, tableName)
    }

    function runNextDdlStatement() {
        if (ddlIndex < 0 || ddlIndex >= ddlStatements.length) {
            ddlRunning = false
            ddlActiveTag = ""
            var cb = ddlOnSuccess
            ddlOnSuccess = null
            ddlOnError = null
            ddlStatements = []
            ddlIndex = -1
            if (cb) cb()
            return
        }

        ddlActiveTag = ddlBaseTag + ":" + ddlIndex
        var ok = App.runQueryAsync(String(ddlStatements[ddlIndex]), ddlActiveTag)
        if (!ok) {
            ddlRunning = false
            var err = App.lastError
            var ecb = ddlOnError
            ddlOnSuccess = null
            ddlOnError = null
            ddlStatements = []
            ddlIndex = -1
            ddlActiveTag = ""
            if (ecb) ecb(err)
        }
    }

    function runStatementsSequentially(statements, onSuccess, onError) {
        if (!statements || statements.length === 0) {
            if (onSuccess) onSuccess()
            return
        }
        ddlRunning = true
        errorMessage = ""
        ddlStatements = statements
        ddlIndex = 0
        ddlBaseTag = "ddl:indexes:" + schema + "." + tableName + ":" + Date.now()
        ddlOnSuccess = onSuccess
        ddlOnError = onError
        runNextDdlStatement()
    }

    function openAddIndexModal() {
        indexEditorModal.accentColor = root.accentColor
        indexEditorModal.openForAdd(schema, tableName, {})
    }

    function openEditIndexModal(indexRow) {
        if (!indexRow || indexRow.isConstraintBacked === true) {
            return
        }
        indexEditorModal.accentColor = root.accentColor
        indexEditorModal.openForEdit(schema, tableName, indexRow)
    }

    function keyItemsDisplay(row) {
        if (!row || !row.keyItems) return ""
        var value = row.keyItems
        if (Array.isArray(value) || (typeof value === "object" && value.length !== undefined && typeof value !== "string")) {
            var parts = []
            for (var i = 0; i < value.length; i++) {
                parts.push(String(value[i]))
            }
            return parts.join(", ")
        }
        return String(value)
    }

    property string pendingDropIndexName: ""
    property bool pendingDropConstraintBacked: false
    property string pendingDropConstraintName: ""
    property string dropConfirmError: ""

    function confirmDropIndex(indexRow) {
        if (!indexRow) return
        pendingDropIndexName = String(indexRow.name || "")
        pendingDropConstraintBacked = indexRow.isConstraintBacked === true
        pendingDropConstraintName = String(indexRow.constraintName || "")
        dropConfirmError = ""
        dropConfirmPopup.open()
    }

    IndexEditorModal {
        id: indexEditorModal
        accentColor: root.accentColor

        onSubmitRequested: function(payload) {
            var statements = []
            if (payload.mode === "add") {
                statements = PgDdl.buildCreateIndexStatements(payload)
            } else {
                statements = PgDdl.buildEditIndexStatements(payload)
            }

            if (!statements || statements.length === 0) {
                indexEditorModal.submitting = false
                indexEditorModal.errorMessage = payload.isConstraintBacked
                    ? "This index is managed by a constraint and cannot be edited here."
                    : "Nothing to apply. Check index name and key items."
                return
            }

            runStatementsSequentially(
                statements,
                function() {
                    indexEditorModal.submitting = false
                    indexEditorModal.errorMessage = ""
                    indexEditorModal.close()
                    refreshAfterDDL()
                },
                function(err) {
                    indexEditorModal.submitting = false
                    indexEditorModal.errorMessage = err
                }
            )
        }
    }

    Popup {
        id: dropConfirmPopup
        parent: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        width: 420
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        padding: Theme.spacingLarge
        implicitHeight: dropConfirmContent.implicitHeight + topPadding + bottomPadding

        background: Rectangle {
            color: Theme.surface
            border.color: Theme.border
            border.width: 1
            radius: 8
        }

        contentItem: ColumnLayout {
            id: dropConfirmContent
            width: dropConfirmPopup.availableWidth
            spacing: Theme.spacingMedium

            Text {
                Layout.fillWidth: true
                text: "Drop index?"
                color: Theme.textPrimary
                font.pixelSize: 15
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: "Drop index \"" + pendingDropIndexName + "\" from " + schema + "." + tableName + "?"
                color: Theme.textSecondary
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                visible: pendingDropConstraintBacked
                text: "This index is managed by constraint \"" + pendingDropConstraintName + "\" and cannot be dropped here."
                color: Theme.textSecondary
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                visible: dropConfirmError.length > 0
                color: Theme.tintColor(Theme.background, Theme.error, 0.10)
                border.color: Theme.tintColor(Theme.border, Theme.error, 0.55)
                border.width: 1
                radius: Theme.radius

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacingMedium
                    text: dropConfirmError
                    color: Theme.textPrimary
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMedium

                Item { Layout.fillWidth: true }

                AppButton {
                    text: "Cancel"
                    isPrimary: false
                    enabled: !ddlRunning
                    onClicked: dropConfirmPopup.close()
                }

                AppButton {
                    text: ddlRunning ? "Dropping..." : "Drop"
                    isPrimary: true
                    accentColor: Theme.error
                    enabled: !ddlRunning && !pendingDropConstraintBacked
                    onClicked: {
                        var statements = PgDdl.buildDropIndexStatements({
                            "schema": schema,
                            "indexName": pendingDropIndexName,
                            "isConstraintBacked": pendingDropConstraintBacked
                        })
                        runStatementsSequentially(
                            statements,
                            function() {
                                dropConfirmPopup.close()
                                refreshAfterDDL()
                            },
                            function(err) {
                                dropConfirmError = err
                            }
                        )
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: Theme.surface
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingLarge
                anchors.rightMargin: Theme.spacingLarge
                spacing: Theme.spacingMedium

                RowLayout {
                    spacing: 10

                    ColumnLayout {
                        spacing: 1

                        Text {
                            text: "Indexes"
                            color: Theme.textPrimary
                            font.pixelSize: 14
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: schema + "." + tableName
                            color: Theme.textSecondary
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }

                    AppButton {
                        text: ""
                        icon.source: "qrc:/qt/qml/sofa/ui/assets/rotate-right-solid-full.svg"
                        isPrimary: false
                        isOutline: true
                        accentColor: root.accentColor
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: 24
                        horizontalPadding: 0
                        verticalPadding: 0
                        iconSize: 12
                        enabled: !loading && !ddlRunning
                        tooltip: "Refresh indexes"
                        onClicked: loadIndexes()
                    }
                }

                Item { Layout.fillWidth: true }

                AppButton {
                    text: "Add index"
                    icon.source: "qrc:/qt/qml/sofa/ui/assets/plus-solid-full.svg"
                    isPrimary: true
                    accentColor: root.accentColor
                    Layout.preferredHeight: 28
                    iconSize: 12
                    spacing: 5
                    enabled: !loading && !ddlRunning
                    onClicked: openAddIndexModal()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                visible: loading || errorMessage.length > 0
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingMedium

                    Text {
                        text: loading ? "Loading indexes..." : "Error loading indexes"
                        color: Theme.textPrimary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        visible: !loading && errorMessage.length > 0
                        text: errorMessage
                        color: Theme.textSecondary
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        Layout.maximumWidth: 520
                    }

                    AppButton {
                        visible: !loading
                        text: "Try again"
                        isPrimary: true
                        accentColor: root.accentColor
                        onClicked: loadIndexes()
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                visible: !loading && errorMessage.length === 0
                spacing: 0

                Flickable {
                    id: indexesHorizontalFlick
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.HorizontalFlick
                    contentWidth: Math.max(width, root.indexesTableMinWidth)
                    contentHeight: height
                    interactive: contentWidth > width

                    ScrollBar.horizontal: ScrollBar {
                        policy: indexesHorizontalFlick.contentWidth > indexesHorizontalFlick.width
                            ? ScrollBar.AsNeeded
                            : ScrollBar.AlwaysOff
                    }

                    Item {
                        width: indexesHorizontalFlick.contentWidth
                        height: indexesHorizontalFlick.height

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                color: Theme.surface
                                border.color: Theme.border
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.spacingLarge
                                    anchors.rightMargin: Theme.spacingLarge
                                    spacing: root.colSpacing

                                    Text { text: "Name"; color: Theme.textSecondary; font.pixelSize: 11; font.bold: true; Layout.minimumWidth: root.colNameWidth; Layout.preferredWidth: root.colNameWidth }
                                    Text { text: "Method"; color: Theme.textSecondary; font.pixelSize: 11; font.bold: true; Layout.minimumWidth: root.colMethodWidth; Layout.preferredWidth: root.colMethodWidth }
                                    Text { text: "Unique"; color: Theme.textSecondary; font.pixelSize: 11; font.bold: true; Layout.minimumWidth: root.colUniqueWidth; Layout.preferredWidth: root.colUniqueWidth }
                                    Text { text: "Keys"; color: Theme.textSecondary; font.pixelSize: 11; font.bold: true; Layout.minimumWidth: root.colKeysMinWidth; Layout.preferredWidth: root.colKeysMinWidth; Layout.fillWidth: true }
                                    Text { text: "Predicate"; color: Theme.textSecondary; font.pixelSize: 11; font.bold: true; Layout.minimumWidth: root.colPredicateMinWidth; Layout.preferredWidth: root.colPredicateMinWidth }
                                    Item { Layout.minimumWidth: root.colActionsWidth; Layout.preferredWidth: root.colActionsWidth }
                                }
                            }

                            ListView {
                                id: indexesListView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                model: indexesModel
                                boundsBehavior: Flickable.StopAtBounds

                                delegate: Rectangle {
                                    width: indexesListView.width
                                    height: 44
                                    color: index % 2 === 0 ? "transparent" : Theme.tintColor(Theme.background, root.accentColor, 0.03)
                                    border.color: Theme.border
                                    border.width: 0

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.spacingLarge
                                        anchors.rightMargin: Theme.spacingLarge
                                        spacing: root.colSpacing

                                        Text {
                                            text: String(model.name || "")
                                            color: Theme.textPrimary
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                            Layout.minimumWidth: root.colNameWidth
                                            Layout.preferredWidth: root.colNameWidth
                                        }

                                        Text {
                                            text: String(model.method || "")
                                            color: Theme.textPrimary
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                            Layout.minimumWidth: root.colMethodWidth
                                            Layout.preferredWidth: root.colMethodWidth
                                        }

                                        Text {
                                            text: model.isUnique === true ? "true" : "false"
                                            color: model.isUnique === true ? root.accentColor : Theme.textSecondary
                                            font.pixelSize: 12
                                            Layout.minimumWidth: root.colUniqueWidth
                                            Layout.preferredWidth: root.colUniqueWidth
                                        }

                                        Item {
                                            Layout.minimumWidth: root.colKeysMinWidth
                                            Layout.preferredWidth: root.colKeysMinWidth
                                            Layout.fillWidth: true
                                            height: parent.height

                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                text: root.keyItemsDisplay(model)
                                                color: Theme.textSecondary
                                                font.pixelSize: 12
                                                elide: Text.ElideRight
                                            }

                                            ToolTip {
                                                visible: keysMouse.containsMouse && root.keyItemsDisplay(model).length > 0
                                                text: root.keyItemsDisplay(model)
                                                delay: 400
                                                contentItem: Text { text: root.keyItemsDisplay(model); color: Theme.textPrimary; font.pixelSize: 12 }
                                                background: Rectangle { color: Theme.surfaceHighlight; border.color: Theme.border; border.width: 1; radius: 4 }
                                            }

                                            MouseArea {
                                                id: keysMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                acceptedButtons: Qt.NoButton
                                            }
                                        }

                                        Text {
                                            text: String(model.predicate || "")
                                            color: Theme.textSecondary
                                            font.pixelSize: 12
                                            Layout.minimumWidth: root.colPredicateMinWidth
                                            Layout.preferredWidth: root.colPredicateMinWidth
                                            elide: Text.ElideRight
                                        }

                                        RowLayout {
                                            Layout.minimumWidth: root.colActionsWidth
                                            Layout.preferredWidth: root.colActionsWidth
                                            spacing: 6

                                            Controls.Button {
                                                Layout.preferredWidth: 24
                                                Layout.preferredHeight: 24
                                                padding: 0
                                                enabled: !ddlRunning && model.isConstraintBacked !== true
                                                onClicked: root.openEditIndexModal(model)
                                                background: Rectangle { radius: 4; color: parent.hovered ? Theme.surfaceHighlight : "transparent" }
                                                contentItem: Text {
                                                    text: "✎"
                                                    color: parent.hovered ? Theme.textPrimary : Theme.textSecondary
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                ToolTip.visible: parent.hovered
                                                ToolTip.text: model.isConstraintBacked === true
                                                    ? "Managed by constraint \"" + String(model.constraintName || "") + "\" (read-only here)."
                                                    : "Edit index"
                                            }

                                            Controls.Button {
                                                Layout.preferredWidth: 24
                                                Layout.preferredHeight: 24
                                                padding: 0
                                                enabled: !ddlRunning && model.isConstraintBacked !== true
                                                onClicked: root.confirmDropIndex(model)
                                                background: Rectangle { radius: 4; color: parent.hovered ? Theme.surfaceHighlight : "transparent" }
                                                contentItem: Text {
                                                    text: "✕"
                                                    color: parent.hovered ? Theme.error : Theme.textSecondary
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                ToolTip.visible: parent.hovered
                                                ToolTip.text: model.isConstraintBacked === true
                                                    ? "Managed by constraint \"" + String(model.constraintName || "") + "\" (read-only here)."
                                                    : "Drop index"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: App

        function onTableIndexesFinished(tag, result) {
            if (tag !== root.requestTag) return
            root.loading = false
            root.errorMessage = ""
            indexesModel.clear()

            var indexes = result.indexes || []
            for (var i = 0; i < indexes.length; i++) {
                var idx = indexes[i]
                indexesModel.append({
                    "name": idx.name || "",
                    "method": idx.method || "",
                    "isUnique": idx.isUnique === true,
                    "isPrimary": idx.isPrimary === true,
                    "isValid": idx.isValid !== false,
                    "isConstraintBacked": idx.isConstraintBacked === true,
                    "constraintName": idx.constraintName || "",
                    "constraintType": idx.constraintType || "",
                    "definitionSql": idx.definitionSql || "",
                    "predicate": idx.predicate || "",
                    "keyItems": idx.keyItems || [],
                    "includeItems": idx.includeItems || [],
                    "advancedTailSql": idx.advancedTailSql || ""
                })
            }
        }

        function onTableIndexesError(tag, error) {
            if (tag !== root.requestTag && root.requestTag.length > 0) return
            root.loading = false
            indexesModel.clear()
            root.errorMessage = error
        }

        function onSqlFinished(tag, result) {
            if (tag !== root.ddlActiveTag) return
            root.ddlIndex += 1
            root.runNextDdlStatement()
        }

        function onSqlError(tag, error) {
            if (tag !== root.ddlActiveTag) return
            root.ddlRunning = false
            var ecb = root.ddlOnError
            root.ddlOnSuccess = null
            root.ddlOnError = null
            root.ddlStatements = []
            root.ddlIndex = -1
            root.ddlActiveTag = ""
            if (ecb) ecb(error)
        }
    }
}
