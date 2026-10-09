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

  /// Plain calendar-relative name shown under dates on entry cards.
  String get phaseName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Period';
      case CyclePhase.follicular:
        return 'Follicular phase';
      case CyclePhase.fertile:
        return 'Fertile window';
      case CyclePhase.ovulatory:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal phase';
    }
  }
}
