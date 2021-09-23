require 'circuit_switch/notification'

module CircuitSwitch
  class Reporter < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform(switch_off_count:)
      circuit_switch = CircuitSwitch.find_or_initialize_by(
        caller: called_path,
        switch_off_count: switch_off_count
      )
      if circuit_switch.watching? && config.enable_report?
        circuit_switch.increment
        notification = raise CalledNotification.new(circuit_switch.message) rescue $!
        config.reporter.call(notification.to_message(called_path: called_path))
      end
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
