enum CycleCondition {
  postpartum('Postpartum'),
  breastfeeding('Breastfeeding'),
  pregnancyLoss('Pregnancy loss'),
  pcos('PCOS');

  const CycleCondition(this.label);

  final String label;

  static CycleCondition fromJson(Object? raw) => CycleCondition.values.firstWhere(
    (condition) => condition.name == raw,
    orElse: () => CycleCondition.pcos,
  );

  String toJson() => name;
}
