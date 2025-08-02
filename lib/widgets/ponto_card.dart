import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/models/ponto_registro_model.dart';
import '../database/models/tipo_atividade_enum.dart';

class PontoRecordCard extends StatelessWidget {
  final PontoRegistroModel ponto;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PontoRecordCard({
    Key? key,
    required this.ponto,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  // Helper para obter um ícone baseado no tipo de atividade
  IconData _getActivityIcon(TipoAtividade tipo) {
    switch (tipo) {
      case TipoAtividade.presencial:
        return Icons.business; // Ícone de prédio/empresa
      case TipoAtividade.aula:
        return Icons.school;   // Ícone de escola/educação
      case TipoAtividade.feriado:
        return Icons.celebration; // Ícone genérico de trabalho
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalMinutes = (ponto.horasTrabalhadas * 60).round();
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    final String formattedTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    Color cardColor;
    Color textColor;
    Color iconColor;

    if (ponto.horasTrabalhadas >= 6) {
      textColor = Colors.green.shade800;
    } else if (ponto.horasTrabalhadas >= 0 && ponto.horasTrabalhadas <= 5) {
      textColor = Colors.red.shade800;
    } else {
      textColor = Colors.grey[800]!;
    }


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícone da atividade
            Icon(
              _getActivityIcon(ponto.tipoAtividade),
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
            const SizedBox(width: 16),

            // Detalhes do ponto (Data, Atividade, Horas)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(

                    DateFormat.yMd('pt_BR').format(ponto.data),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(

                    'Atividade: ${ponto.tipoAtividade.toDisplayString()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(

                    'Horas: $formattedTime',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            // Botões de ação
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
                onPressed: onEdit,
                tooltip: 'Editar registro',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Excluir registro',
              ),
          ],
        ),
      ),
    );
  }
}