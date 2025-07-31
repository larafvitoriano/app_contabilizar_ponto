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
    const Color primaryColor = Color(0xFF004D40); // Definição de cor
    const Color secondaryColor = Color(0xFF568F80); // Definição de cor

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendário',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card( // O Card envolve o TableCalendar para a estilização do container
          color: Colors.grey[200],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime.utc(2010, 10, 20),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mês', // Nome para o formato de mês se o botão for visível
              },
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
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Mantido como false para remover os botões Week/Month
                titleCentered: true,
                formatButtonTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                formatButtonDecoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.green),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.green),
              ),
              calendarStyle: CalendarStyle(
                weekendTextStyle: const TextStyle(
                  color: Colors.red,
                ),
                todayDecoration: BoxDecoration(
                  color: secondaryColor, // Usando a cor definida
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: primaryColor, // Usando a cor definida para o dia selecionado
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white), // Cor do texto do dia selecionado
              ),
              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, day) {
                  final formattedDate = DateFormat.yMMMM('pt_BR').format(day);
                  // Capitaliza a primeira letra da string formatada
                  final capitalized = formattedDate[0].toUpperCase() +
                      formattedDate.substring(1);
                  return Center(
                    child: Text(
                      capitalized,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}