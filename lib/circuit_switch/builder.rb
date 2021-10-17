require_relative 'core'

module CircuitSwitch
  class Builder < Core
    def assign_runner(key:, if:, close_if:, close_if_reach_limit:, limit_count:)
      @key = key
      @run_if = binding.local_variable_get(:if)
      @close_if = close_if
      @close_if_reach_limit = close_if_reach_limit
      @run_limit_count = limit_count
    end

    def assign_reporter(key:, if:, stop_report_if:, stop_report_if_reach_limit:, limit_count:)
      @key = key
      @report_if = binding.local_variable_get(:if)
      @stop_report_if = stop_report_if
      @stop_report_if_reach_limit = stop_report_if_reach_limit
      @report_limit_count = limit_count
    end

    def run(
      key: nil,
      if: true,
      close_if: false,
      close_if_reach_limit: nil,
      limit_count: nil,
      &block
    )
      assign_runner(
        key: key,
        if: binding.local_variable_get(:if),
        close_if: close_if,
        close_if_reach_limit: close_if_reach_limit,
        limit_count: limit_count,
      )
      execute_run(&block)
    end

    def report(
      key: nil,
      if: true,
      stop_report_if: false,
      stop_report_if_reach_limit: true,
      limit_count: nil
    )
      assign_reporter(
        key: key,
        if: binding.local_variable_get(:if),
        stop_report_if: stop_report_if,
        stop_report_if_reach_limit: stop_report_if_reach_limit,
        limit_count: limit_count,
      )
      execute_report
    end
  end
end
