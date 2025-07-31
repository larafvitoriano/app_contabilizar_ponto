import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../database/contracts/ponto_repository_contract.dart';
import '../database/models/ponto_registro_model.dart';
import '../database/repositories/ponto_repository_impl.dart';
import '../widgets/ponto_registro_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final IPontoRepository _pontoRepository = PontoRepositoryImpl();
  List<PontoRegistroModel> _registrosDoDiaSelecionado = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _selectedDay = _focusedDay;
    _carregarRegistrosDoDia(_selectedDay!);
  }

  // O dispose() do TextEditingController agora está no PontoRegistroDialog

  Future<void> _carregarRegistrosDoDia(DateTime date) async {
    final registros = await _pontoRepository.getPontosByDate(date);
    setState(() {
      _registrosDoDiaSelecionado = registros;
    });
  }

  Future<void> _excluirRegistroPonto(int id, DateTime day) async {
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

  Future<void> _mostrarDialogoRegistroPonto(DateTime day) async {
    PontoRegistroModel? registroParaEditar;

    // Se já houver um registro para o dia, vamos passá-lo para edição.
    // Para simplificar, pegamos o primeiro. Em um caso real, você poderia ter múltiplos
    // ou permitir que o usuário escolha qual editar.
    final registrosExistente = await _pontoRepository.getPontosByDate(day);
    if (registrosExistente.isNotEmpty) {
      registroParaEditar = registrosExistente.first;
    }

    // Chama o novo widget de diálogo e espera um resultado
    final result = await showDialog<String?>( // Agora espera uma string (mensagem de sucesso/erro) ou null
      context: context,
      builder: (context) => PontoRegistroDialog(
        selectedDay: day,
        registroParaEditar: registroParaEditar,
        pontoRepository: _pontoRepository, // Passa o repositório
      ),
    );

    if (result != null) {
      // Se um resultado foi retornado (sucesso ou erro ao salvar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
      // Recarrega os registros do dia, independentemente do sucesso ou falha,
      // para refletir as possíveis mudanças.
      _carregarRegistrosDoDia(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004D40);
    const Color secondaryColor = Color(0xFF568F80);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendário',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 420.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
              child: Card(
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
                      CalendarFormat.month: 'Mês',
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
                        _carregarRegistrosDoDia(selectedDay);
                      }
                    },
                    onDayLongPressed: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          _carregarRegistrosDoDia(selectedDay);
                        }
                        _mostrarDialogoRegistroPonto(selectedDay);
                        },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      _selectedDay = _focusedDay;
                      _carregarRegistrosDoDia(_focusedDay);
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      formatButtonTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
                      titleTextStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.green),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.green),
                    ),
                    calendarStyle: CalendarStyle(
                      weekendTextStyle: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      todayDecoration: BoxDecoration(
                        color: secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
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
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        if (_registrosDoDiaSelecionado.any((p) => DateTime(p.data.year, p.data.month, p.data.day) == normalizedDay)) {
                          return Positioned(
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
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Selecione um dia para ver os registros de ponto.'))
                : FutureBuilder<List<PontoRegistroModel>>(
              future: _pontoRepository.getPontosByDate(_selectedDay!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar registros: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum registro de ponto para ${DateFormat.yMd('pt_BR').format(_selectedDay!)}.',
                    ),
                  );
                } else {
                  final registros = snapshot.data!;
                  return ListView.builder(
                    itemCount: registros.length,
                    itemBuilder: (context, index) {
                      final registro = registros[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(registro.toDisplayString(context)),
                              ),
                              if (registro.id != null)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _excluirRegistroPonto(registro.id!, _selectedDay!),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}