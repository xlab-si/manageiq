class PhysicalServerBiosUpdateRequest < MiqRequest
  TASK_DESCRIPTION  = 'Physical Server BIOS Update'.freeze
  SOURCE_CLASS_NAME = 'PhysicalServer'.freeze

  def description
    'Physical Server BIOS Update'
  end

  def my_role(_action = nil)
    'ems_operations'
  end

  def self.request_task_class
    PhysicalServerBiosUpdateTask
  end

  def self.new_request_task(attribs)
    ManageIQ::Providers::Redfish::PhysicalInfraManager::BiosUpdate.new(attribs)
  end

  def self.source_physical_server(source_id)
    PhysicalServer.find_by(:id => source_id).tap do |source|
      raise MiqException::MiqProvisionError, "Unable to find source PhysicalServer with id [#{source_id}]" if source.nil?

      if source.ext_management_system.nil?
        raise MiqException::MiqProvisionError,
              "Source PhysicalServer with id [#{source_id}] has no EMS, unable to update BIOS"
      end
    end
  end
end
