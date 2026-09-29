enum CyclePhase { menstrual, follicular, fertile, ovulatory, luteal }

extension CyclePhaseLabel on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Shedding Tide';
      case CyclePhase.follicular:
        return 'Waxing Glow';
      case CyclePhase.fertile:
        return 'Fertile Window';
      case CyclePhase.ovulatory:
        return 'Full Moon Peak';
      case CyclePhase.luteal:
        return 'Waning Glow';
    }
  }
}
