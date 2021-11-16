module CircuitSwitch
  def self.table_name_prefix
    ''
  end

  class Engine < ::Rails::Engine
    isolate_namespace ::CircuitSwitch
  end
end
