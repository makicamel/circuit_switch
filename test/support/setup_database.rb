ActiveRecord::Base.configurations = { test: { adapter: 'sqlite3', database: ':memory:' } }
ActiveRecord::Base.establish_connection :test

class CreateCircuitSwitches < ActiveRecord::Migration[6.1]
  def self.up
    create_table :circuit_switches do |t|
      t.string :caller, null: false
      t.integer :run_count, default: 0, null: false
      t.integer :run_limit_count, default: 10, null: false
      t.integer :report_count, default: 0, null: false
      t.integer :report_limit_count, default: 10, null: false
      t.date :date_to_be_removed, default: Time.now + 10.days, null: false
      t.timestamps
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateCircuitSwitches.up
