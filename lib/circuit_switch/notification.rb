module CircuitSwitch
  class CircuitSwitchNotification < RuntimeError
  end

  class CalledNotification < CircuitSwitchNotification
  end
end
