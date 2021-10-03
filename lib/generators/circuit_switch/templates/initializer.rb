# frozen_string_literal: true

CircuitSwitch.configure do |config|
  # Specify proc to call your report tool: like;
  # config.reporter = -> (message) { Bugsnag.notify(message) }
  config.reporter = nil

  # Condition to report
  # config.report_if = Rails.env.production?

  # Allowed paths to report
  # CircuitSwitch recognizes logic as unique that first match with these paths.
  # Allowed all paths when set `[]`.
  # config.report_paths = [Rails.root]

  # Excluded paths to report
  # config.silent_paths =  [CIRCUIT_SWITCH]

  # Notifier to notify circuit_switch's due_date come and it's time to clean code!
  # Specify proc to call your report tool: like;
  # config.due_date_notifier = -> (message) { Slack::Web::Client.new.chat_postMessage(channel: '#your_channel', text: message) }
  # config.due_date_notifier = nil

  # Date for due_date_notifier
  # config.due_date = Date.today + 10

  # Option to contain error backtrace for report
  # You don't need backtrace when you report to some bug report tool.
  # You may be want backtrace when report to plain feed; e.g. Slack or email.
  # config.with_backtrace = false

  # Allowd backtrace paths to report
  # Specify with `with_backtrace` option.
  # Allowed all paths when set `[]`.
  # config.allowed_backtrace_paths = [Dir.pwd]

  # Omit path prefix in caller and backtrace for readability
  # config.strip_paths = [Dir.pwd]
end
