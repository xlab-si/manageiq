class PhysicalServerProvisionWorkflow < MiqProvisionConfiguredSystemWorkflow
  def self.base_model
    PhysicalServerProvisionWorkflow
  end

  def self.automate_dialog_request
    'UI_PHYSICAL_SERVER_PROVISION_INFO'
  end

  def self.request_class
    PhysicalServerProvisionRequest
  end

  def self.default_dialog_file
    'physical_server_provision_dialogs'
  end

  def allowed_configured_systems(_options = {})
    @allowed_configured_systems ||= begin
      physical_servers = PhysicalServer.where(:id => @values[:src_configured_system_ids])
      physical_servers.collect do |configured_system|
        build_ci_hash_struct(configured_system, ["name"])
      end
    end
  end

  def allowed_configuration_profiles(_options = {})
    pxe_image_id = @values.dig(:src_pxe_image_id, 0)
    return [] unless pxe_image_id

    templates = PxeImage.find(pxe_image_id).customization_templates
    templates.each_with_object({}) do |config_profile, hash|
        hash[config_profile.id] = config_profile.name
      end
  end

  def allowed_pxe_images(_options = {})
    PxeImage.all.each_with_object({}) do |img, hash|
      hash[img.id] = img.description
    end
  end

  def get_source_and_targets(_refresh = false)
  end
end
