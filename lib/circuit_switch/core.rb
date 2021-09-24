module CircuitSwitch
  class Core
    def run(
      if: true,
      close_if: false,
      close_if_reach_limit: true,
      limit_count: nil,
      &block
    )
      return self if evaluate(close_if) || !evaluate(binding.local_variable_get(:if))

      yield
      self
    end

    def report(
      if: true,
      stop_report_if: false,
      stop_report_if_reach_limit: true,
      limit_count: nil
    )
      return self if evaluate(stop_report_if) || !evaluate(binding.local_variable_get(:if))

      Reporter.perform_later(switch_off_count: limit_count)
      self
    end

    private

    def evaluate(boolean_or_proc)
      boolean_or_proc.respond_to?(:call) ? boolean_or_proc.call : boolean_or_proc
    end
  end
end
