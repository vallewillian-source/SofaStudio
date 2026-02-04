#pragma once
#include "addons/IAddon.h"
#include <QString>
#include <vector>

namespace Sofa::Addons::Postgres {

using namespace Sofa::Core;

class PostgresQueryProvider : public IQueryProvider {
public:
    DatasetPage execute(const QString& query, const DatasetRequest& request) override;
};

class PostgresCatalogProvider : public ICatalogProvider {
public:
    std::vector<QString> listSchemas() override;
    std::vector<QString> listTables(const QString& schema) override;
    TableSchema getTableSchema(const QString& schema, const QString& table) override;
};

class PostgresConnection : public IConnectionProvider {
public:
    bool testConnection(const QString& host, int port, const QString& db, const QString& user, const QString& password) override;
    bool open(const QString& host, int port, const QString& db, const QString& user, const QString& password) override;
    void close() override;
    bool isOpen() const override;
    QString lastError() const override;

    std::shared_ptr<ICatalogProvider> catalog() override;
    std::shared_ptr<IQueryProvider> query() override;

private:
    bool m_isOpen = false;
    std::shared_ptr<PostgresCatalogProvider> m_catalog;
    std::shared_ptr<PostgresQueryProvider> m_query;
};

class PostgresAddon : public IAddon {
public:
    QString id() const override { return "postgres"; }
    QString name() const override { return "PostgreSQL (Mock)"; }
    std::shared_ptr<IConnectionProvider> createConnection() override;
};

}
