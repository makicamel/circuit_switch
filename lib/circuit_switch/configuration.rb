module CircuitSwitch
  class Configuration
    extend ActiveSupport::Autoload
    include ActiveSupport::Configurable

    config_accessor(:report_tool) { :bugsnag }
    config_accessor(:report_paths) { Rails.root }
  end
end
