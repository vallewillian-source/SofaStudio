#pragma once
#include <memory>
#include <map>
#include <QString>
#include "addons/IAddon.h"
#include "ILogger.h"

namespace Sofa::Core {

class AddonHost {
public:
    explicit AddonHost(std::shared_ptr<ILogger> logger);
    
    // Register an addon instance (in-tree registration for now)
    void registerAddon(const QString& id, std::shared_ptr<IAddon> addon);
    
    // Get an addon by ID
    std::shared_ptr<IAddon> getAddon(const QString& id);
    
    // Check if addon exists
    bool hasAddon(const QString& id) const;

private:
    std::shared_ptr<ILogger> m_logger;
    std::map<QString, std::shared_ptr<IAddon>> m_addons;
};

}
