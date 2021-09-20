module CircuitSwitch
  class Configuration
    extend ActiveSupport::Autoload
    include ActiveSupport::Configurable

    config_accessor(:report_tool) { :bugsnag }
  end
end
