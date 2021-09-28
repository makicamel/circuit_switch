module CircuitSwitch
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'circuit_switch/tasks/circuit_switch.rake'
    end
  end
end
