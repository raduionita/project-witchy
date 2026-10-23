enum TrendDirection {
  up('Increasing'),
  down('Decreasing'),
  stable('Stable'),
  insufficient('Not enough data');

  const TrendDirection(this.label);
  final String label;
}
