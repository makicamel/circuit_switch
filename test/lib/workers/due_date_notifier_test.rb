require 'test_helper'

class DueDateNotifierTest < Test::Unit::TestCase
  include ::CircuitSwitch::TestHelper

  setup do
    CircuitSwitch::CircuitSwitch.truncate
  end

  def test_notifier_calls_config_notifier
    message = 'There is no switch!'
    assert_equal(
      message,
      CircuitSwitch::DueDateNotifier.new.perform
    )
  end

  def test_notifier_notifies_when_due_date_has_come
    due_date = Date.today
    circuit_switch = CircuitSwitch::CircuitSwitch.create(caller: called_path, due_date: due_date)
    message = "Due date has come! Let's consider about removing switches and cleaning up code! :)\n" +
      "id: #{circuit_switch.id}, key: '#{circuit_switch.caller}', caller: '#{circuit_switch.caller}', created_at: #{circuit_switch.created_at}"
    assert_equal(
      message,
      CircuitSwitch::DueDateNotifier.new.perform
    )
  end

  def test_notifier_notifies_when_due_date_does_not_come
    due_date = Date.today + 1
    CircuitSwitch::CircuitSwitch.create(caller: called_path, due_date: due_date)
    message = '1 switches are waiting for their due_date.'
    assert_equal(
      message,
      CircuitSwitch::DueDateNotifier.new.perform
    )
  end

  def test_notifier_raises_error_when_config_due_date_notifier_is_nil
    stub(CircuitSwitch.config).due_date_notifier { nil }
    assert_raise ::CircuitSwitch::CircuitSwitchError do
      CircuitSwitch::DueDateNotifier.new.perform
    end
  end
end
