require_relative 'circuit_switch/configuration'
require_relative 'circuit_switch/core'
require_relative 'circuit_switch/orm/active_record/circuit_switch'
require_relative 'circuit_switch/railtie' if defined?(Rails::Railtie)
require_relative 'circuit_switch/version'
require_relative 'circuit_switch/workers/due_date_notifier'

module CircuitSwitch
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    # @param if [Boolean, Proc] Call proc when `if` is truthy (default: true)
    # @param close_if [Boolean, Proc] Call proc when `close_if` is falsy (default: false)
    # @param close_if_reach_limit [Boolean] Stop calling proc when run count reaches limit (default: true)
    # @param limit_count [Integer] Limit count. Use `run_limit_count` default value if it's nil
    #   Can't be set 0 when `close_if_reach_limit` is true (default: nil)
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

    # @param if [Boolean, Proc] Report when `if` is truthy (default: true)
    # @param stop_report_if [Boolean, Proc] Report when `close_if` is falsy (default: false)
    # @param stop_report_if_reach_limit [Boolean] Stop reporting when reported count reaches limit (default: true)
    # @param limit_count [Integer] Limit count. Use `report_limit_count` default value if it's nil
    #   Can't be set 0 when `stop_report_if_reach_limit` is true (default: nil)
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
    # @param if [Boolean, Proc] `CircuitSwitch.run` is runnable when `if` is truthy (default: true)
    # @param close_if [Boolean, Proc] `CircuitSwitch.run` is runnable when `close_if` is falsy (default: false)
    # @param close_if_reach_limit [Boolean] `CircuitSwitch.run` is NOT runnable when run count reaches limit (default: true)
    # @param limit_count [Integer] Limit count. Use `run_limit_count` default value if it's nil. Can't be set 0 (default: nil)
    # @return [Boolean]
    def open?(
      if: true,
      close_if: false,
      close_if_reach_limit: true,
      limit_count: nil
    )
      if block_given?
        raise ArgumentError.new('CircuitSwitch.open doesn\'t receive block. Use CircuitSwitch.run if you want to pass block.')
      end

      Core.new.run(
        if: binding.local_variable_get(:if),
        close_if: close_if,
        close_if_reach_limit: close_if_reach_limit,
        limit_count: limit_count
      ) {}.run?
    end
  end
end
