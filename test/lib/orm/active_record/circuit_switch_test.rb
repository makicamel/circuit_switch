require 'test_helper'

class CircuitSwitchTest < Test::Unit::TestCase
  def test_assign_sets_attribute_when_has_nil_and_receives_value
    circuit_switch = CircuitSwitch::CircuitSwitch
      .new(run_limit_count: nil)
      .assign(run_limit_count: 1)
    assert_equal(
      1,
      circuit_switch.run_limit_count
    )
  end

  def test_assign_doesnt_set_attribute_when_has_nil_and_doesnt_receive_value
    circuit_switch = CircuitSwitch::CircuitSwitch
      .new(run_limit_count: nil)
      .assign
    assert_equal(
      nil,
      circuit_switch.run_limit_count
    )
  end

  def test_assign_sets_attribute_when_has_value_and_receives_value
    circuit_switch = CircuitSwitch::CircuitSwitch
      .new(run_limit_count: 1)
      .assign(run_limit_count: 2)
    assert_equal(
      2,
      circuit_switch.run_limit_count
    )
  end

  def test_assign_doesnt_set_attribute_when_has_value_and_doesnt_receive_value
    circuit_switch = CircuitSwitch::CircuitSwitch
      .new(run_limit_count: 1)
      .assign
    assert_equal(
      1,
      circuit_switch.run_limit_count
    )
  end
end
