require 'test_helper'

class BuilderTest < Test::Unit::TestCase
  include ::CircuitSwitch::TestHelper

  def test_run_assigns_value_when_receives_value
    builder = CircuitSwitch::Builder.new
    if_value = [true, false].sample
    close_if_value = [true, false].sample
    close_if_reach_limit_value = [true, false].sample
    initially_closed_value = [true, false].sample
    builder.run(if: if_value, close_if: close_if_value, close_if_reach_limit: close_if_reach_limit_value, initially_closed: initially_closed_value) {}

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
    builder = CircuitSwitch::Builder.new
    builder.run {}

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

  def test_report_assigns_value_when_receives_value
    builder = CircuitSwitch::Builder.new
    if_value = [true, false].sample
    stop_report_if_value = [true, false].sample
    stop_report_if_reach_limit_value = [true, false].sample
    builder.report(if: if_value, stop_report_if: stop_report_if_value, stop_report_if_reach_limit: stop_report_if_reach_limit_value)

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
    builder = CircuitSwitch::Builder.new
    builder.report

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
end
