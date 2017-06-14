class ManageIQ::Providers::Kubernetes::MonitoringManager::EventCatcher < ManageIQ::Providers::BaseManager::EventCatcher
  require_nested :Runner

  def self.ems_class
    ManageIQ::Providers::Kubernetes::MonitoringManager
  end
end
