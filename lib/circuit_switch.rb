require_relative 'circuit_switch/configuration'
require_relative 'circuit_switch/builder'
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

    # @param key [String] Named key to find switch instead of caller
    # @param if [Boolean, Proc] Call proc when `if` is truthy (default: true)
    # @param close_if [Boolean, Proc] Call proc when `close_if` is falsy (default: false)
    # @param close_if_reach_limit [Boolean] Stop calling proc when run count reaches limit (default: false)
    # @param limit_count [Integer] Limit count. Use `run_limit_count` default value if it's nil
    #   Can't be set 0 when `close_if_reach_limit` is true (default: nil)
    # @param initially_closed [Boolean] Create switch with terminated mode (default: false)
    # @param [Proc] block
    def run(key: nil, if: nil, close_if: nil, close_if_reach_limit: nil, limit_count: nil, initially_closed: nil, &block)
      arguments = {
        key: key,
        if: binding.local_variable_get(:if),
        close_if: close_if,
        close_if_reach_limit: close_if_reach_limit,
        limit_count: limit_count,
        initially_closed: initially_closed,
      }.reject { |_, v| v.nil? }
      Builder.new.run(**arguments, &block)
    end

    # @param key [String] Named key to find switch instead of caller
    # @param if [Boolean, Proc] Report when `if` is truthy (default: true)
    # @param stop_report_if [Boolean, Proc] Report when `close_if` is falsy (default: false)
    # @param stop_report_if_reach_limit [Boolean] Stop reporting when reported count reaches limit (default: true)
    # @param limit_count [Integer] Limit count. Use `report_limit_count` default value if it's nil
    #   Can't be set 0 when `stop_report_if_reach_limit` is true (default: nil)
    def report(key: nil, if: nil, stop_report_if: nil, stop_report_if_reach_limit: nil, limit_count: nil)
      if block_given?
        raise ArgumentError.new('CircuitSwitch.report doesn\'t receive block. Use CircuitSwitch.run if you want to pass block.')
      end

      arguments = {
        key: key,
        if: binding.local_variable_get(:if),
        stop_report_if: stop_report_if,
        stop_report_if_reach_limit: stop_report_if_reach_limit,
        limit_count: limit_count
      }.reject { |_, v| v.nil? }
      Builder.new.report(**arguments)
    end

    # Syntax sugar for `CircuitSwitch.run`
    # @param key [String] Named key to find switch instead of caller
    # @param if [Boolean, Proc] `CircuitSwitch.run` is runnable when `if` is truthy (default: true)
    # @param close_if [Boolean, Proc] `CircuitSwitch.run` is runnable when `close_if` is falsy (default: false)
    # @param close_if_reach_limit [Boolean] `CircuitSwitch.run` is NOT runnable when run count reaches limit (default: true)
    # @param limit_count [Integer] Limit count. Use `run_limit_count` default value if it's nil. Can't be set 0 (default: nil)
    # @param initially_closed [Boolean] Create switch with terminated mode (default: false)
    # @return [Boolean]
    def open?(key: nil, if: nil, close_if: nil, close_if_reach_limit: nil, limit_count: nil, initially_closed: nil)
      if block_given?
        raise ArgumentError.new('CircuitSwitch.open doesn\'t receive block. Use CircuitSwitch.run if you want to pass block.')
      end

      arguments = {
        key: key,
        if: binding.local_variable_get(:if),
        close_if: close_if,
        close_if_reach_limit: close_if_reach_limit,
        limit_count: limit_count,
        initially_closed: initially_closed,
      }.reject { |_, v| v.nil? }
      Builder.new.run(**arguments) {}.run?
    end
  end
end
