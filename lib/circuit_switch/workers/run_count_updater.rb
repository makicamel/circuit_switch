require 'active_job'
require 'active_support/core_ext/module/delegation'

module CircuitSwitch
  class RunCountUpdater < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform(key:, limit_count:, called_path:, reported:, initially_closed:)
      # Wait for Reporter saves circuit_switch
      sleep(3) if reported

      first_raise = true
      begin
        circuit_switch = key ? CircuitSwitch.find_by(key: key) : CircuitSwitch.find_by(caller: called_path)
        if reported && circuit_switch.nil?
          raise ActiveRecord::RecordNotFound.new('Couldn\'t find CircuitSwitch::CircuitSwitch')
        end

        circuit_switch ||= CircuitSwitch.new(key: key, caller: called_path, run_is_terminated: initially_closed)
        circuit_switch.due_date ||= config.due_date
        circuit_switch.assign(run_limit_count: limit_count).increment_run_count!
      rescue ActiveRecord::RecordInvalid => e
        raise e unless first_raise

        first_raise = false
        sleep(2)
        retry
      end
    end
  end
end
