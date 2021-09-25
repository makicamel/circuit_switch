module CircuitSwitch
  class CircuitSwitch < ::ActiveRecord::Base
    def reached_run_limit?
      run_count >= run_limit_count
    end

    def reached_report_limit?
      report_count >= report_limit_count
    end

    def increment
      with_writable { update(report_count: report_count + 1) }
    end

    def message
      "Watching process is called for #{report_count}th. Report until for #{report_limit_count}th."
    end

    private

    def with_writable
      if ApplicationRecord.respond_to?(:with_writable)
        ApplicationRecord.with_writable { yield }
      else
        yield
      end
    end
  end
end
