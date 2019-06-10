class PhysicalServerBiosUpdateTask < MiqRequestTask
  include_concern 'StateMachine'

  validates :state, :inclusion => {
    :in      => %w[pending queued active bios_updated finished],
    :message => 'should be pending, queued, active, bios_updated or finished'
  }

  AUTOMATE_DRIVES = false

  def description
    'Physical Server BIOS Update'
  end

  def self.base_model
    PhysicalServerBiosUpdateTask
  end

  def do_request
    signal :run_bios_update
  end

  def self.request_class
    PhysicalServerBiosUpdateRequest
  end

  def self.display_name(number = 1)
    n_('Bios Update Task', 'Bios Update Tasks', number)
  end
end
