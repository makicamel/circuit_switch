require 'test_helper'

class ReporterTest < Test::Unit::TestCase
  include ::CircuitSwitch::TestHelper

  setup do
    CircuitSwitch::CircuitSwitch.truncate
  end

  def test_reporter_calls_config_reporter
    message = CircuitSwitch::Reporter.new.perform(limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      CircuitSwitch::CircuitSwitch.last.message,
      message
    )
  end

  def test_reporter_creates_circuit_switch_when_no_switch
    assert_equal(
      0,
      CircuitSwitch::CircuitSwitch.all.size
    )
    CircuitSwitch::Reporter.new.perform(limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      true,
      CircuitSwitch::CircuitSwitch.exists?(report_count: 1)
    )
  end

  def test_reporter_updates_circuit_switch_report_count_when_switch_exists
    CircuitSwitch::Reporter.new.perform(limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      1,
      CircuitSwitch::CircuitSwitch.find_by(caller: called_path).report_count
    )
    CircuitSwitch::Reporter.new.perform(limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      2,
      CircuitSwitch::CircuitSwitch.find_by(caller: called_path).report_count
    )
  end
end
