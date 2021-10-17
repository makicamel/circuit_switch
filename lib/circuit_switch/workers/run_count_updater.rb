module CircuitSwitch
  class RunCountUpdater < ::ActiveJob::Base
    delegate :config, to: ::CircuitSwitch

    def perform(key:, limit_count:, called_path:, reported:)
      circuit_switch =
        if reported
          # Wait for Reporter saves circuit_switch
          sleep(3)
          CircuitSwitch.find_by(key: key) || CircuitSwitch.find_by!(caller: called_path)
        else
          CircuitSwitch.find_by(key: key) || CircuitSwitch.find_or_initialize_by(key: key, caller: called_path)
        end
      circuit_switch.due_date ||= config.due_date
      circuit_switch.assign(run_limit_count: limit_count).increment_run_count
    end
  end
end
