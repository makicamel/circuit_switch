CircuitSwitch::Engine.routes.draw do
  resources 'circuit_switch', only: [:index, :edit, :update, :destroy], controller: 'circuit_switch'
  root to: 'circuit_switch#index'
end
