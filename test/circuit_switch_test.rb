require 'test_helper'

class CircuitSwitchTest < Test::Unit::TestCase
  def test_run_returns_builder_instance
    assert_instance_of(
      CircuitSwitch::Builder,
      CircuitSwitch.run {}
    )
  end

  def test_run_assigns_value_when_receives_value
    if_value = [true, false].sample
    close_if_value = [true, false].sample
    close_if_reach_limit_value = [true, false].sample
    initially_closed_value = [true, false].sample
    builder = CircuitSwitch.run(if: if_value, close_if: close_if_value, close_if_reach_limit: close_if_reach_limit_value, initially_closed: initially_closed_value) {}

    assert_equal(
      if_value,
      builder.instance_variable_get(:@run_if)
    )
    assert_equal(
      close_if_value,
      builder.instance_variable_get(:@close_if)
    )
    assert_equal(
      close_if_reach_limit_value,
      builder.instance_variable_get(:@close_if_reach_limit)
    )
    assert_equal(
      initially_closed_value,
      builder.instance_variable_get(:@initially_closed)
    )
  end

  def test_run_assigns_default_value_when_doesnt_receive_value
    builder = CircuitSwitch.run {}

    assert_equal(
      true,
      builder.instance_variable_get(:@run_if)
    )
    assert_equal(
      false,
      builder.instance_variable_get(:@close_if)
    )
    assert_equal(
      false,
      builder.instance_variable_get(:@close_if_reach_limit)
    )
    assert_equal(
      false,
      builder.instance_variable_get(:@initially_closed)
    )
  end

  def test_report_returns_builder_instance
    assert_instance_of(
      CircuitSwitch::Builder,
      CircuitSwitch.report
    )
  end

  def test_report_raises_error_if_block_given
    assert_raise ArgumentError do
      CircuitSwitch.report {}
    end
  end

  def test_report_assigns_value_when_receives_value
    if_value = [true, false].sample
    stop_report_if_value = [true, false].sample
    stop_report_if_reach_limit_value = [true, false].sample
    builder = CircuitSwitch.report(if: if_value, stop_report_if: stop_report_if_value, stop_report_if_reach_limit: stop_report_if_reach_limit_value)

    assert_equal(
      if_value,
      builder.instance_variable_get(:@report_if)
    )
    assert_equal(
      stop_report_if_value,
      builder.instance_variable_get(:@stop_report_if)
    )
    assert_equal(
      stop_report_if_reach_limit_value,
      builder.instance_variable_get(:@stop_report_if_reach_limit)
    )
  end

  def test_report_assigns_default_value_when_doesnt_receive_value
    builder = CircuitSwitch.report

    assert_equal(
      true,
      builder.instance_variable_get(:@report_if)
    )
    assert_equal(
      false,
      builder.instance_variable_get(:@stop_report_if)
    )
    assert_equal(
      true,
      builder.instance_variable_get(:@stop_report_if_reach_limit)
    )
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

  def test_open_returns_same_value_with_run_run_when_receives_value
    if_value = [true, false].sample
    close_if_value = [true, false].sample
    close_if_reach_limit_value = [true, false].sample
    initially_closed_value = [true, false].sample

    assert_equal(
      CircuitSwitch.run(if: if_value, close_if: close_if_value, close_if_reach_limit: close_if_reach_limit_value, initially_closed: initially_closed_value) {}.run?,
      CircuitSwitch.open?(if: if_value, close_if: close_if_value, close_if_reach_limit: close_if_reach_limit_value, initially_closed: initially_closed_value)
    )
  end

  def test_open_returns_same_value_with_run_run_when_doesnt_receive_value
    assert_equal(
      CircuitSwitch.run {}.run?,
      CircuitSwitch.open?
    )
  end
end
