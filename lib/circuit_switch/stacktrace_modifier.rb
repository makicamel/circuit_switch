require 'circuit_switch/configuration.rb'

module CircuitSwitch
  class StacktraceModifier
    class << self
      delegate :config, to: ::CircuitSwitch

      def call(backtrace:)
        backtrace
          .select { |path| /(#{config.allowed_backtrace_paths.join('|')})/.match?(path) }
          .map { |path| path.sub(/(#{config.strip_paths.join('|')})/, '') }
          .join("\n")
      end
    end
  end
end
