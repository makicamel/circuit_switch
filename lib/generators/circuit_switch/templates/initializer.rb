# frozen_string_literal: true

CircuitSwitch.configure do |config|
  # Specify proc to call your report tool: like;
  # config.reporter = -> (message, error) { Bugsnag.notify(error) }
  # config.reporter = -> (message, error) { Sentry::Rails.capture_message(message) }
  config.reporter = nil

  # Condition to report
  # config.report_if = Rails.env.production?

  # Allowed paths to report
  # CircuitSwitch recognizes logic as unique that first match with these paths.
  # Allowed all paths when set `[]`.
  # config.report_paths = [Rails.root]

  # Excluded paths to report
  # config.silent_paths = [CIRCUIT_SWITCH]

  # Alias column name for circuit_switches.key through alias_attribute
  # config.key_column_name = :key

  # Notifier to notify circuit_switch's due_date come and it's time to clean code!
  # Specify proc to call your report tool: like;
  # config.due_date_notifier = -> (message) { Slack::Web::Client.new.chat_postMessage(channel: '#your_channel', text: message) }
  # config.due_date_notifier = nil

  # Date for due_date_notifier
  # config.due_date = Date.today + 10

  # Option to contain error backtrace for report
  # You don't need backtrace when you report to some bug report tool.
  # You may want backtrace when reporting to a plain feed; e.g. Slack or email.
  # config.with_backtrace = false

  # Allowed backtrace paths to report
  # Allowed all paths when set `[]`.
  # config.allowed_backtrace_paths = [Dir.pwd]

  # Omit path prefix in caller and backtrace for readability
  # config.strip_paths = [Dir.pwd]
end
