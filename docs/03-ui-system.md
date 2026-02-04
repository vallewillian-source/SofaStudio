# UI System

The User Interface is built with Qt Quick (QML) and controls the application flow.

## Structure

*   **`Main.qml`**: The entry point. It manages the global `StackLayout` or `Loader` state (Home vs Table View vs SQL Console).
*   **`AppSidebar`**: Persistent navigation rail on the left.
*   **`AppTabs`**: (If implemented) Manages open query/table sessions.

## Theming

**File:** [Theme.qml](file:///Users/vallewillian/www/sofa-studio/src/ui/Theme.qml)

A singleton object (`Theme`) provides semantic color definitions. Hardcoded hex values should be avoided in components.

*   `Theme.background`: Main app background.
*   `Theme.surface`: Cards, sidebars, headers.
*   `Theme.accent`: Primary action color (Blue).
*   `Theme.textPrimary` / `Theme.textSecondary`: Typography.

## Key Components

### DataGrid
**File:** [DataGrid.qml](file:///Users/vallewillian/www/sofa-studio/src/ui/DataGrid.qml)
A wrapper around the C++ `DataGridEngine`.
*   **Properties**: `engine` (reference to C++ object), `controlsVisible`.
*   **Internals**: Uses `DataGridView` (C++ item) for the actual grid area and standard QML `ScrollBar`s for navigation.

### SqlConsole
**File:** [SqlConsole.qml](file:///Users/vallewillian/www/sofa-studio/src/ui/SqlConsole.qml)
A split-view component:
*   **Top**: `TextArea` for SQL input.
*   **Bottom**: `DataGrid` for results.
*   **Logic**: Handles `Cmd+Enter` to run, `Esc` to cancel. Manages loading states and error messages.

### ViewEditor
**File:** [ViewEditor.qml](file:///Users/vallewillian/www/sofa-studio/src/ui/ViewEditor.qml)
Allows users to customize how a table is displayed.
*   **Input**: `tableSchema` (JSON).
*   **Output**: Modified JSON definition.
*   **Persistence**: Saves changes to `LocalStore` via `App.saveView()`.

## Signal Flow Example: "Run Query"

1.  `SqlConsole` calls `App.runQueryAsync()`.
2.  `SqlConsole` listens to `Connections { target: App }`.
3.  `onSqlStarted`: Sets `running = true`, shows loading spinner.
4.  `onSqlFinished`:
    *   Sets `running = false`.
    *   Calls `gridEngine.loadFromVariant(result)` to populate the C++ grid model.
    *   Updates status bar with row count and execution time.
5.  `onSqlError`: Displays error banner.
