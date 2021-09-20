# frozen_string_literal: true

CircuitSwitch.configure do |config|
  # Currently only Bugsnag is supported
  # config.report_tool = :bugsnag

  # Allowed paths to report
  # CircuitSwitch recognizes logic as unique that first match with these paths
  # config.report_paths = [Rails.root]
end
