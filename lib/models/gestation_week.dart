class GestationWeek {
  const GestationWeek({
    required this.startWeek,
    required this.endWeek,
    required this.size,
    required this.development,
    required this.tip,
  });

  final int startWeek;
  final int endWeek;
  final String size;
  final String development;
  final String tip;

  bool covers(int week) => week >= startWeek && week <= endWeek;
}
