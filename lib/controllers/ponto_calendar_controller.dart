import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../database/contracts/ponto_repository_contract.dart';
import '../database/models/ponto_registro_model.dart';
import '../database/repositories/ponto_repository_impl.dart';
import '../utils/selected_date_range.dart';
import '../widgets/ponto_registro_dialog.dart';
import '../widgets/selecionar_varios_dias.dialog.dart';

class PontoCalendarController extends ChangeNotifier {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<PontoRegistroModel> _registrosDoDiaSelecionado = [];
  Map<DateTime, List<PontoRegistroModel>> _registrosDoMesFocado = {};

  final IPontoRepository _pontoRepository = PontoRepositoryImpl();

  PontoCalendarController() {
    initializeDateFormatting('pt_BR', null);
    _selectedDay = _focusedDay;
    _carregarRegistrosDoDia(_selectedDay!);
    _loadAllRecordsForMonth(_focusedDay);
  }

  CalendarFormat get calendarFormat => _calendarFormat;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  List<PontoRegistroModel> get registrosDoDiaSelecionado => _registrosDoDiaSelecionado;
  IPontoRepository get pontoRepository => _pontoRepository;

  Future<void> _carregarRegistrosDoDia(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final registros = await _pontoRepository.getPontosByDate(normalizedDate);
    _registrosDoDiaSelecionado = registros;
    notifyListeners();
  }

  Future<void> _loadAllRecordsForMonth(DateTime month) async {
    final DateTime startOfMonth = DateTime(month.year, month.month, 1);
    final DateTime endOfMonth = DateTime(month.year, month.month + 1, 0);

    final allPontos = await _pontoRepository.getAllPontos();

    _registrosDoMesFocado.clear();
    for (var ponto in allPontos) {
      final normalizedDate = DateTime(ponto.data.year, ponto.data.month, ponto.data.day);
      if (normalizedDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          normalizedDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        _registrosDoMesFocado.putIfAbsent(normalizedDate, () => []).add(ponto);
      }
    }
    notifyListeners();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _carregarRegistrosDoDia(selectedDay);
      _loadAllRecordsForMonth(focusedDay);
      notifyListeners();
    }
  }

  void onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      _calendarFormat = format;
      notifyListeners();
    }
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    _selectedDay = focusedDay;
    _carregarRegistrosDoDia(_selectedDay!);
    _loadAllRecordsForMonth(_focusedDay);
    notifyListeners();
  }

  bool hasRecordsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _registrosDoMesFocado.containsKey(normalizedDay) &&
        _registrosDoMesFocado[normalizedDay]!.isNotEmpty;
  }

  Future<void> showPontoRegisterOptions(BuildContext context, DateTime initialSelectedDay, {PontoRegistroModel? registroParaEditar}) async {
    SelectedDateRange? selectedRange;

    if (registroParaEditar != null) {
      selectedRange = SelectedDateRange(
        startDate: registroParaEditar.data,
        endDate: registroParaEditar.data,
        totalBusinessDays: (registroParaEditar.data.weekday >= DateTime.monday && registroParaEditar.data.weekday <= DateTime.friday) ? 1 : 0,
      );
    } else {
      selectedRange = await showDialog<SelectedDateRange>(
        context: context,
        builder: (BuildContext dialogContext) {
          return MultiDaySelectionDialog(initialSelectedDay: initialSelectedDay);
        },
      );
    }

    if (selectedRange != null) {
      final DateTime startDate = selectedRange.startDate;
      final DateTime endDate = selectedRange.endDate;
      final int totalBusinessDays = selectedRange.totalBusinessDays;

      PontoRegistroModel? finalRegistroParaEditar = registroParaEditar;
      if (finalRegistroParaEditar == null && startDate.isAtSameMomentAs(endDate)) {
        final existingRecords = await _pontoRepository.getPontosByDate(startDate);
        if (existingRecords.isNotEmpty) {
          finalRegistroParaEditar = existingRecords.first;
        }
      }

      final result = await showDialog<String?>(
        context: context,
        builder: (context) => PontoRegistroDialog(
          startDate: startDate,
          endDate: endDate,
          registroParaEditar: finalRegistroParaEditar,
          pontoRepository: _pontoRepository,
          totalBusinessDays: totalBusinessDays,
        ),
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
        _carregarRegistrosDoDia(_selectedDay ?? _focusedDay);
        _loadAllRecordsForMonth(_focusedDay);
      }
    }
  }

  Future<void> deletePontoRecord(BuildContext context, int id, DateTime day) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este registro de ponto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _pontoRepository.deletePonto(id);
        _carregarRegistrosDoDia(day);
        _loadAllRecordsForMonth(day);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro de ponto excluído com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir registro: $e')),
        );
      }
    }
  }
}