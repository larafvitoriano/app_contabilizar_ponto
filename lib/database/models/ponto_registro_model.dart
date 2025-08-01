import 'package:app_contabilizar_ponto/database/models/tipo_atividade_enum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PontoRegistroModel {
  int? id;
  final DateTime data;
  final double horasTrabalhadas;
  final TipoAtividade tipoAtividade;

  PontoRegistroModel({
    this.id,
    required DateTime data,
    required this.horasTrabalhadas,
    required this.tipoAtividade,
  }) : assert(
  horasTrabalhadas >= 0, // Garante que horasTrabalhadas não é negativo
  'Horas trabalhadas deve ser um valor positivo ou zero.',
  ),
  // Normaliza a data para apenas ano, mês e dia
        this.data = DateTime(data.year, data.month, data.day);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data.millisecondsSinceEpoch, // Salva a data como inteiro (timestamp)
      'horasTrabalhadas': horasTrabalhadas,
      'tipoAtividade': tipoAtividade.name,
    };
  }

  factory PontoRegistroModel.fromMap(Map<String, dynamic> map) {
    return PontoRegistroModel(

      // Para 'id': Tenta parsear para int. Se for null ou não for int/string convertível, retorna null.
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,

      // Para 'data': Tenta parsear para int. Se for null ou não for int/string convertível, retorna 0 (ou outro default seguro).
      // A partir de millisecondsSinceEpoch cria o DateTime.
      data: DateTime.fromMillisecondsSinceEpoch(
        map['data'] != null ? int.tryParse(map['data'].toString()) ?? 0 : 0,
      ),

      // Para 'horasTrabalhadas': Assume que pode vir como int ou double do banco, converte para double.
      horasTrabalhadas: (map['horasTrabalhadas'] as num).toDouble(),

      // Para 'tipoAtividade': Busca pelo nome. Adiciona um fallback robusto.

      tipoAtividade: TipoAtividade.values.firstWhere(
            (e) => e.name == map['tipoAtividade'],
        orElse: () => TipoAtividade.presencial, //
      ),
    );
  }

  PontoRegistroModel copyWith({
    int? id,
    DateTime? data,
    double? horasTrabalhadas,
    TipoAtividade? tipoAtividade,
  }) {
    return PontoRegistroModel(
      id: id ?? this.id,
      data: data ?? this.data,
      horasTrabalhadas: horasTrabalhadas ?? this.horasTrabalhadas,
      tipoAtividade: tipoAtividade ?? this.tipoAtividade,
    );
  }

  String toDisplayString(BuildContext context) {
    final int totalMinutes = (horasTrabalhadas * 60).round();
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    final String formattedTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    return 'Data: ${DateFormat.yMd('pt_BR').format(data)} - Atividade: ${tipoAtividade.toDisplayString()} - Horas: $formattedTime';
  }
}