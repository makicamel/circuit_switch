module CircuitSwitch
  class Configuration
    attr_accessor :reporter
    attr_writer :report_paths

    def report_paths
      @report_paths ||= [Rails.root]
    end
  end
end
