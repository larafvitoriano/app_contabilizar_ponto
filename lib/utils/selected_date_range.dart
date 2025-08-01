
/// Uma classe para encapsular o resultado da seleção de um intervalo de datas.
/// Torna o retorno de MultiDaySelectionDialog mais seguro e explícito.
class SelectedDateRange {
  final DateTime startDate;
  final DateTime endDate;
  final int totalBusinessDays;

  SelectedDateRange({
    required this.startDate,
    required this.endDate,
    required this.totalBusinessDays,
  });

  @override
  String toString() {
    return 'SelectedDateRange(startDate: $startDate, endDate: $endDate, totalBusinessDays: $totalBusinessDays)';
  }
}