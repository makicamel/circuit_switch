require 'rails/generators/active_record'

module CircuitSwitch
  class MigrationGenerator < ActiveRecord::Generators::Base
    desc 'Create a migration to manage circuit switches state'
    source_root File.expand_path('templates', __dir__)
    argument :migration_type, required: false, type: :array, default: ['create'],
      desc: 'Type of migration to create or add key column or make key unique. By default to create.',
      banner: 'create or add_key'

    def generate_migration
      case migration_type
      when ['add_key']
        migration_template 'add_key.rb.erb', 'db/migrate/add_key_to_circuit_switches.rb', migration_version: migration_version
      when ['make_key_unique']
        migration_template 'make_key_unique.rb.erb', 'db/migrate/make_key_unique_for_circuit_switches.rb', migration_version: migration_version
      else
        migration_template 'migration.rb.erb', 'db/migrate/create_circuit_switches.rb', migration_version: migration_version
      end
    end

    def migration_version
      if ActiveRecord::VERSION::MAJOR >= 5
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end
    end
  end
end
