#pragma once

#include <QObject>
#include <memory>
#include "ICommandService.h"
#include "ILogger.h"
#include "ILocalStoreService.h"
#include "ISecretsService.h"
#include "AddonHost.h"
#include <QVariantList>

namespace Sofa::Core {

class AppContext : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList connections READ connections NOTIFY connectionsChanged)
    Q_PROPERTY(QVariantList availableDrivers READ availableDrivers CONSTANT)

public:
    explicit AppContext(std::shared_ptr<ICommandService> commandService,
                       std::shared_ptr<ILogger> logger,
                       std::shared_ptr<ILocalStoreService> localStore,
                       std::shared_ptr<ISecretsService> secrets,
                       std::shared_ptr<AddonHost> addonHost,
                       QObject* parent = nullptr);

    Q_INVOKABLE void executeCommand(const QString& id);
    
    // Connections API
    QVariantList connections() const;
    Q_INVOKABLE bool saveConnection(const QVariantMap& data);
    Q_INVOKABLE bool deleteConnection(int id);
    
    // Drivers/Addons API
    QVariantList availableDrivers() const;
    Q_INVOKABLE bool testConnection(const QVariantMap& data);

signals:
    void connectionsChanged();

private:
    std::shared_ptr<ICommandService> m_commandService;
    std::shared_ptr<ILogger> m_logger;
    std::shared_ptr<ILocalStoreService> m_localStore;
    std::shared_ptr<ISecretsService> m_secrets;
    std::shared_ptr<AddonHost> m_addonHost;
    
    void refreshConnections();
};

}
