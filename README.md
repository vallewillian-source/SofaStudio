# Sofa Studio 🛋️

> **The "VS Code" of Database Clients.**
> Minimalist. Fast. Extensible.

Sofa Studio is an open-source database client built with **Qt 6 (C++ & QML)**. It aims to provide a developer experience similar to VS Code but for data: a lean core, a consistent UI/UX, and a powerful add-on system.

## 🎯 Vision

The goal is to build a tool that feels **instant** and looks **beautiful** without sacrificing power.

*   **Functional Minimalism**: Only the essential elements, well-designed.
*   **Fast by Default**: Low latency interactions (scroll, filters, opening tables).
*   **"Beauty Mode"**: Transform raw database tables into readable, analyzable views with aliases and formatting.
*   **Extensible Architecture**: A thin core with database drivers implemented as add-ons.

## ✨ Features (MVP)

*   **🔌 PostgreSQL Support**: First-class support via the modular Add-on system.
*   **⚡ Universal DataGrid**: A high-performance, C++ powered grid engine capable of handling large datasets with smooth virtualization.
*   **💅 Beauty Mode**: Create "Views" for your tables with custom column aliases, visibility settings, and formatting—persisted locally.
*   **🚀 SQL Console**: Asynchronous query execution with real cancellation support and history.
*   **🔒 Local-First**: Connections, views, and query history are stored locally. Passwords are securely managed by the OS.

## 🏗️ Architecture

Sofa Studio uses a **Hybrid Architecture**:

1.  **UI Layer (Qt Quick/QML)**: Handles the shell, navigation, and layout. It's completely declarative and uses a modern Design System.
2.  **Core Layer (C++)**: The heavy lifter. Manages the dependency injection container, command system, and application state.
3.  **Data Engine (C++)**: The `DataGridEngine` and `Universal Data Model (UDM)` ensure that data handling is consistent across different database drivers.
4.  **Add-ons**: Database drivers (like Postgres) are isolated modules that implement standard interfaces (`IConnectionProvider`, `IQueryProvider`).

## 📚 Documentation

We believe in documenting code and decisions.

*   **[Documentation Index](docs/00-index.md)** - Start here.
*   **[Architecture Overview](docs/01-architecture-overview.md)** - High-level system design.
*   **[Core Concepts](docs/02-core-concepts.md)** - AppContext, LocalStore, and Async patterns.
*   **[Postgres Add-on](docs/05-postgres-addon.md)** - Implementation details of the Postgres driver.
*   **[DataGrid Engine](docs/07-datagrid-engine.md)** - How the high-performance grid works.

## 🛠️ Build & Run

**Prerequisites**: CMake 3.16+, Qt 6, C++17 Compiler.

```bash
# Configure
cmake -S . -B build

# Build
cmake --build build

# Run
./build/apps/desktop/sofa-studio
```

For detailed instructions and troubleshooting, see the [Getting Started Guide](docs/01-getting-started.md).

## 🗺️ Roadmap

*   **MVP (Current)**: Postgres support, Basic SQL Console, DataGrid, Beauty Mode v1.
*   **Next Steps**:
    *   Improved UI/UX.
    *   Export results (CSV/JSON).
    *   Advanced "Beauty Mode" (saved filters, sorting).
    *   More database drivers (SQLite, MySQL).
    *   Dashboards.

## 📄 License

This project is open source. See [LICENSE](LICENSE) for details.
