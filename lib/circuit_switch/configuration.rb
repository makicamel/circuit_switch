module CircuitSwitch
  class Configuration
    attr_accessor :reporter
    attr_writer :report_paths, :with_backtrace, :allowed_backtrace_paths, :strip_paths

    def report_paths
      @report_paths ||= [Rails.root]
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
