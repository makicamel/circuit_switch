require "circuit_switch/version"
require "circuit_switch/notifications"
require "circuit_switch/orm/active_record/circuit_switch"

module CircuitSwitch
  class << self
    def watch_over
      yield
      raise CalledNotification.new
    rescue CalledNotification => e
      report e
    end

    private

    def report(error)
      caller_path = caller.detect { |path| path.match?(/(#{Rails.root})/) }
      # N+1 problem may be caused
      circuit_switch = CircuitSwitch.find_or_initialize_by(caller: caller_path)
      if circuit_switch.watching?
        circuit_switch.increment
        # TODO: Be able to choice report tool
        Bugsnag.notify(error)
      end
    end
  end
end
