namespace :circuit_switch do
  desc 'Update run_limit_count to 0 to close running'
  task :run_limit_count_to_zero, ['caller'] => :environment do |_, arg|
    called_path = arg[:caller]
    puts "Start to update report_limit_count of circuit_switch for '#{called_path}' to zero."

    switch = CircuitSwitch::CircuitSwitch.find_by!(caller: called_path)
    puts "circuit_switch is found. id: #{switch.id}."

    switch.update(run_limit_count: 0)
    puts "Updated run_limit_count of circuit_switch for '#{called_path}' to zero."
  end

  desc 'Update report_limit_count to 0 to stop reporting'
  task :report_limit_count_to_zero, ['caller'] => :environment do |_, arg|
    called_path = arg[:caller]
    puts "Start to update report_limit_count of circuit_switch for '#{called_path}' to zero."

    switch = CircuitSwitch::CircuitSwitch.find_by!(caller: called_path)
    puts "circuit_switch is found. id: #{switch.id}."

    switch.update(report_limit_count: 0)
    puts "Updated report_limit_count of circuit_switch for '#{called_path}' to zero."
  end
end
