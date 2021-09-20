require "circuit_switch/orm/active_record/circuit_switch"
require "circuit_switch/version"
require "circuit_switch/workers/reporter"

module CircuitSwitch
  class << self
    def watch_over
      yield
      raise CalledNotification.new
    rescue CalledNotification
      Reporter.perform_later
    end
  end
end
