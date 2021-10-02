require 'date'

module CircuitSwitch
  class DueDateNotifier < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform
      raise CircuitSwitchError.new('Set config.due_date_notifier.') unless config.due_date_notifier

      circuit_switches = CircuitSwitch.where('due_date <= ?', Date.today).order(id: :asc)
      if circuit_switches.present?
        message = "Due date has come! Let's consider about removing switches and cleaning up code! :)\n" +
          circuit_switches.map { |switch|  "id: #{switch.id}, caller: '#{switch.caller}' , created_at: #{switch.created_at}" }.join("\n")
        config.due_date_notifier.call(message)
      else
        switches_count = CircuitSwitch.all.size
        message = switches_count.zero? ? 'There is no switch!' : "#{switches_count} switches are waiting for their due_date."
        config.due_date_notifier.call(message)
      end
    end
  end
end
