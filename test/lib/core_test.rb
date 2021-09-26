require 'test_helper'

class CoreTest < Test::Unit::TestCase
  setup do
    CircuitSwitch::CircuitSwitch.truncate
  end

  def test_run_calls_block_when_all_conditions_are_clear
    test_value = 0
    CircuitSwitch::Core.new.run { test_value = 1 }
    assert_equal(
      1,
      test_value
    )
  end

  def test_run_creates_circuit_switch_when_block_is_called_and_no_switch
    called_path = CircuitSwitch::Core.new.run {}.__send__(:called_path)
    assert_equal(
      true,
      CircuitSwitch::CircuitSwitch.exists?(caller: called_path)
    )
  end

  def test_run_increments_run_count_when_block_is_called
    called_path = CircuitSwitch::Core.new.run {}.__send__(:called_path)
    assert_equal(
      1,
      CircuitSwitch::CircuitSwitch.find_by(caller: called_path).run_count
    )

    CircuitSwitch::Core.new.run {}
    assert_equal(
      2,
      CircuitSwitch::CircuitSwitch.find_by(caller: called_path).run_count
    )
  end

  def test_run_calls_block_when_close_if_reach_limit_is_false_and_reached_limit
    test_value = 0
    CircuitSwitch::Core.new.run(limit_count: 1) { test_value = 1 }
    CircuitSwitch::Core.new.run(close_if_reach_limit: false) { test_value = 2 }
    assert_equal(
      2,
      test_value
    )
  end

  def test_run_doesnt_call_block_when_close_if_reach_limit_is_true_and_reached_limit
    test_value = 0
    CircuitSwitch::Core.new.run(limit_count: 1) { test_value = 1 }
    CircuitSwitch::Core.new.run(close_if_reach_limit: true) { test_value = 2 }
    assert_equal(
      1,
      test_value
    )
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
    core = CircuitSwitch::Core.new
    stub(core).called_path { 'test' }
    stub(CircuitSwitch::Reporter).perform_later(limit_count: nil, called_path: 'test')
    core.report
    assert_received(CircuitSwitch::Reporter) do |reporter|
      reporter.perform_later(limit_count: nil, called_path: 'test')
    end
  end

  def test_report_reports_when_close_if_reach_limit_is_false_and_reached_limit
    core = CircuitSwitch::Core.new
    stub(core).called_path { 'test' }
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1, called_path: 'test')
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 10, called_path: 'test')
    core.report(limit_count: 1)
    core.report(limit_count: 10, stop_report_if_reach_limit: false)
    assert_received(CircuitSwitch::Reporter) do |reporter|
      reporter.perform_later(limit_count: 10, called_path: 'test')
    end
  end

  def test_report_doesnt_call_block_when_close_if_reach_limit_is_true_and_reached_limit
    core1, core2 = CircuitSwitch::Core.new, CircuitSwitch::Core.new
    stub(core1).called_path { 'test' }
    stub(core2).called_path { 'test' }
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1, called_path: 'test') do
      CircuitSwitch::CircuitSwitch.new(caller: 'test', report_limit_count: 1).increment_report_count
    end
    core1.report(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      core2.report(limit_count: 10, stop_report_if_reach_limit: true)
    end
  end

  def test_report_doesnt_call_block_when_stop_report_if_is_true
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      CircuitSwitch::Core.new.report(stop_report_if: true)
    end
  end

  def test_report_doesnt_call_block_when_if_is_false
    stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
    assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
      CircuitSwitch::Core.new.report(if: false)
    end
  end

  def test_report_doesnt_call_block_when_report_if_is_false
    stub.proxy(CircuitSwitch::Configuration).new do |config|
      stub(config).enable_report? { false }
      stub(CircuitSwitch::Reporter).perform_later(limit_count: 1)
      assert_nothing_raised(RR::Errors::DoubleNotFoundError) do
        CircuitSwitch::Core.new.report
      end
    end
  end

  def test_run_with_question_returns_true_when_run
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
