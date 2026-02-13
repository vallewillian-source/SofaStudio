import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import sofa.ui
import "PostgresDdl.js" as PgDdl

Popup {
    id: root
    parent: Overlay.overlay
    width: {
        if (!parent) return 760
        var maxAllowed = Math.max(440, parent.width - (Theme.spacingXLarge * 2))
        return Math.min(760, maxAllowed)
    }
    height: {
        if (!parent) return 700
        return Math.min(700, parent.height - (Theme.spacingXLarge * 2))
    }
    x: Math.round((parent.width - width) / 2)
    y: Math.max(Theme.spacingXLarge, Math.round((parent.height - height) / 2))
    padding: 0
    modal: true
    focus: true
    clip: true
    closePolicy: Popup.NoAutoClose

    property string schemaName: ""
    property string tableName: ""
    property color accentColor: Theme.accent
    property bool submitting: false
    property string errorMessage: ""

    property bool editing: false
    property bool isConstraintBacked: false

    property string originalName: ""
    property string originalMethod: "btree"
    property bool originalIsUnique: false
    property string originalKeyItemsText: ""
    property string originalIncludeItemsText: ""
    property string originalPredicate: ""
    property string originalAdvancedTailSql: ""

    property string nameValue: ""
    property string methodValue: "btree"
    property bool uniqueValue: false
    property string keyItemsText: ""
    property string includeItemsText: ""
    property string predicateValue: ""
    property string advancedTailValue: ""

    signal submitRequested(var payload)

    readonly property bool readOnlyConstraint: editing && isConstraintBacked

    ListModel {
        id: methodModel
        ListElement { value: "btree" }
        ListElement { value: "hash" }
        ListElement { value: "gin" }
        ListElement { value: "gist" }
        ListElement { value: "spgist" }
        ListElement { value: "brin" }
    }

    function linesVariantToText(value) {
        if (value === null || value === undefined) return ""
        if (Array.isArray(value) || (typeof value === "object" && value.length !== undefined && typeof value !== "string")) {
            var lines = []
            for (var i = 0; i < value.length; i++) {
                var line = String(value[i] === null || value[i] === undefined ? "" : value[i]).trim()
                if (line.length > 0) lines.push(line)
            }
            return lines.join("\n")
        }
        return String(value)
    }

    function setMethodOrDefault(rawValue) {
        var normalized = String(rawValue === null || rawValue === undefined ? "" : rawValue).trim().toLowerCase()
        if (normalized.length === 0) normalized = "btree"
        for (var i = 0; i < methodModel.count; i++) {
            if (String(methodModel.get(i).value) === normalized) {
                return normalized
            }
        }
        return "btree"
    }

    function resetDraftValues() {
        if (editing) {
            nameValue = originalName
            methodValue = originalMethod
            uniqueValue = originalIsUnique
            keyItemsText = originalKeyItemsText
            includeItemsText = originalIncludeItemsText
            predicateValue = originalPredicate
            advancedTailValue = originalAdvancedTailSql
        } else {
            nameValue = ""
            methodValue = "btree"
            uniqueValue = false
            keyItemsText = ""
            includeItemsText = ""
            predicateValue = ""
            advancedTailValue = ""
        }
    }

    function openForAdd(schema, table, context) {
        editing = false
        schemaName = schema || ""
        tableName = table || ""
        submitting = false
        errorMessage = ""
        isConstraintBacked = false

        originalName = ""
        originalMethod = "btree"
        originalIsUnique = false
        originalKeyItemsText = ""
        originalIncludeItemsText = ""
        originalPredicate = ""
        originalAdvancedTailSql = ""

        nameValue = ""
        methodValue = "btree"
        uniqueValue = false
        keyItemsText = ""
        includeItemsText = ""
        predicateValue = ""
        advancedTailValue = ""

        open()
    }

    function openForEdit(schema, table, indexRow) {
        editing = true
        schemaName = schema || ""
        tableName = table || ""
        submitting = false
        errorMessage = ""

        var row = indexRow || ({})
        isConstraintBacked = row.isConstraintBacked === true

        originalName = String(row.name || "")
        originalMethod = setMethodOrDefault(row.method)
        originalIsUnique = row.isUnique === true
        originalKeyItemsText = linesVariantToText(row.keyItems)
        originalIncludeItemsText = linesVariantToText(row.includeItems)
        originalPredicate = String(row.predicate || "")
        originalAdvancedTailSql = String(row.advancedTailSql || "")

        nameValue = originalName
        methodValue = originalMethod
        uniqueValue = originalIsUnique
        keyItemsText = originalKeyItemsText
        includeItemsText = originalIncludeItemsText
        predicateValue = originalPredicate
        advancedTailValue = originalAdvancedTailSql

        open()
    }

    function buildPreviewStatements() {
        var payload = {
            "schema": schemaName,
            "table": tableName,
            "name": nameValue,
            "method": methodValue,
            "isUnique": uniqueValue,
            "keyItems": keyItemsText,
            "includeItems": includeItemsText,
            "predicate": predicateValue,
            "advancedTailSql": advancedTailValue,
            "isConstraintBacked": isConstraintBacked,
            "originalName": originalName,
            "originalMethod": originalMethod,
            "originalIsUnique": originalIsUnique,
            "originalKeyItems": originalKeyItemsText,
            "originalIncludeItems": originalIncludeItemsText,
            "originalPredicate": originalPredicate,
            "originalAdvancedTailSql": originalAdvancedTailSql
        }

        return editing ? PgDdl.buildEditIndexStatements(payload) : PgDdl.buildCreateIndexStatements(payload)
    }

    function previewSqlText() {
        if (readOnlyConstraint) {
            return "-- This index is managed by a table constraint and is read-only here."
        }
        var stmts = buildPreviewStatements()
        if (!stmts || stmts.length === 0) return "-- No changes detected"
        return stmts.map(function(s) { return s + ";" }).join("\n")
    }

    function requestSubmit() {
        if (readOnlyConstraint) {
            errorMessage = "This index is managed by a constraint and cannot be edited here."
            submitting = false
            return
        }

        var payload = {
            "mode": editing ? "edit" : "add",
            "schema": schemaName,
            "table": tableName,
            "name": nameValue,
            "method": methodValue,
            "isUnique": uniqueValue,
            "keyItems": keyItemsText,
            "includeItems": includeItemsText,
            "predicate": predicateValue,
            "advancedTailSql": advancedTailValue,
            "isConstraintBacked": isConstraintBacked,
            "originalName": originalName,
            "originalMethod": originalMethod,
            "originalIsUnique": originalIsUnique,
            "originalKeyItems": originalKeyItemsText,
            "originalIncludeItems": originalIncludeItemsText,
            "originalPredicate": originalPredicate,
            "originalAdvancedTailSql": originalAdvancedTailSql
        }

        errorMessage = ""
        submitting = true
        submitRequested(payload)
    }

    background: Rectangle {
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: 10
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            color: Theme.surfaceHighlight
            border.color: Theme.border
            border.width: 1
            implicitHeight: headerContent.implicitHeight + (Theme.spacingLarge * 2)

            ColumnLayout {
                id: headerContent
                anchors.fill: parent
                anchors.margins: Theme.spacingLarge
                spacing: Theme.spacingMedium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingMedium

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 15
                        color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2)
                        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.45)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: root.accentColor
                            font.bold: true
                            font.pixelSize: 16
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: root.editing ? "Edit Index on " : "Add Index to "
                                color: Theme.textPrimary
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Text {
                                text: root.schemaName.length > 0 ? root.schemaName : "default"
                                color: Theme.textSecondary
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Text {
                                text: "."
                                color: Theme.textSecondary
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.tableName
                                color: root.accentColor
                                font.pixelSize: 20
                                font.bold: true
                                elide: Text.ElideMiddle
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.readOnlyConstraint
                                  ? "This index is linked to a constraint and is read-only."
                                  : (root.editing
                                        ? "Adjust index attributes and save schema changes."
                                        : "Configure index attributes before applying changes.")
                            color: Theme.textSecondary
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }
                    }

                    AppButton {
                        text: "Close"
                        isPrimary: false
                        enabled: !root.submitting
                        onClicked: root.close()
                    }
                }
            }
        }

        ScrollView {
            id: bodyScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Item {
                width: Math.max(bodyScroll.availableWidth, 1)
                implicitHeight: bodyContent.implicitHeight + (Theme.spacingLarge * 2)

                ColumnLayout {
                    id: bodyContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: Theme.spacingLarge
                    anchors.rightMargin: Theme.spacingLarge
                    anchors.topMargin: Theme.spacingLarge
                    spacing: Theme.spacingLarge

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSmall

                        Text {
                            Layout.fillWidth: true
                            text: "SQL preview"
                            color: Theme.textPrimary
                            font.pixelSize: 12
                            font.bold: true
                        }

                        TextArea {
                            id: previewSql
                            Layout.fillWidth: true
                            readOnly: true
                            selectByMouse: true
                            wrapMode: TextEdit.WrapAnywhere
                            leftPadding: 0
                            rightPadding: 0
                            topPadding: 0
                            bottomPadding: 0
                            text: {
                                root.editing
                                root.readOnlyConstraint
                                root.nameValue
                                root.methodValue
                                root.uniqueValue
                                root.keyItemsText
                                root.includeItemsText
                                root.predicateValue
                                root.advancedTailValue
                                root.originalName
                                root.originalMethod
                                root.originalIsUnique
                                root.originalKeyItemsText
                                root.originalIncludeItemsText
                                root.originalPredicate
                                root.originalAdvancedTailSql
                                return root.previewSqlText()
                            }
                            color: Theme.textPrimary
                            selectionColor: Theme.accent
                            selectedTextColor: "#FFFFFF"
                            background: Rectangle { color: "transparent" }
                            font.pixelSize: 11
                            font.family: Qt.platform.os === "osx" ? "Menlo" : "Monospace"
                            implicitHeight: Math.max(40, contentHeight)
                        }

                        SqlSyntaxHighlighter {
                            document: previewSql.textDocument
                            keywordColor: Theme.accentSecondary
                            stringColor: Theme.tintColor(Theme.textPrimary, Theme.connectionAvatarColors[3], 0.55)
                            numberColor: Theme.tintColor(Theme.textPrimary, Theme.connectionAvatarColors[8], 0.65)
                            commentColor: Theme.textSecondary
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: root.width >= 700 ? 2 : 1
                        columnSpacing: Theme.spacingMedium
                        rowSpacing: Theme.spacingMedium

                        Rectangle {
                            Layout.fillWidth: true
                            radius: Theme.radius
                            color: Theme.surface
                            border.width: 0
                            implicitHeight: nameCardContent.implicitHeight + (Theme.spacingMedium * 2)

                            ColumnLayout {
                                id: nameCardContent
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMedium
                                spacing: Theme.spacingSmall

                                Text {
                                    text: "Index Name"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                AppTextField {
                                    Layout.fillWidth: true
                                    accentColor: root.accentColor
                                    enabled: !root.submitting && !root.readOnlyConstraint
                                    text: root.nameValue
                                    placeholderText: "idx_table_column"
                                    onTextChanged: root.nameValue = text
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            radius: Theme.radius
                            color: Theme.surface
                            border.width: 0
                            implicitHeight: methodCardContent.implicitHeight + (Theme.spacingMedium * 2)

                            ColumnLayout {
                                id: methodCardContent
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMedium
                                spacing: Theme.spacingSmall

                                Text {
                                    text: "Method"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                ComboBox {
                                    id: methodCombo
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Theme.buttonHeight
                                    enabled: !root.submitting && !root.readOnlyConstraint
                                    textRole: "value"
                                    model: methodModel
                                    currentIndex: {
                                        for (var i = 0; i < methodModel.count; i++) {
                                            if (String(methodModel.get(i).value) === root.methodValue) return i
                                        }
                                        return 0
                                    }
                                    onActivated: {
                                        if (currentIndex >= 0 && currentIndex < methodModel.count) {
                                            root.methodValue = String(methodModel.get(currentIndex).value)
                                        }
                                    }

                                    background: Rectangle {
                                        implicitHeight: Theme.buttonHeight
                                        color: Theme.surface
                                        border.color: methodCombo.activeFocus ? root.accentColor : Theme.border
                                        border.width: 1
                                        radius: Theme.radius
                                    }

                                    contentItem: Text {
                                        leftPadding: 10
                                        rightPadding: 10
                                        text: methodCombo.displayText
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.columnSpan: columns
                            radius: Theme.radius
                            color: Theme.surface
                            border.width: 0
                            implicitHeight: uniqueCardContent.implicitHeight + (Theme.spacingMedium * 2)

                            ColumnLayout {
                                id: uniqueCardContent
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMedium
                                spacing: Theme.spacingSmall

                                Text {
                                    text: "Constraints"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                CheckBox {
                                    enabled: !root.submitting && !root.readOnlyConstraint
                                    text: "Unique index"
                                    checked: root.uniqueValue
                                    onToggled: root.uniqueValue = checked

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 13
                                        color: parent.enabled ? Theme.textPrimary : Theme.textSecondary
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: parent.indicator.width + parent.spacing
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.columnSpan: columns
                            radius: Theme.radius
                            color: Theme.surface
                            border.width: 0
                            implicitHeight: keyCardContent.implicitHeight + (Theme.spacingMedium * 2)

                            ColumnLayout {
                                id: keyCardContent
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMedium
                                spacing: Theme.spacingSmall

                                Text {
                                    text: "Key items (one per line)"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 94
                                    color: Theme.surface
                                    border.color: keyItemsInput.activeFocus ? root.accentColor : Theme.border
                                    border.width: 1
                                    radius: Theme.radius

                                    TextArea {
                                        id: keyItemsInput
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        enabled: !root.submitting && !root.readOnlyConstraint
                                        text: root.keyItemsText
                                        selectByMouse: true
                                        wrapMode: TextEdit.Wrap
                                        leftPadding: 10
                                        rightPadding: 10
                                        topPadding: 8
                                        bottomPadding: 8
                                        selectionColor: root.accentColor
                                        selectedTextColor: "#FFFFFF"
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        background: Rectangle { color: "transparent" }
                                        onTextChanged: root.keyItemsText = text
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.columnSpan: columns
                            radius: Theme.radius
                            color: Theme.surface
                            border.width: 0
                            implicitHeight: includeCardContent.implicitHeight + (Theme.spacingMedium * 2)

                            ColumnLayout {
                                id: includeCardContent
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMedium
                                spacing: Theme.spacingSmall

                                Text {
                                    text: "Include items (optional, one per line)"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 82
                                    color: Theme.surface
                                    border.color: includeItemsInput.activeFocus ? root.accentColor : Theme.border
                                    border.width: 1
                                    radius: Theme.radius

                                    TextArea {
                                        id: includeItemsInput
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        enabled: !root.submitting && !root.readOnlyConstraint
                                        text: root.includeItemsText
                                        selectByMouse: true
                                        wrapMode: TextEdit.Wrap
                                        leftPadding: 10
                                        rightPadding: 10
                                        topPadding: 8
                                        bottomPadding: 8
                                        selectionColor: root.accentColor
                                        selectedTextColor: "#FFFFFF"
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        background: Rectangle { color: "transparent" }
                                        onTextChanged: root.includeItemsText = text
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.columnSpan: columns
                            radius: Theme.radius
                            color: Theme.surface
                            border.width: 0
                            implicitHeight: predicateCardContent.implicitHeight + (Theme.spacingMedium * 2)

                            ColumnLayout {
                                id: predicateCardContent
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMedium
                                spacing: Theme.spacingSmall

                                Text {
                                    text: "WHERE predicate (optional)"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                AppTextField {
                                    Layout.fillWidth: true
                                    accentColor: root.accentColor
                                    enabled: !root.submitting && !root.readOnlyConstraint
                                    text: root.predicateValue
                                    placeholderText: "status = 'active'"
                                    onTextChanged: root.predicateValue = text
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.columnSpan: columns
                            radius: Theme.radius
                            color: Theme.surface
                            border.width: 0
                            implicitHeight: advancedCardContent.implicitHeight + (Theme.spacingMedium * 2)

                            ColumnLayout {
                                id: advancedCardContent
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMedium
                                spacing: Theme.spacingSmall

                                Text {
                                    text: "Advanced tail SQL (optional)"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 82
                                    color: Theme.surface
                                    border.color: advancedInput.activeFocus ? root.accentColor : Theme.border
                                    border.width: 1
                                    radius: Theme.radius

                                    TextArea {
                                        id: advancedInput
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        enabled: !root.submitting && !root.readOnlyConstraint
                                        text: root.advancedTailValue
                                        selectByMouse: true
                                        wrapMode: TextEdit.Wrap
                                        leftPadding: 10
                                        rightPadding: 10
                                        topPadding: 8
                                        bottomPadding: 8
                                        selectionColor: root.accentColor
                                        selectedTextColor: "#FFFFFF"
                                        color: Theme.textPrimary
                                        font.pixelSize: 13
                                        background: Rectangle { color: "transparent" }
                                        onTextChanged: root.advancedTailValue = text
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.spacingSmall
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            color: Theme.surface
            border.color: Theme.border
            border.width: 1
            implicitHeight: footerContent.implicitHeight + (Theme.spacingLarge * 2)

            ColumnLayout {
                id: footerContent
                anchors.fill: parent
                anchors.margins: Theme.spacingLarge
                spacing: Theme.spacingLarge

                Rectangle {
                    Layout.fillWidth: true
                    visible: root.errorMessage.length > 0
                    Layout.preferredHeight: root.errorMessage.length > 0 ? footerErrorText.implicitHeight + (Theme.spacingMedium * 2) : 0
                    radius: Theme.radius
                    color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12)
                    border.color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.38)
                    border.width: 1

                    Text {
                        id: footerErrorText
                        anchors.fill: parent
                        anchors.margins: Theme.spacingMedium
                        wrapMode: Text.WordWrap
                        text: root.errorMessage
                        color: Theme.error
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingMedium

                    AppButton {
                        text: "Reset Values"
                        isOutline: true
                        accentColor: root.accentColor
                        enabled: !root.submitting
                        onClicked: root.resetDraftValues()
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Tip: Key items and advanced sections accept raw SQL fragments."
                        color: Theme.textSecondary
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    AppButton {
                        text: "Cancel"
                        isPrimary: false
                        enabled: !root.submitting
                        onClicked: root.close()
                    }

                    AppButton {
                        text: root.submitting
                              ? (root.editing ? "Saving..." : "Creating...")
                              : (root.editing ? "Save Changes" : "Add Index")
                        isPrimary: true
                        accentColor: root.accentColor
                        enabled: !root.submitting && !root.readOnlyConstraint
                        onClicked: root.requestSubmit()
                    }
                }
            }
        }
    }
}
