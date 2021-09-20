module CircuitSwitch
  class CircuitSwitchNotification < RuntimeError
  end

  class CalledNotification < CircuitSwitchNotification
  end

  class ReportToolNotFound < CircuitSwitchNotification
  end
end
