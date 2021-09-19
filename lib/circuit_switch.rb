require "circuit_switch/version"
require "circuit_switch/notifications"

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
      # TODO: Be able to choice report tool
      Bugsnag.notify(error)
    end
  end
end
