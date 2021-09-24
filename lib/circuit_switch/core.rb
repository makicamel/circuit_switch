module CircuitSwitch
  class Core
    def run(switch_off_count:, if:)
      condition = binding.local_variable_get(:if)
      return unless condition.respond_to?(:call) ? condition.call : condition

      yield
    end

    def report(switch_off_count:, if:)
      condition = binding.local_variable_get(:if)
      return self unless condition.respond_to?(:call) ? condition.call : condition

      Reporter.perform_later(switch_off_count: switch_off_count)
      self
    end
  end
end
