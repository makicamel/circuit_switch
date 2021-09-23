require 'circuit_switch/configuration.rb'

module CircuitSwitch
  class StacktraceModifier
    class << self
      delegate :config, to: ::CircuitSwitch

      def call(backtrace:)
        backtrace.select { |path| path.match?(/(#{config.report_paths.join('|')})/) }.join("\n")
      end
    end
  end
end
