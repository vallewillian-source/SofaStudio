# Architecture Overview

## System Design

Sofa Studio follows a **hybrid architecture** combining a performance-critical C++ core with a flexible QML-based user interface. The system is designed around the concept of **Add-ons** for database support, ensuring the core remains agnostic to specific database technologies.

### High-Level Components

1.  **Sofa Core (C++)**:
    *   **Bootstrap**: Initializes the Qt application, dependency injection container, and core services.
    *   **AppContext**: The main facade/singleton exposed to QML. Manages application state, sessions, and inter-module communication.
    *   **Services**: `LocalStoreService` (persistence), `SecretsService` (credential management), `CommandService` (actions).
    *   **Universal Data Model (UDM)**: Common C++ structs (`TableSchema`, `Column`, `DatasetPage`) used to exchange data between Add-ons and the UI.

2.  **Add-on System (C++)**:
    *   **AddonHost**: Discovers and manages database drivers.
    *   **Interfaces**: `IAddon`, `IConnectionProvider`, `ICatalogProvider`, `IQueryProvider`.
    *   **Implementations**: Database-specific logic (e.g., PostgreSQL) resides here, isolated from the core.

3.  **UI Layer (QML/JavaScript)**:
    *   **View Layer**: Completely declarative QML for layout and interaction.
    *   **Logic**: JavaScript used for UI state management and calling C++ `AppContext` methods.
    *   **Custom Renderers**: Performance-heavy components (like `DataGrid`) use C++ `QQuickPaintedItem` for rendering while exposing a QML API.

## Data Flow

### 1. Query Execution Flow

1.  **User Action**: User clicks "Run" in `SqlConsole.qml`.
2.  **QML Layer**: Calls `App.runQueryAsync(query, tag)` (where `App` is the `AppContext` singleton).
3.  **AppContext**:
    *   Validates the active connection.
    *   Creates a `QueryWorker` and moves it to a background `QThread`.
    *   Emits `sqlStarted` signal to UI.
4.  **Worker Thread**:
    *   Calls `IConnectionProvider::query()->execute()`.
    *   The Add-on translates the request to the specific DB driver (e.g., `libpq` or `QSqlDatabase`).
    *   Returns a `DatasetPage` struct.
5.  **Completion**:
    *   Worker signals success/failure back to the main thread.
    *   `AppContext` emits `sqlFinished` with a `QVariantMap` representation of the result.
6.  **UI Update**: `SqlConsole.qml` receives the signal and passes the data to `DataGridEngine` for rendering.

### 2. View Persistence Flow

1.  **User Action**: User modifies column aliases in `ViewEditor.qml` and clicks "Save".
2.  **QML Layer**: Collects state and calls `App.saveView(viewData)`.
3.  **AppContext**: Calls `LocalStoreService::saveView()`.
4.  **LocalStore**: Writes JSON configuration to the SQLite `views` table.
5.  **Confirmation**: Returns success ID to QML.

## Key Design Principles

*   **UI/Core Separation**: The Core never calls QML directly. It emits signals. QML calls Core methods via the `Q_INVOKABLE` macro.
*   **Asynchronous by Default**: All heavy DB operations run on a worker thread to keep the UI responsive.
*   **Driver Agnostic**: The UI and Core Logic operate on UDM structures (`DatasetPage`, `TableSchema`). Only the Add-on knows SQL dialects.
