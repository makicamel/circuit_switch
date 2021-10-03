namespace :circuit_switch do
  desc 'Update run_is_terminated to true to close circuit'
  task :terminate_to_run, ['caller'] => :environment do |_, arg|
    called_path = arg[:caller]
    puts "Start to update run_is_terminated of circuit_switch for '#{called_path}' to true."
    sleep(3)

    switch = CircuitSwitch::CircuitSwitch.find_by!(caller: called_path)
    puts "circuit_switch is found. id: #{switch.id}."

    switch.update(run_is_terminated: true)
    puts "Updated run_is_terminated of circuit_switch for '#{called_path}' to true."
  end

  desc 'Update report_is_terminated to true to stop reporting'
  task :terminate_to_report, ['caller'] => :environment do |_, arg|
    called_path = arg[:caller]
    puts "Start to update report_is_terminated of circuit_switch for '#{called_path}' to true."
    sleep(3)

    switch = CircuitSwitch::CircuitSwitch.find_by!(caller: called_path)
    puts "circuit_switch is found. id: #{switch.id}."

    switch.update(report_is_terminated: true)
    puts "Updated report_is_terminated of circuit_switch for '#{called_path}' to true."
  end
end
