require "circuit_switch/configuration.rb"
require "circuit_switch/orm/active_record/circuit_switch"
require "circuit_switch/version"
require "circuit_switch/workers/reporter"

module CircuitSwitch
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    # @param [Integer] switch_off_count
    def watch_over(switch_off_count: nil)
      yield
      Reporter.perform_later(switch_off_count: switch_off_count)
    end
  end
end
