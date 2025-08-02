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

  /// Cria um range de datas com cálculo automático de dias úteis
  factory SelectedDateRange.fromDates(DateTime start, DateTime end) {
    final DateTime s = _normalize(start);
    final DateTime e = _normalize(end);
    final int businessDays = _countBusinessDays(s, e);
    return SelectedDateRange(
      startDate: s,
      endDate: e,
      totalBusinessDays: businessDays,
    );
  }

  /// Normaliza uma data para conter apenas ano/mês/dia
  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Verifica se é um dia útil (segunda a sexta)
  static bool isBusinessDay(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  /// Conta dias úteis entre duas datas, inclusive
  static int _countBusinessDays(DateTime start, DateTime end) {
    int count = 0;
    DateTime current = start;
    while (!current.isAfter(end)) {
      if (isBusinessDay(current)) count++;
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  @override
  String toString() {
    return 'SelectedDateRange(startDate: $startDate, endDate: $endDate, totalBusinessDays: $totalBusinessDays)';
  }
}
