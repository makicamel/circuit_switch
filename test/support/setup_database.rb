if ActiveRecord.version >= Gem::Version.new('6.0')
  ActiveRecord::Base.configurations = { test: { adapter: 'sqlite3', database: ':memory:' } }
  ActiveRecord::Base.establish_connection :test
else
  ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
end

class CreateCircuitSwitches < ActiveRecord::Migration[5.0]
  def self.up
    create_table :circuit_switches do |t|
      t.string :awesome_key, null: false
      t.string :caller, null: false
      t.integer :run_count, default: 0, null: false
      t.integer :run_limit_count, default: 10, null: false
      t.boolean :run_is_terminated, default: false, null: false
      t.integer :report_count, default: 0, null: false
      t.integer :report_limit_count, default: 10, null: false
      t.boolean :report_is_terminated, default: false, null: false
      t.date :due_date, null: false
      t.timestamps
    end
    add_index :circuit_switches, [:awesome_key], unique: true
  end
end

ActiveRecord::Migration.verbose = false
CreateCircuitSwitches.up
