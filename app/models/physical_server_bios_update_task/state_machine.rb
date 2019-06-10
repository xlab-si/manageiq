module PhysicalServerBiosUpdateTask::StateMachine
  def run_bios_update
    raise MiqException::MiqProvisionError, "Unable to find #{model_class} with id #{source_id.inspect}" if source.blank?

    dump_obj(options, "MIQ(#{self.class.name}##{__method__}) options: ", $log, :info)
    signal :start_bios_update
  end

  def start_bios_update
    # Implement BIOS update in subclass, user-defined values are stored in options field.
    raise NotImplementedError, 'Must be implemented in subclass and signal :done_bios_update when done'
  end

  def done_bios_update
    update_and_notify_parent(:message => msg('done bios update'))
    signal :mark_as_completed
  end

  def mark_as_completed
    update_and_notify_parent(:state => 'bios_updated', :message => msg('bios update completed'))
    MiqEvent.raise_evm_event(source, 'generic_task_finish', :message => "Done updating BIOS on PhysicalServer")
    signal :finish
  end

  def finish
    if status != 'Error'
      _log.info("Executing bios update task: [#{description}]... Complete")
    else
      _log.info("Executing bios update task: [#{description}]... Errored")
    end
  end

  def msg(txt)
    "Updating BIOS for PhysicalServer id=#{source.id}, name=#{source.name}, ems_ref=#{source.ems_ref}: #{txt}"
  end
end
