# frozen_string_literal: true

module CircuitSwitch
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration
    source_root File.expand_path('templates', __dir__)
    desc 'Installs CircuitSwitch.'

    def install
      template 'initializer.rb', 'config/initializers/circuit_switch.rb'
    end
  end
end
