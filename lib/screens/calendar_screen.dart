import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    const Color primaryColor = const Color(0xFF004D40);
    const Color secondaryColor = const Color(0xFF568F80);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          locale: 'pt_BR',
          firstDay: DateTime.utc(2010, 10, 20),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            formatButtonTextStyle:
            TextStyle(color: Colors.white, fontSize: 16),
            titleTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20
            ),
            leftChevronIcon:
            Icon(Icons.chevron_left, color: Colors.green),
            rightChevronIcon:
            Icon(Icons.chevron_right, color: Colors.green,
          ),
        ),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
      ),
    )
    );
  }
}
