module CircuitSwitch
  class Configuration
    attr_accessor :reporter
    attr_writer :report_paths, :with_backtrace

    def report_paths
      @report_paths ||= [Rails.root]
    end

    def with_backtrace
      @with_backtrace ||= false
    end
  end
end
