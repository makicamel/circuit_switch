require_relative 'notification'
require_relative 'workers/reporter'
require_relative 'workers/run_count_updater'

module CircuitSwitch
  class Core
    delegate :config, to: ::CircuitSwitch

    def run(
      key: nil,
      if: true,
      close_if: false,
      close_if_reach_limit: nil,
      limit_count: nil,
      &block
    )
      if close_if_reach_limit && limit_count == 0
        raise CircuitSwitchError.new('Can\'t set limit_count to 0 when close_if_reach_limit is true')
      end
      if close_if_reach_limit.nil?
        Logger.new($stdout).info('Default value for close_if_reach_limit is modified from true to false at ver 0.2.0.')
        close_if_reach_limit = false
      end
      @key = key
      return self if evaluate(close_if) || !evaluate(binding.local_variable_get(:if))
      return self if close_if_reach_limit && switch.reached_run_limit?(limit_count)
      return self if switch.run_is_terminated?

      yield
      RunCountUpdater.perform_later(
        key: key,
        limit_count: limit_count,
        called_path: called_path,
        reported: reported?
      )
      @run = true
      self
    end

    def report(
      key: nil,
      if: true,
      stop_report_if: false,
      stop_report_if_reach_limit: true,
      limit_count: nil
    )
      if config.reporter.nil?
        raise CircuitSwitchError.new('Set config.reporter.')
      end
      if stop_report_if_reach_limit && limit_count == 0
        raise CircuitSwitchError.new('Can\'t set limit_count to 0 when stop_report_if_reach_limit is true')
      end
      @key = key
      return self unless config.enable_report?
      return self if evaluate(stop_report_if) || !evaluate(binding.local_variable_get(:if))
      return self if switch.report_is_terminated?
      return self if stop_report_if_reach_limit && switch.reached_report_limit?(limit_count)

      Reporter.perform_later(
        key: key,
        limit_count: limit_count,
        called_path: called_path,
        run: run?
      )
      @reported = true
      self
    end

    # @return [Boolean]
    def run?
      !!@run
    end

    # @return [Boolean]
    def reported?
      !!@reported
    end

    private

    def switch
      return @switch if defined? @switch

      if @key
        @switch = CircuitSwitch.find_or_initialize_by(key: @key)
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
