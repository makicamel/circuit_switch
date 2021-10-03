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
    CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, called_path: called_path, reported: false)
    assert_equal(
      true,
      CircuitSwitch::CircuitSwitch.exists?(run_count: 1)
    )
  end

  def test_updater_updates_circuit_switch_run_count_when_switch_exists
    CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, called_path: called_path, reported: false)
    assert_equal(
      1,
      CircuitSwitch::CircuitSwitch.find_by(caller: called_path).run_count
    )
    CircuitSwitch::RunCountUpdater.new.perform(limit_count: 10, called_path: called_path, reported: false)
    assert_equal(
      2,
      CircuitSwitch::CircuitSwitch.find_by(caller: called_path).run_count
    )
  end
end
