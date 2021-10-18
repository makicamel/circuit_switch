require 'test_helper'

class RunCountUpdaterTest < Test::Unit::TestCase
  include ::CircuitSwitch::TestHelper

  setup do
    CircuitSwitch::CircuitSwitch.truncate
  end

  def test_updater_creates_circuit_switch_when_no_switch
    assert_equal(
      0,
      CircuitSwitch::CircuitSwitch.all.size
    )
    CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, key: nil, called_path: called_path, reported: false, initially_closed: false)
    assert_equal(
      true,
      CircuitSwitch::CircuitSwitch.exists?(run_count: 1, key: called_path)
    )
  end

  def test_updater_creates_circuit_switch_with_key_when_no_switch
    assert_equal(
      0,
      CircuitSwitch::CircuitSwitch.all.size
    )
    CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, key: 'test', called_path: called_path, reported: false, initially_closed: false)
    assert_equal(
      true,
      CircuitSwitch::CircuitSwitch.exists?(run_count: 1, key: 'test')
    )
  end

  def test_updater_updates_circuit_switch_run_count_when_switch_exists
    CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, key: nil, called_path: called_path, reported: false, initially_closed: false)
    assert_equal(
      1,
      CircuitSwitch::CircuitSwitch.find_by(key: called_path, caller: called_path).run_count
    )
    CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, key: nil, called_path: called_path, reported: false, initially_closed: false)
    assert_equal(
      2,
      CircuitSwitch::CircuitSwitch.find_by(key: called_path, caller: called_path).run_count
    )
  end

  def test_updater_updates_circuit_switch_run_count_with_key_when_switch_exists
    CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, key: 'test', called_path: called_path, reported: false, initially_closed: false)
    assert_equal(
      1,
      CircuitSwitch::CircuitSwitch.find_by(key: 'test').run_count
    )
    CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, key: nil, called_path: called_path, reported: false, initially_closed: false)
    assert_equal(
      2,
      CircuitSwitch::CircuitSwitch.find_by(key: 'test', caller: called_path).run_count
    )
  end

  def test_updater_raises_active_record_record_not_found_when_reported_and_no_switch_exists
    assert_raise ActiveRecord::RecordNotFound do
      CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, key: nil, called_path: called_path, reported: true, initially_closed: false)
    end
  end
end
