require "circuit_switch/configuration.rb"
require "circuit_switch/core"
require "circuit_switch/notification"
require "circuit_switch/orm/active_record/circuit_switch"
require "circuit_switch/railtie" if defined?(Rails::Railtie)
require "circuit_switch/version"
require "circuit_switch/workers/due_date_notifier"
require "circuit_switch/workers/reporter"
require "circuit_switch/workers/run_count_updater"

module CircuitSwitch
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    # @param [Boolean, Proc] if
    # @param [Boolean, Proc] close_if
    # @param [Boolean] close_if_reach_limit
    # @param [Integer] limit_count
    # @param [Proc] block
    def run(
      if: true,
      close_if: false,
      close_if_reach_limit: true,
      limit_count: nil,
      &block
    )
      Core.new.run(
        if: binding.local_variable_get(:if),
        close_if: close_if,
        close_if_reach_limit: close_if_reach_limit,
        limit_count: limit_count,
        &block
      )
    end

    # @param [Boolean, Proc] if
    # @param [Boolean, Proc] stop_report_if
    # @param [Boolean] stop_report_if_reach_limit
    # @param [Integer] limit_count
    def report(
      if: true,
      stop_report_if: false,
      stop_report_if_reach_limit: true,
      limit_count: nil
    )
      if block_given?
        raise ArgumentError.new('CircuitSwitch.report doesn\'t receive block. Use CircuitSwitch.run if you want to pass block.')
      end

      Core.new.report(
        if: binding.local_variable_get(:if),
        stop_report_if: stop_report_if,
        stop_report_if_reach_limit: stop_report_if_reach_limit,
        limit_count: limit_count
      )
    end

    # Syntax sugar for `CircuitSwitch.run`
    # @param [Boolean, Proc] if
    # @param [Integer] limit_count
    def open?(if: true, limit_count: nil)
      if block_given?
        raise ArgumentError.new('CircuitSwitch.open doesn\'t receive block. Use CircuitSwitch.run if you want to pass block.')
      end

      Core.new.run(
        if: binding.local_variable_get(:if),
        limit_count: limit_count
      ) {}.run?
    end
  end
end
