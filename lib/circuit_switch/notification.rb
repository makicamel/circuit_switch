require_relative 'stacktrace_modifier'

module CircuitSwitch
  class CircuitSwitchError < RuntimeError
  end

  class CircuitSwitchNotification < RuntimeError
  end

  class CalledNotification < CircuitSwitchNotification
    def to_message(called_path:)
      if ::CircuitSwitch.config.with_backtrace
        "#{message}\ncalled_path: #{called_path}\n#{StacktraceModifier.call(backtrace: backtrace)}"
      else
        message
      end
    end
  end
end
