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
    # @param [Boolean or Proc] if
    def run(switch_off_count: nil, if: true)
      condition = binding.local_variable_get(:if)
      return unless condition.respond_to?(:call) ? condition.call : condition
      yield
    end

    def report(switch_off_count: nil, if: true)
      condition = binding.local_variable_get(:if)
      return self unless condition.respond_to?(:call) ? condition.call : condition

      Reporter.perform_later(switch_off_count: switch_off_count)
      self
    end
  end
end
