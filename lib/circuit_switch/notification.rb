require 'circuit_switch/stacktrace_modifier'

module CircuitSwitch
  class CircuitSwitchNotification < RuntimeError
  end

  class CalledNotification < CircuitSwitchNotification
    def to_message
      if ::CircuitSwitch.config.with_backtrace
        "#{message}\n#{StacktraceModifier.call(backtrace: backtrace)}"
      else
        message
      end
    end
  end
end
