#pragma once
#include <QString>
#include <QDateTime>
#include <vector>

namespace Sofa::Core {

struct ConnectionData {
    int id = -1;
    QString name;
    QString host;
    int port = 5432;
    QString database;
    QString user;
    QString secretRef;
    QDateTime createdAt;
    QDateTime updatedAt;
};

struct QueryHistoryItem {
    int id = -1;
    int connectionId = -1;
    QString query;
    QDateTime createdAt;
};

class ILocalStoreService {
public:
    virtual ~ILocalStoreService() = default;
    
    virtual void init() = 0;
    virtual std::vector<ConnectionData> getAllConnections() = 0;
    virtual int saveConnection(const ConnectionData& data) = 0;
    virtual void deleteConnection(int id) = 0;
    
    virtual void saveQueryHistory(const QueryHistoryItem& item) = 0;
    virtual std::vector<QueryHistoryItem> getQueryHistory(int connectionId) = 0;
};

}
