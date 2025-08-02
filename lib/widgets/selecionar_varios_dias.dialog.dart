import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/selected_date_range.dart';

class MultiDaySelectionDialog extends StatefulWidget {
  final DateTime initialSelectedDay;

  const MultiDaySelectionDialog({super.key, required this.initialSelectedDay});

  @override
  State<MultiDaySelectionDialog> createState() => _MultiDaySelectionDialogState();
}

class _MultiDaySelectionDialogState extends State<MultiDaySelectionDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialSelectedDay;
    _endDate = widget.initialSelectedDay;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart ? _startDate : _endDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) _startDate = _endDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return AlertDialog(
      title: const Text('Selecionar intervalo de datas'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Data inicial'),
            subtitle: Text(formatter.format(_startDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context, true),
          ),
          ListTile(
            title: const Text('Data final'),
            subtitle: Text(formatter.format(_endDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context, false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final result = SelectedDateRange.fromDates(_startDate, _endDate);
            Navigator.of(context).pop(result);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
