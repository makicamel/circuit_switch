require 'rails/generators/active_record'

module CircuitSwitch
  class MigrationGenerator < ActiveRecord::Generators::Base
    desc 'Create a migration to manage circuit switches state'
    source_root File.expand_path('templates', __dir__)

    def generate_migration
      migration_template 'migration.rb.erb', 'db/migrate/create_circuit_switches.rb', migration_version: migration_version
    end

    def migration_version
      if ActiveRecord::VERSION::MAJOR >= 5
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end
    end
  end
end
