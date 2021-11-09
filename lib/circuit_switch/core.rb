require_relative 'notification'
require_relative 'workers/reporter'
require_relative 'workers/run_count_updater'

module CircuitSwitch
  class Core
    delegate :config, to: ::CircuitSwitch
    attr_reader :key, :run_if, :close_if, :close_if_reach_limit, :run_limit_count, :initially_closed,
      :report_if, :stop_report_if, :stop_report_if_reach_limit, :report_limit_count

    def execute_run(&block)
      run_executable = false
      if close_if_reach_limit && run_limit_count == 0
        raise CircuitSwitchError.new('Can\'t set limit_count to 0 when close_if_reach_limit is true')
      end
      if close_if_reach_limit.nil?
        Logger.new($stdout).info('Default value for close_if_reach_limit is modified from true to false at ver 0.2.0.')
        @close_if_reach_limit = false
      end

      return self if evaluate(close_if) || !evaluate(run_if)
      return self if close_if_reach_limit && switch.reached_run_limit?(run_limit_count)
      return self if switch.run_is_terminated?

      run_executable = true
      unless switch.new_record? && initially_closed
        yield
        @run = true
      end
      self
    ensure
      if run_executable
        RunCountUpdater.perform_later(
          key: key,
          limit_count: run_limit_count,
          called_path: called_path,
          reported: reported?,
          initially_closed: initially_closed
        )
      end
    end

    def execute_report
      if config.reporter.nil?
        raise CircuitSwitchError.new('Set config.reporter.')
      end
      if config.reporter.arity == 1
        Logger.new($stdout).info('config.reporter now receives 2 arguments. Improve your `config/initialzers/circuit_switch.rb`.')
      end
      if stop_report_if_reach_limit && report_limit_count == 0
        raise CircuitSwitchError.new('Can\'t set limit_count to 0 when stop_report_if_reach_limit is true')
      end
      return self unless config.enable_report?
      return self if evaluate(stop_report_if) || !evaluate(report_if)
      return self if switch.report_is_terminated?
      return self if stop_report_if_reach_limit && switch.reached_report_limit?(report_limit_count)

      Reporter.perform_later(
        key: key,
        limit_count: report_limit_count,
        called_path: called_path,
        stacktrace: StacktraceModifier.call(backtrace: caller),
        run: run?
      )
      @reported = true
      self
    end

    # @return [Boolean]
    def run?
      @run
    end

    # @return [Boolean]
    def reported?
      @reported
    end

    private

    def switch
      return @switch if defined? @switch

      if key
        @switch = CircuitSwitch.find_or_initialize_by(key: key)
      else
        @switch = CircuitSwitch.find_or_initialize_by(caller: called_path)
      end
    end

    def called_path
      @called_path ||= caller
        .reject { |path| /(#{config.silent_paths.join('|')})/.match?(path) }
        .detect { |path| /(#{config.report_paths.join('|')})/.match?(path) }
        &.sub(/(#{config.strip_paths.join('|')})/, '')
        &.gsub(/[`']/, '') ||
        "/somewhere/in/library:in #{Date.today}"
    end

    def evaluate(boolean_or_proc)
      boolean_or_proc.respond_to?(:call) ? boolean_or_proc.call : boolean_or_proc
    end
  end
end
