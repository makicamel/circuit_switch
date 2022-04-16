require 'test_helper'

class ReporterTest < Test::Unit::TestCase
  include ::CircuitSwitch::TestHelper

  setup do
    CircuitSwitch::Store.redis.flushall
  end

  def test_reporter_calls_config_reporter
    message = CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, stacktrace: [], run: false)
    assert_equal(
      message,
      CircuitSwitch::Store.find_by(key: called_path).message
    )
  end

  def test_reporter_creates_circuit_switch_when_no_switch
    assert CircuitSwitch::Store.empty?
    CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, stacktrace: [], run: false)
    assert_equal(
      1,
      CircuitSwitch::Store.find_by(key: called_path).report_count
    )
  end

  def test_reporter_creates_circuit_switch_with_key_when_no_switch
    assert CircuitSwitch::Store.empty?
    CircuitSwitch::Reporter.new.perform(key: 'test', limit_count: 10, called_path: called_path, stacktrace: [], run: false)
    assert_equal(
      1,
      CircuitSwitch::Store.find_by(key: 'test').report_count
    )
  end

  def test_reporter_updates_circuit_switch_report_count_when_switch_exists
    CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, stacktrace: [], run: false)
    assert_equal(
      1,
      CircuitSwitch::Store.find_by(key: called_path, caller: called_path).report_count
    )
    CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, stacktrace: [], run: false)
    assert_equal(
      2,
      CircuitSwitch::Store.find_by(key: called_path, caller: called_path).report_count
    )
  end

  def test_reporter_updates_circuit_switch_report_count_with_key_when_switch_exists
    CircuitSwitch::Reporter.new.perform(key: 'test', limit_count: 10, called_path: called_path, stacktrace: [], run: false)
    assert_equal(
      1,
      CircuitSwitch::Store.find_by(key: 'test').report_count
    )
    CircuitSwitch::Reporter.new.perform(key: 'test', limit_count: 10, called_path: called_path, stacktrace: [], run: false)
    assert_equal(
      2,
      CircuitSwitch::Store.find_by(key: 'test', caller: called_path).report_count
    )
  end

  def test_reporter_raises_active_record_record_not_found_when_reported_and_no_switch_exists
    assert_raise ActiveRecord::RecordNotFound do
      CircuitSwitch::Reporter.new.perform(key: nil, limit_count: 10, called_path: called_path, stacktrace: [], run: true)
    end
  end
end
