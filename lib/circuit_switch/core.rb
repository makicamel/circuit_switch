module CircuitSwitch
  class Core
    def run(
      if: true,
      close_if: false,
      close_if_reach_limit: true,
      limit_count: nil,
      &block
    )
      condition = binding.local_variable_get(:if)
      return self unless condition.respond_to?(:call) ? condition.call : condition
      return self if close_if.respond_to?(:call) ? close_if.call : close_if

      yield
      self
    end

    def report(
      if: true,
      stop_report_if: false,
      stop_report_if_reach_limit: true,
      limit_count: nil
    )
      condition = binding.local_variable_get(:if)
      return self unless condition.respond_to?(:call) ? condition.call : condition
      return self if stop_report_if.respond_to?(:call) ? stop_report_if.call : stop_report_if

      Reporter.perform_later(switch_off_count: limit_count)
      self
    end
  end
end
