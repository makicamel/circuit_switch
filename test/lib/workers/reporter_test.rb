require 'test_helper'

class ReporterTest < Test::Unit::TestCase
  include ::CircuitSwitch::TestHelper

  setup do
    CircuitSwitch::CircuitSwitch.truncate
  end

  def test_reporter_calls_config_reporter
    message = CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, run: false)
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
    CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      true,
      CircuitSwitch::CircuitSwitch.exists?(report_count: 1, key: called_path)
    )
  end

  def test_reporter_creates_circuit_switch_with_key_when_no_switch
    assert_equal(
      0,
      CircuitSwitch::CircuitSwitch.all.size
    )
    CircuitSwitch::Reporter.new.perform(key: 'test', limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      true,
      CircuitSwitch::CircuitSwitch.exists?(report_count: 1, key: 'test')
    )
  end

  def test_reporter_updates_circuit_switch_report_count_when_switch_exists
    CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      1,
      CircuitSwitch::CircuitSwitch.find_by(key: called_path, caller: called_path).report_count
    )
    CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      2,
      CircuitSwitch::CircuitSwitch.find_by(key: called_path, caller: called_path).report_count
    )
  end

  def test_reporter_updates_circuit_switch_report_count_with_key_when_switch_exists
    CircuitSwitch::Reporter.new.perform(key: 'test', limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      1,
      CircuitSwitch::CircuitSwitch.find_by(key: 'test').report_count
    )
    CircuitSwitch::Reporter.new.perform(key: 'test', limit_count: 10, called_path: called_path, run: false)
    assert_equal(
      2,
      CircuitSwitch::CircuitSwitch.find_by(key: 'test', caller: called_path).report_count
    )
  end

  def test_reporter_raises_active_record_record_not_found_when_reported_and_no_switch_exists
    assert_raise ActiveRecord::RecordNotFound do
      CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, run: true)
    end
  end
end
