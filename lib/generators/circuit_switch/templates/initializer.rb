# frozen_string_literal: true

CircuitSwitch.configure do |config|
  # Specify proc to call your report tool: like;
  # config.reporter = -> (message) { Bugsnag.notify(message) }
  config.reporter = nil

  # Allowed paths to report
  # CircuitSwitch recognizes logic as unique that first match with these paths
  # config.report_paths = [Rails.root]
end
