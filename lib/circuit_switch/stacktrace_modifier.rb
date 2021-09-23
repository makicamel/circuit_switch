require 'circuit_switch/configuration.rb'

module CircuitSwitch
  class StacktraceModifier
    class << self
      delegate :config, to: ::CircuitSwitch

      def call(backtrace:)
        backtrace
          .select { |path| path.match?(/(#{config.allowed_backtrace_paths.join('|')})/) }
          .map { |path| path.sub(/(#{config.strip_paths.join('|')})/, '') }
          .join("\n")
      end
    end
  end
end
