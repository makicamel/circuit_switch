namespace :circuit_switch do
  desc 'Update run_is_terminated to true to close circuit'
  task :terminate_to_run, ['key_or_caller'] => :environment do |_, arg|
    key_or_caller = arg[:key_or_caller]
    puts "Start to update run_is_terminated of circuit_switch for '#{key_or_caller}' to true."
    sleep(3)

    switch = CircuitSwitch::CircuitSwitch.find_by(key: key_or_caller) || CircuitSwitch::CircuitSwitch.find_by!(caller: key_or_caller)
    puts "circuit_switch is found. id: #{switch.id}."

    switch.update(run_is_terminated: true)
    puts "Updated run_is_terminated of circuit_switch for '#{key_or_caller}' to true."
  end

  desc 'Update report_is_terminated to true to stop reporting'
  task :terminate_to_report, ['key_or_caller'] => :environment do |_, arg|
    key_or_caller = arg[:key_or_caller]
    puts "Start to update report_is_terminated of circuit_switch for '#{key_or_caller}' to true."
    sleep(3)

    switch = CircuitSwitch::CircuitSwitch.find_by(key: key_or_caller) || CircuitSwitch::CircuitSwitch.find_by!(caller: key_or_caller)
    puts "circuit_switch is found. id: #{switch.id}."

    switch.update(report_is_terminated: true)
    puts "Updated report_is_terminated of circuit_switch for '#{key_or_caller}' to true."
  end

  desc 'Delete switch'
  task :delete_switch, ['key_or_caller'] => :environment do |_, arg|
    key_or_caller = arg[:key_or_caller]
    puts "Start to delete circuit_switch for '#{key_or_caller}'."
    sleep(3)

    switch = CircuitSwitch::CircuitSwitch.find_by(key: key_or_caller) || CircuitSwitch::CircuitSwitch.find_by!(caller: key_or_caller)
    puts "circuit_switch is found. id: #{switch.id}."

    switch.destroy!
    puts "Successfully deleted circuit_switch for '#{key_or_caller}'."
  end
end
