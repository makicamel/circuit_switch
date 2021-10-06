module CircuitSwitch
  class Configuration
    CIRCUIT_SWITCH = 'circuit_switch'.freeze

    attr_accessor :reporter, :due_date_notifier
    attr_writer :report_paths, :report_if, :due_date, :with_backtrace, :allowed_backtrace_paths, :strip_paths

    def report_paths
      @report_paths ||= [Rails.root]
    end

    def silent_paths=(paths)
      @silent_paths = paths.append(CIRCUIT_SWITCH).uniq
    end

    def silent_paths
      @silent_paths ||= [CIRCUIT_SWITCH]
    end

    def report_if
      @report_if ||= Rails.env.production?
    end

    def enable_report?
      report_if.respond_to?(:call) ? report_if.call : !!report_if
    end

    def due_date
      @due_date ||= Date.today + 10
    end

    def with_backtrace
      @with_backtrace ||= false
    end

    def allowed_backtrace_paths
      @allowed_backtrace_paths ||= [Dir.pwd]
    end

    def strip_paths
      @strip_paths ||= [Dir.pwd]
    end
  end
end
