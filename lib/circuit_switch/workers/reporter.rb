require 'circuit_switch/notification'

module CircuitSwitch
  class Reporter < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform
      caller_path = caller.detect { |path| path.match?(/(#{config.report_paths.join('|')})/) } || "/somewhere/in/library:in #{Date.today}"
      circuit_switch = CircuitSwitch.find_or_initialize_by(caller: caller_path)
      if circuit_switch.watching?
        circuit_switch.increment
        notification = raise CalledNotification.new(circuit_switch.message) rescue $!
        config.reporter.call(notification.to_message)
      end
    end
  end
end
