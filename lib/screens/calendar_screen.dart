import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/ponto_calendar_controller.dart';
import '../database/models/ponto_registro_model.dart';
import '../widgets/ponto_card.dart'; //

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004D40);
    const Color secondaryColor = Color(0xFF568F80);

    return ChangeNotifierProvider(
      create: (_) => PontoCalendarController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Calendário',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Consumer<PontoCalendarController>(
            builder: (context, controller, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    child: Card(
                      color: Colors.grey[200],
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                        child: TableCalendar(
                          locale: 'pt_BR',
                          firstDay: DateTime.utc(2010, 10, 20),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: controller.focusedDay,
                          calendarFormat: controller.calendarFormat,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Mês',
                          },
                          selectedDayPredicate: (day) {
                            return isSameDay(controller.selectedDay, day);
                          },
                          onDaySelected: controller.onDaySelected,
                          onDayLongPressed: (selectedDay, focusedDay) {
                            controller.onDaySelected(selectedDay, focusedDay);
                            controller.showPontoRegisterOptions(context, selectedDay);
                          },
                          onFormatChanged: controller.onFormatChanged,
                          onPageChanged: controller.onPageChanged,
                          eventLoader: (day) {
                            final normalizedDay = DateTime(day.year, day.month, day.day);
                            return controller.hasRecordsForDay(normalizedDay) ? [true] : [];
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            formatButtonTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
                            titleTextStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.green),
                            rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.green),
                          ),
                          calendarStyle: CalendarStyle(
                            weekendTextStyle: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            todayDecoration: const BoxDecoration(
                              color: secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(color: Colors.white),
                            defaultTextStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            headerTitleBuilder: (context, day) {
                              final formattedDate = DateFormat.yMMMM('pt_BR').format(day);
                              final capitalized = formattedDate[0].toUpperCase() + formattedDate.substring(1);
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
                            markerBuilder: (context, day, events) {
                              return controller.hasRecordsForDay(day)
                                  ? Positioned(
                                top: 35,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor,
                                    ),
                                    width: 8.0,
                                    height: 8.0,
                                  ),
                                ),
                              )
                                  : null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (controller.selectedDay != null) {
                          controller.showPontoRegisterOptions(context, controller.selectedDay!);
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Registrar Ponto'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Exibição dos registros do dia selecionado
                  controller.selectedDay == null
                      ? const Center(child: Text('Selecione um dia para ver os registros de ponto.'))
                      : FutureBuilder<List<PontoRegistroModel>>(
                    future: controller.pontoRepository.getPontosByDate(controller.selectedDay!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erro ao carregar registros: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhum registro de ponto para ${DateFormat.yMd('pt_BR').format(controller.selectedDay!)}.',
                          ),
                        );
                      } else {
                        final registros = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: registros.length,
                          itemBuilder: (context, index) {
                            final registro = registros[index];
                            return PontoRecordCard(
                              ponto: registro,
                              onDelete: () {
                                if (registro.id != null) {
                                  controller.deletePontoRecord(context, registro.id!, controller.selectedDay!);
                                }
                              },
                              onEdit: () {
                                controller.showPontoRegisterOptions(context, registro.data, registroParaEditar: registro);
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}