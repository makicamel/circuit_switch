require 'test_helper'

class CoreTest < Test::Unit::TestCase
  include ::CircuitSwitch::TestHelper

  setup do
    CircuitSwitch::CircuitSwitch.truncate
  end

  def test_run_calls_block_when_all_conditions_are_clear
    stub(CircuitSwitch::RunCountUpdater).perform_later
    test_value = 0
    CircuitSwitch::Core.new.run { test_value = 1 }
    assert_equal(
      1,
      test_value
    )
  end

  def test_run_calls_updater_when_block_is_called_and_no_switch
    stub(CircuitSwitch::RunCountUpdater).perform_later(limit_count: nil, called_path: called_path, reported: false)
    CircuitSwitch::Core.new.run {}
    assert_received(CircuitSwitch::RunCountUpdater) do |reporter|
      reporter.perform_later(limit_count: nil, called_path: called_path, reported: false)
    end
  end

  def test_run_calls_block_when_close_if_reach_limit_is_false_and_reached_limit
    stub(CircuitSwitch::RunCountUpdater).perform_later(limit_count: nil, called_path: called_path, reported: false)
    limit_count = 1
    CircuitSwitch::CircuitSwitch.new(run_limit_count: limit_count, caller: called_path, due_date: due_date).increment_run_count

    test_value = 0
    CircuitSwitch::Core.new.run(close_if_reach_limit: false) { test_value = 1 }
    assert_equal(
      1,
      test_value
    )
  end

  def test_run_doesnt_call_block_when_close_if_reach_limit_is_true_and_reached_limit
    stub(CircuitSwitch::RunCountUpdater).perform_later(limit_count: nil, called_path: called_path, reported: false)
    limit_count = 1
    CircuitSwitch::CircuitSwitch.new(run_limit_count: limit_count, caller: called_path, due_date: due_date).increment_run_count

    test_value = 0
    CircuitSwitch::Core.new.run(close_if_reach_limit: true) { test_value = 1 }
    assert_equal(
      0,
      test_value
    )
  end

  def test_run_raises_error_when_close_if_reach_limit_is_true_and_reached_limit_is_zero
    assert_raise CircuitSwitch::CircuitSwitchError do
      CircuitSwitch::Core.new.run(close_if_reach_limit: true, limit_count: 0) {}
    end
  end

  def test_run_doesnt_call_block_when_close_if_is_true
    test_value = 0
    CircuitSwitch::Core.new.run(close_if: true) { test_value = 1 }
    assert_equal(
      0,
      test_value
    )
  end

  def test_run_doesnt_call_block_when_if_is_false
    test_value = 0
    CircuitSwitch::Core.new.run(if: false) { test_value = 1 }
    assert_equal(
      0,
      test_value
    )
  end

  def test_report_reports_when_all_conditions_are_clear
    stub(CircuitSwitch::Reporter).perform_later(limit_count: nil, called_path: called_path, run: false)
    CircuitSwitch::Core.new.report
    assert_received(CircuitSwitch::Reporter) do |reporter|
      reporter.perform_later(limit_count: nil, called_path: called_path, run: false)
    end
  end

  def test_report_reports_when_close_if_reach_limit_is_false_and_reached_limit
    limit_count = 1
    CircuitSwitch::CircuitSwitch.new(report_limit_count: limit_count, caller: called_path, due_date: due_date).increment_report_count
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1, called_path: called_path, run: false)

    CircuitSwitch::Core.new.report(limit_count: 1, stop_report_if_reach_limit: false)
    assert_received(CircuitSwitch::Reporter) do |reporter|
      reporter.perform_later(limit_count: 1, called_path: called_path, run: false)
    end
  end

  def test_report_doesnt_report_when_close_if_reach_limit_is_true_and_reached_limit
    limit_count = 1
    CircuitSwitch::CircuitSwitch.new(report_limit_count: limit_count, caller: called_path, due_date: due_date).increment_report_count
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 10, called_path: called_path, run: false)

    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      CircuitSwitch::Core.new.report(limit_count: 1, stop_report_if_reach_limit: true)
    end
  end

  def test_report_raises_error_when_stop_report_if_reach_limit_is_true_and_reached_limit_is_zero
    assert_raise CircuitSwitch::CircuitSwitchError do
      CircuitSwitch::Core.new.report(stop_report_if_reach_limit: true, limit_count: 0)
    end
  end

  def test_report_doesnt_report_when_stop_report_if_is_true
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      CircuitSwitch::Core.new.report(stop_report_if: true)
    end
  end

  def test_report_doesnt_report_when_if_is_false
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      CircuitSwitch::Core.new.report(if: false)
    end
  end

  def test_report_doesnt_report_when_report_if_is_false
    stub(CircuitSwitch.config).enable_report? { false }
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      CircuitSwitch::Core.new.report
    end
  end

  def test_run_with_question_returns_true_when_run
    stub(CircuitSwitch::RunCountUpdater).perform_later
    assert_equal(
      true,
      CircuitSwitch::Core.new.run {}.run?
    )
  end

  def test_run_with_question_returns_false_when_didnt_run
    assert_equal(
      false,
      CircuitSwitch::Core.new.run(if: false) {}.run?
    )
  end

  def test_reported_with_question_returns_true_when_reported
    stub(CircuitSwitch::Reporter).perform_later
    assert_equal(
      true,
      CircuitSwitch::Core.new.report.reported?
    )
  end

  def test_reported_with_question_returns_false_when_didnt_report
    stub(CircuitSwitch::Reporter).perform_later
    assert_equal(
      false,
      CircuitSwitch::Core.new.report(if: false).reported?
    )
  end
end
