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
      return self if evaluate(close_if) || !evaluate(binding.local_variable_get(:if))
      return self if close_if_reach_limit && switch.reached_run_limit?

      yield
      switch.assign(run_limit_count: limit_count).increment_run_count
      self
    end

    def report(
      if: true,
      stop_report_if: false,
      stop_report_if_reach_limit: true,
      limit_count: nil
    )
      return self unless config.enable_report?
      return self if evaluate(stop_report_if) || !evaluate(binding.local_variable_get(:if))
      return self if stop_report_if_reach_limit && switch.reached_report_limit?

      Reporter.perform_later(
        limit_count: limit_count,
        called_path: called_path
      )
      self
    end

    private

    def switch
      @switch ||= CircuitSwitch.find_or_initialize_by(caller: called_path)
    end

    def called_path
      @called_path ||= caller
        .detect { |path| path.match?(/(#{config.report_paths.join('|')})/) }
        &.sub(/(#{config.strip_paths.join('|')})/, '') ||
        "/somewhere/in/library:in #{Date.today}"
    end

    def evaluate(boolean_or_proc)
      boolean_or_proc.respond_to?(:call) ? boolean_or_proc.call : boolean_or_proc
    end
  end
end
