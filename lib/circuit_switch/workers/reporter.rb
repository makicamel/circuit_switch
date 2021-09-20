require 'circuit_switch/notifications'

module CircuitSwitch
  class Reporter < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform
      caller_path = caller.detect { |path| path.match?(/(#{Rails.root})/) }
      circuit_switch = CircuitSwitch.find_or_initialize_by(caller: caller_path)
      if circuit_switch.watching?
        circuit_switch.increment
        report(
          CalledNotification.new("Watching process is called for #{circuit_switch.report_count}th. Report until for #{circuit_switch.switch_off_count}th.")
        )
      end
    end

    private

    def report(error)
      case config.report_tool
      when :bugsnag
        Bugsnag.notify(error)
      else
        raise ReportToolNotFound
      end
    end
  end
end
