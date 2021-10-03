$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'active_job'
require 'active_record'

require 'bundler/setup'
Bundler.require

require 'support/setup_database'

require 'byebug'
require 'test/unit'
require 'test/unit/rr'
require 'circuit_switch'

CircuitSwitch.configure do |config|
  config.reporter = -> (message) { DummyReporter.report(message) }
  config.report_paths = [Dir.pwd]
  config.report_if = true
  config.due_date_notifier = -> (message) { DummyReporter.report(message) }
end

class DummyReporter
  def self.report(message)
    message
  end
end

class CircuitSwitch::CircuitSwitch < ActiveRecord::Base
  def self.truncate
    connection.execute 'DELETE FROM circuit_switches'
  end
end

module CircuitSwitch::TestHelper
  def called_path
    "/somewhere/in/library:in #{Date.today}"
  end

  def due_date
    Date.today + 10
  end
end
