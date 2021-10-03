module CircuitSwitch
  class Reporter < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform(limit_count:, called_path:, run:)
      circuit_switch =
      if run
        # Wait for RunCountUpdater saves circuit_switch
        sleep(3)
        CircuitSwitch.find_by!(caller: called_path)
      else
        CircuitSwitch.find_or_initialize_by(caller: called_path)
      end
      circuit_switch.due_date ||= config.due_date
      circuit_switch.assign(report_limit_count: limit_count).increment_report_count
      raise CalledNotification.new(circuit_switch.message)
    rescue CalledNotification => notification
      config.reporter.call(notification.to_message(called_path: called_path))
    end
  end
end
