#include "AddonHost.h"

namespace Sofa::Core {

AddonHost::AddonHost(std::shared_ptr<ILogger> logger)
    : m_logger(logger)
{
}

void AddonHost::registerAddon(const QString& id, std::shared_ptr<IAddon> addon)
{
    if (m_addons.find(id) != m_addons.end()) {
        m_logger->warning("Addon already registered: " + id);
        return;
    }
    m_addons[id] = addon;
    m_logger->info("Registered addon: " + id + " (" + addon->name() + ")");
}

std::shared_ptr<IAddon> AddonHost::getAddon(const QString& id)
{
    auto it = m_addons.find(id);
    if (it != m_addons.end()) {
        return it->second;
    }
    return nullptr;
}

bool AddonHost::hasAddon(const QString& id) const
{
    return m_addons.find(id) != m_addons.end();
}

}
