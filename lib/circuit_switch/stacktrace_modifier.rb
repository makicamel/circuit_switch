require 'active_support/core_ext/module/delegation'

module CircuitSwitch
  class StacktraceModifier
    class << self
      delegate :config, to: ::CircuitSwitch

      def call(backtrace:)
        if config.with_backtrace
          backtrace
            .select { |path| /(#{config.allowed_backtrace_paths.join('|')})/.match?(path) }
            .map { |path| path.sub(/(#{config.strip_paths.join('|')})/, '') }
        else
          backtrace
            .select { |path| /(#{config.allowed_backtrace_paths.join('|')})/.match?(path) }
        end
      end
    end
  end
end
