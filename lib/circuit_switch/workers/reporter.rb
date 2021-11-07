require 'active_job'
require 'active_support/core_ext/module/delegation'

module CircuitSwitch
  class Reporter < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform(key:, limit_count:, called_path:, run:)
      # Wait for RunCountUpdater saves circuit_switch
      sleep(3) if run

      first_raise = true
      begin
        circuit_switch = key ? CircuitSwitch.find_by(key: key) : CircuitSwitch.find_by(caller: called_path)
        if run && circuit_switch.nil?
          raise ActiveRecord::RecordNotFound.new('Couldn\'t find CircuitSwitch::CircuitSwitch')
        end

        circuit_switch ||= CircuitSwitch.new(key: key, caller: called_path)
        circuit_switch.due_date ||= config.due_date
        circuit_switch.assign(report_limit_count: limit_count).increment_report_count!
        raise CalledNotification.new(circuit_switch.message)
      rescue ActiveRecord::RecordInvalid => e
        raise e unless first_raise

        first_raise = false
        sleep(2)
        retry
      rescue CalledNotification => notification
        if config.reporter.arity == 1
          config.reporter.call(notification.to_message(called_path: called_path))
        else
          config.reporter.call(notification.to_message(called_path: called_path), notification)
        end
      end
    end
  end
end
