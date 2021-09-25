require 'circuit_switch/notification'

module CircuitSwitch
  class Reporter < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform(limit_count:)
      circuit_switch = CircuitSwitch.find_or_initialize_by(
        caller: called_path
      )
      if config.enable_report?
        circuit_switch.increment
        raise CalledNotification.new(circuit_switch.message)
      end
    rescue CalledNotification => notification
      config.reporter.call(notification.to_message(called_path: called_path))
    end

    private

    def called_path
      @called_path ||= caller
        .detect { |path| path.match?(/(#{config.report_paths.join('|')})/) }
        &.sub(/(#{config.strip_paths.join('|')})/, '') ||
        "/somewhere/in/library:in #{Date.today}"
    end
  end
end
