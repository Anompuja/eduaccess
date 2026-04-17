class ReportKpi {
  final String label;
  final String value;
  final String delta;

  const ReportKpi({
    required this.label,
    required this.value,
    required this.delta,
  });
}

class ReportCategory {
  final String label;
  final int value;

  const ReportCategory({
    required this.label,
    required this.value,
  });
}
