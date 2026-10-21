/// What the user is here for. Drives the tone of the fertility copy.
enum CycleGoal {
  track,
  conceive;

  /// Parses a stored [name], falling back to [CycleGoal.track].
  static CycleGoal fromName(String? name) =>
      values.firstWhere((goal) => goal.name == name, orElse: () => CycleGoal.track);
}

extension CycleGoalLabel on CycleGoal {
  String get label => switch (this) {
        CycleGoal.track => 'Track',
        CycleGoal.conceive => 'Conceive',
      };

  String get blurb => switch (this) {
        CycleGoal.track => 'Follow your cycle, no goal in mind.',
        CycleGoal.conceive => 'Time things around your fertile days.',
      };
}
