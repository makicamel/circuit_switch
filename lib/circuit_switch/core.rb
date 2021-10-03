module CircuitSwitch
  class Core
    delegate :config, to: ::CircuitSwitch

    def run(
      if: true,
      close_if: false,
      close_if_reach_limit: true,
      limit_count: nil,
      &block
    )
      if close_if_reach_limit && limit_count == 0
        raise CircuitSwitchError.new('Can\'t set limit_count to 0 when close_if_reach_limit is true')
      end
      return self if evaluate(close_if) || !evaluate(binding.local_variable_get(:if))
      return self if close_if_reach_limit && switch.reached_run_limit?(limit_count)

      yield
      RunCountUpdater.perform_later(
        limit_count: limit_count,
        called_path: called_path,
        reported: reported?
      )
      @run = true
      self
    end

    def report(
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
      return self unless config.enable_report?
      return self if evaluate(stop_report_if) || !evaluate(binding.local_variable_get(:if))
      return self if stop_report_if_reach_limit && switch.reached_report_limit?(limit_count)

      Reporter.perform_later(
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
      @switch ||= CircuitSwitch.find_or_initialize_by(caller: called_path)
    end

    def called_path
      @called_path ||= caller
        .reject { |path| path.match?(/(#{config.silent_paths.join('|')})/) }
        .detect { |path| path.match?(/(#{config.report_paths.join('|')})/) }
        &.sub(/(#{config.strip_paths.join('|')})/, '')
        &.gsub(/[`']/, '') ||
        "/somewhere/in/library:in #{Date.today}"
    end

    def evaluate(boolean_or_proc)
      boolean_or_proc.respond_to?(:call) ? boolean_or_proc.call : boolean_or_proc
    end
  end
end
