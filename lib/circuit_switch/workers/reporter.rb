require 'circuit_switch/notification'

module CircuitSwitch
  class Reporter < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform(limit_count:, called_path:)
      circuit_switch = CircuitSwitch.find_or_initialize_by(caller: called_path)
      if config.enable_report?
        circuit_switch.assign(report_limit_count: limit_count).increment_report_count
        raise CalledNotification.new(circuit_switch.message)
      end
    rescue CalledNotification => notification
      config.reporter.call(notification.to_message(called_path: called_path))
    end
  end
end
