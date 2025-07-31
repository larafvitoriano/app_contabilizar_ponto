import 'package:app_contabilizar_ponto/database/models/tipo_atividade_enum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Modelo de dados para um registro de ponto eletrônico.
class PontoRegistroModel {
  int? id; // ID único do registro (útil para banco de dados)
  final DateTime data; // A data do registro (sem considerar a hora)
  final TimeOfDay? horaEntrada; // Agora opcional
  final TimeOfDay? horaSaida;   // Agora opcional
  final double? horasTrabalhadas; // Novo campo para horas trabalhadas (opcional)
  final TipoAtividade tipoAtividade; // Se é presencial ou aula

  PontoRegistroModel({
    this.id,
    required this.data,
    this.horaEntrada,
    this.horaSaida,
    this.horasTrabalhadas, // Inclua no construtor
    required this.tipoAtividade,
  }) : assert(
  (horaEntrada != null && horaSaida != null) || horasTrabalhadas != null,
  'Deve fornecer hora de entrada/saída OU horas trabalhadas.',
  ); // Adiciona uma asserção para garantir uma das opções

  /// Converte um objeto PontoRegistroModel em um Map para armazenamento (ex: banco de dados).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': DateFormat('yyyy-MM-dd').format(data), // Armazenar data como string
      'horaEntrada': horaEntrada != null ? '${horaEntrada!.hour}:${horaEntrada!.minute}' : null, // Pode ser nulo
      'horaSaida': horaSaida != null ? '${horaSaida!.hour}:${horaSaida!.minute}' : null,       // Pode ser nulo
      'horasTrabalhadas': horasTrabalhadas, // Armazenar o double
      'tipoAtividade': tipoAtividade.name, // Armazenar o nome do enum como string
    };
  }

  /// Cria um objeto PontoRegistroModel a partir de um Map (ex: lido do banco de dados).
  factory PontoRegistroModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parseTime(String? timeString) { // Retorna TimeOfDay?
      if (timeString == null) return null;
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return PontoRegistroModel(
      id: map['id'],
      data: DateTime.parse(map['data']),
      horaEntrada: parseTime(map['horaEntrada']),
      horaSaida: parseTime(map['horaSaida']),
      horasTrabalhadas: map['horasTrabalhadas'] as double?, // Cast para double?
      tipoAtividade: TipoAtividade.values.firstWhere(
            (e) => e.name == map['tipoAtividade'],
        orElse: () => TipoAtividade.presencial, // Valor padrão se não encontrar
      ),
    );
  }

  /// Retorna uma representação de string formatada para exibição.
  String toDisplayString(BuildContext context) {
    String formatTime(TimeOfDay time) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat.Hm(Localizations.localeOf(context).toString()).format(dt);
    }

    String horasInfo;
    if (horasTrabalhadas != null) {
      horasInfo = 'Horas Trabalhadas: ${horasTrabalhadas!.toStringAsFixed(2)}h';
    } else if (horaEntrada != null && horaSaida != null) {
      horasInfo = 'Entrada: ${formatTime(horaEntrada!)}\nSaída: ${formatTime(horaSaida!)}';
    } else if (horaEntrada != null) {
      horasInfo = 'Entrada: ${formatTime(horaEntrada!)}\nSaída: Em andamento';
    } else {
      horasInfo = 'Nenhuma hora registrada';
    }

    return 'Data: ${DateFormat.yMd('pt_BR').format(data)}\n'
        '$horasInfo\n'
        'Tipo: ${tipoAtividade.toDisplayString()}';
  }
}