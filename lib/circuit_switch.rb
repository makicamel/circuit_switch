require "circuit_switch/configuration.rb"
require "circuit_switch/core"
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

    def run(switch_off_count: nil, if: true, &block)
      Core.new.run(
        switch_off_count: switch_off_count,
        if: binding.local_variable_get(:if),
        &block
      )
    end

    def report(switch_off_count: nil, if: true)
      Core.new.report(
        switch_off_count: switch_off_count,
        if: binding.local_variable_get(:if)
      )
    end
  end
end
