require "circuit_switch/configuration.rb"
require "circuit_switch/orm/active_record/circuit_switch"
require "circuit_switch/version"
require "circuit_switch/workers/reporter"

module CircuitSwitch
  extend ActiveSupport::Autoload
  autoload :Configuration

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    def watch_over
      yield
      Reporter.perform_later
    end
  end
end
