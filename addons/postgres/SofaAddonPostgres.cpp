#include "SofaAddonPostgres.h"
#include <QThread>

namespace Sofa::Addons::Postgres {

// --- Addon ---
std::shared_ptr<IConnectionProvider> PostgresAddon::createConnection() {
    return std::make_shared<PostgresConnection>();
}

// --- Connection ---
bool PostgresConnection::testConnection(const QString& host, int port, const QString& db, const QString& user, const QString& password) {
    // Mock: always success
    return true;
}

bool PostgresConnection::open(const QString& host, int port, const QString& db, const QString& user, const QString& password) {
    m_isOpen = true;
    m_catalog = std::make_shared<PostgresCatalogProvider>();
    m_query = std::make_shared<PostgresQueryProvider>();
    return true;
}

void PostgresConnection::close() {
    m_isOpen = false;
    m_catalog.reset();
    m_query.reset();
}

bool PostgresConnection::isOpen() const {
    return m_isOpen;
}

QString PostgresConnection::lastError() const {
    return "";
}

std::shared_ptr<ICatalogProvider> PostgresConnection::catalog() {
    return m_catalog;
}

std::shared_ptr<IQueryProvider> PostgresConnection::query() {
    return m_query;
}

// --- Catalog ---
std::vector<QString> PostgresCatalogProvider::listSchemas() {
    return {"public", "information_schema", "pg_catalog"};
}

std::vector<QString> PostgresCatalogProvider::listTables(const QString& schema) {
    if (schema == "public") {
        return {"users", "posts", "comments"};
    }
    return {};
}

TableSchema PostgresCatalogProvider::getTableSchema(const QString& schema, const QString& table) {
    TableSchema ts;
    ts.schema = schema;
    ts.name = table;
    
    if (table == "users") {
        ts.columns.push_back({"id", DataType::Integer, "int4", true, false});
        ts.columns.push_back({"name", DataType::Text, "text", false, true});
        ts.columns.push_back({"email", DataType::Text, "varchar", false, true});
        ts.columns.push_back({"created_at", DataType::DateTime, "timestamp", false, true});
    }
    return ts;
}

// --- Query ---
DatasetPage PostgresQueryProvider::execute(const QString& query, const DatasetRequest& request) {
    DatasetPage page;
    
    // Mock columns
    page.columns.push_back({"id", DataType::Integer, "int4"});
    page.columns.push_back({"name", DataType::Text, "text"});
    page.columns.push_back({"email", DataType::Text, "varchar"});
    
    // Mock rows (10 rows)
    for (int i = 0; i < 10; i++) {
        std::vector<QVariant> row;
        row.push_back(i + 1);
        row.push_back(QString("User %1").arg(i + 1));
        row.push_back(QString("user%1@example.com").arg(i + 1));
        page.rows.push_back(row);
    }
    
    page.hasMore = false;
    page.executionTimeMs = 15;
    
    return page;
}

}
