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
