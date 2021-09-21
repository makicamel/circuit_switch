module CircuitSwitch
  class Configuration
    attr_writer :report_tool, :report_paths

    def report_tool
      @report_tool ||= :bugsnag
    end

    def report_paths
      @report_paths ||= [Rails.root]
    end
  end
end
