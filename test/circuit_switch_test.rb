require 'test_helper'

class CircuitSwitchTest < Test::Unit::TestCase
  def test_run_returns_core_instance
    assert_instance_of(
      CircuitSwitch::Core,
      CircuitSwitch.run {}
    )
  end

  def test_report_returns_core_instance
    assert_instance_of(
      CircuitSwitch::Core,
      CircuitSwitch.report
    )
  end

  def test_report_raises_error_if_block_given
    assert_raise ArgumentError do
      CircuitSwitch.report {}
    end
  end

  def test_open_returns_boolean
    assert_equal(
      true,
      CircuitSwitch.open?
    )
  end

  def test_open_raises_error_if_block_given
    assert_raise ArgumentError do
      CircuitSwitch.open? {}
    end
  end
end
