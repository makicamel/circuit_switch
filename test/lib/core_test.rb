require 'test_helper'

class CoreTest < Test::Unit::TestCase
  include ::CircuitSwitch::TestHelper

  setup do
    CircuitSwitch::CircuitSwitch.truncate
  end

  def runner(arguments = {})
    core = CircuitSwitch::Builder.new
    core.assign_runner(**arguments)
    core
  end

  def reporter(arguments = {})
    core = CircuitSwitch::Builder.new
    core.assign_reporter(**arguments)
    core
  end

  def test_run_calls_block_when_all_conditions_are_clear
    stub(CircuitSwitch::RunCountUpdater).perform_later
    test_value = 0
    runner.execute_run { test_value = 1 }
    assert_equal(
      1,
      test_value
    )
  end

  def test_run_calls_updater_when_block_is_called_and_no_switch
    stub(CircuitSwitch::RunCountUpdater).perform_later(limit_count: nil, key: nil, called_path: called_path, reported: false, initially_closed: false)
    runner.execute_run {}
    assert_received(CircuitSwitch::RunCountUpdater) do |updator|
      updator.perform_later(limit_count: nil, key: nil, called_path: called_path, reported: false, initially_closed: false)
    end
  end

  def test_run_calls_block_when_close_if_reach_limit_is_false_and_reached_limit
    stub(CircuitSwitch::RunCountUpdater).perform_later(limit_count: nil, key: nil, called_path: called_path, reported: false, initially_closed: false)
    limit_count = 1
    CircuitSwitch::CircuitSwitch.new(run_limit_count: limit_count, caller: called_path, due_date: due_date).increment_run_count

    test_value = 0
    runner(close_if_reach_limit: false).execute_run { test_value = 1 }
    assert_equal(
      1,
      test_value
    )
  end

  def test_run_doesnt_call_block_when_close_if_reach_limit_is_true_and_reached_limit
    limit_count = 1
    CircuitSwitch::CircuitSwitch.new(run_limit_count: limit_count, caller: called_path, due_date: due_date).increment_run_count

    test_value = 0
    runner(close_if_reach_limit: true).execute_run { test_value = 1 }
    assert_equal(
      0,
      test_value
    )
  end

  def test_run_doesnt_call_block_when_run_is_terminated
    CircuitSwitch::CircuitSwitch.create(caller: called_path, due_date: due_date, run_is_terminated: true)
    test_value = 0
    runner.execute_run { test_value = 1 }
    assert_equal(
      0,
      test_value
    )
  end

  def test_run_raises_error_when_close_if_reach_limit_is_true_and_reached_limit_is_zero
    assert_raise CircuitSwitch::CircuitSwitchError do
      runner(close_if_reach_limit: true, limit_count: 0).execute_run {}
    end
  end

  def test_run_doesnt_call_block_when_close_if_is_true
    test_value = 0
    runner(close_if: true).execute_run { test_value = 1 }
    assert_equal(
      0,
      test_value
    )
  end

  def test_run_doesnt_call_block_when_if_is_false
    test_value = 0
    runner(if: false).execute_run { test_value = 1 }
    assert_equal(
      0,
      test_value
    )
  end

  def test_report_reports_when_all_conditions_are_clear
    stub(CircuitSwitch::Reporter).perform_later(limit_count: nil, key: nil, called_path: called_path, run: false)
    reporter.execute_report
    assert_received(CircuitSwitch::Reporter) do |reporter|
      reporter.perform_later(limit_count: nil, key: nil, called_path: called_path, run: false)
    end
  end

  def test_report_reports_when_close_if_reach_limit_is_false_and_reached_limit
    limit_count = 1
    CircuitSwitch::CircuitSwitch.new(report_limit_count: limit_count, caller: called_path, due_date: due_date).increment_report_count
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1, key: nil, called_path: called_path, run: false)

    reporter(limit_count: 1, stop_report_if_reach_limit: false).execute_report
    assert_received(CircuitSwitch::Reporter) do |reporter|
      reporter.perform_later(limit_count: 1, key: nil, called_path: called_path, run: false)
    end
  end

  def test_report_doesnt_report_when_close_if_reach_limit_is_true_and_reached_limit
    limit_count = 1
    CircuitSwitch::CircuitSwitch.new(report_limit_count: limit_count, caller: called_path, due_date: due_date).increment_report_count
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 10, called_path: called_path, run: false)

    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      reporter(limit_count: 1, stop_report_if_reach_limit: true).execute_report
    end
  end

  def test_report_raises_error_when_reporter_is_nil
    stub(CircuitSwitch.config).reporter { nil }
    assert_raise CircuitSwitch::CircuitSwitchError do
      reporter.execute_report
    end
  end

  def test_report_raises_error_when_stop_report_if_reach_limit_is_true_and_reached_limit_is_zero
    assert_raise CircuitSwitch::CircuitSwitchError do
      reporter(stop_report_if_reach_limit: true, limit_count: 0).execute_report
    end
  end

  def test_report_doesnt_report_when_report_is_terminated
    CircuitSwitch::CircuitSwitch.create(caller: called_path, due_date: due_date, report_is_terminated: true)

    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      reporter.execute_report
    end
  end

  def test_report_doesnt_report_when_stop_report_if_is_true
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      reporter(stop_report_if: true).execute_report
    end
  end

  def test_report_doesnt_report_when_if_is_false
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      reporter(if: false).execute_report
    end
  end

  def test_report_doesnt_report_when_report_if_is_false
    stub(CircuitSwitch.config).enable_report? { false }
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      reporter.execute_report
    end
  end

  def test_run_with_question_returns_true_when_run
    stub(CircuitSwitch::RunCountUpdater).perform_later
    assert_equal(
      true,
      runner.execute_run {}.run?
    )
  end

  def test_run_with_question_returns_false_when_didnt_run
    assert_equal(
      false,
      runner(if: false).execute_run {}.run?
    )
  end

  def test_reported_with_question_returns_true_when_reported
    stub(CircuitSwitch::Reporter).perform_later
    assert_equal(
      true,
      reporter.execute_report.reported?
    )
  end

  def test_reported_with_question_returns_false_when_didnt_report
    stub(CircuitSwitch::Reporter).perform_later
    assert_equal(
      false,
      reporter(if: false).execute_report.reported?
    )
  end
end
