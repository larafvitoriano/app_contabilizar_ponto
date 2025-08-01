import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/selected_date_range.dart';

class MultiDaySelectionDialog extends StatefulWidget {
  final DateTime initialSelectedDay;

  const MultiDaySelectionDialog({
    super.key,
    required this.initialSelectedDay,
  });

  @override
  State<MultiDaySelectionDialog> createState() => _MultiDaySelectionDialogState();
}

class _MultiDaySelectionDialogState extends State<MultiDaySelectionDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalBusinessDays = 0;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime(widget.initialSelectedDay.year, widget.initialSelectedDay.month, widget.initialSelectedDay.day);
    _endDate = DateTime(widget.initialSelectedDay.year, widget.initialSelectedDay.month, widget.initialSelectedDay.day);
    _totalBusinessDays = _calculateBusinessDays(_startDate!, _endDate!);
  }

  /// Calcula o número de dias úteis (segunda a sexta) entre duas datas.
  int _calculateBusinessDays(DateTime startDate, DateTime endDate) {
    int businessDays = 0;

    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (current.weekday >= DateTime.monday && current.weekday <= DateTime.friday) {
        businessDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    return businessDays;
  }

  /// Abre um seletor de data e atualiza a data de início ou fim.
  /// Garante que a data de início não seja posterior à data de fim e vice-versa.
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate! : _endDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      helpText: isStart ? 'SELECIONE A DATA DE INÍCIO' : 'SELECIONE A DATA DE FIM',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
      fieldLabelText: 'Insira a data',
      errorFormatText: 'Formato de data inválido.',
      errorInvalidText: 'Data fora do intervalo.',
    );
    if (picked != null) {
      setState(() {
        final normalizedPicked = DateTime(picked.year, picked.month, picked.day);

        if (isStart) {
          _startDate = normalizedPicked;
          // Se a data de fim for anterior à nova data de início, ajusta a data de fim
          if (_endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = normalizedPicked;
          // Se a data de início for posterior à nova data de fim, ajusta a data de início
          if (_startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
        _totalBusinessDays = _calculateBusinessDays(_startDate!, _endDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Período de Ponto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Data de Início:'),
            subtitle: Text(DateFormat.yMd('pt_BR').format(_startDate!)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context, true),
          ),
          ListTile(
            title: const Text('Data de Fim:'),
            subtitle: Text(DateFormat.yMd('pt_BR').format(_endDate!)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context, false),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dias Úteis no Período: $_totalBusinessDays',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(SelectedDateRange(
              startDate: _startDate!,
              endDate: _endDate!,
              totalBusinessDays: _totalBusinessDays,
            ));
          },
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}