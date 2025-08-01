import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../database/contracts/ponto_repository_contract.dart';
import '../database/models/ponto_registro_model.dart';
import '../database/models/tipo_atividade_enum.dart';

class _TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final String text = newValue.text;
    final String cleanText = text.replaceAll(RegExp(r'[^\d]'), '');

    String formattedText = '';
    int selectionIndex = newValue.selection.end;

    if (cleanText.length >= 2) {
      formattedText += cleanText.substring(0, 2);
      if (cleanText.length > 2) {
        formattedText += ':';
        if (selectionIndex == 2 && oldValue.text.length == 2) {
          selectionIndex++;
        }
        formattedText += cleanText.substring(2);
      }
    } else {
      formattedText = cleanText;
    }

    if (formattedText.length > 5) {
      formattedText = formattedText.substring(0, 5);
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class PontoRegistroDialog extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final PontoRegistroModel? registroParaEditar;
  final IPontoRepository pontoRepository;
  final int totalBusinessDays;

  const PontoRegistroDialog({
    super.key,
    required this.startDate,
    required this.endDate,
    this.registroParaEditar,
    required this.pontoRepository,
    required this.totalBusinessDays,
  });

  @override
  State<PontoRegistroDialog> createState() => _PontoRegistroDialogState();
}

class _PontoRegistroDialogState extends State<PontoRegistroDialog> {
  double? _horasTrabalhadas;
  TipoAtividade? _tipoAtividadeSelecionada;

  final TextEditingController _horasTrabalhadasController =
  TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.registroParaEditar != null) {
      _horasTrabalhadas = widget.registroParaEditar!.horasTrabalhadas;
      _tipoAtividadeSelecionada = widget.registroParaEditar!.tipoAtividade;

      if (_horasTrabalhadas != null) {
        final int totalMinutes = (_horasTrabalhadas! * 60).round();
        final int hours = totalMinutes ~/ 60;
        final int minutes = totalMinutes % 60;
        _horasTrabalhadasController.text =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      }
    } else {
      _horasTrabalhadas = 6.0;
      _horasTrabalhadasController.text = '06:00';
      _tipoAtividadeSelecionada = TipoAtividade.presencial;
    }
  }

  @override
  void dispose() {
    _horasTrabalhadasController.dispose();
    super.dispose();
  }

  double? _parseHoursFromHHMM(String hhMm) {
    if (hhMm.isEmpty) return null;

    final parts = hhMm.split(':');
    if (parts.length != 2) return null;

    final int? hours = int.tryParse(parts[0]);
    final int? minutes = int.tryParse(parts[1]);

    if (hours == null || minutes == null || minutes >= 60) {
      return null;
    }

    return hours + (minutes / 60.0);
  }

  @override
  Widget build(BuildContext context) {
    String titleText;
    if (widget.startDate == widget.endDate) {
      titleText = 'Registrar Ponto - ${DateFormat.yMd('pt_BR').format(widget.startDate)}';
    } else {
      titleText = 'Registrar Ponto: ${DateFormat.yMd('pt_BR').format(widget.startDate)} - ${DateFormat.yMd('pt_BR').format(widget.endDate)}';
    }

    return AlertDialog(
      title: Text(titleText),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.startDate != widget.endDate)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Período selecionado: ${widget.totalBusinessDays} dias úteis',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                  ),
                ),
              const Text(
                'Tipo de Atividade:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...TipoAtividade.values.map((TipoAtividade tipo) {
                return RadioListTile<TipoAtividade>(
                  title: Text(tipo.toDisplayString()),
                  value: tipo,
                  groupValue: _tipoAtividadeSelecionada,
                  onChanged: (TipoAtividade? newValue) {
                    setState(() {
                      _tipoAtividadeSelecionada = newValue;
                    });
                  },
                );
              }).toList(),
              const Divider(height: 20, thickness: 1),

              TextFormField(
                controller: _horasTrabalhadasController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}:?\d{0,2}$')),
                  _TimeTextInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Horas Trabalhadas (Ex: 08:30)',
                  hintText: 'HH:MM',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira as horas trabalhadas.';
                  }
                  final parsedHours = _parseHoursFromHHMM(value);
                  if (parsedHours == null) {
                    return 'Formato inválido.';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _horasTrabalhadas = _parseHoursFromHHMM(value);
                  });
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, preencha todos os campos corretamente.'),
                ),
              );
              return;
            }

            if (_tipoAtividadeSelecionada == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, selecione o tipo de atividade.'),
                ),
              );
              return;
            }

            String successMessage = '';
            try {
              if (widget.startDate == widget.endDate) {
                final ponto = PontoRegistroModel(
                  id: widget.registroParaEditar?.id,
                  data: widget.startDate,
                  horasTrabalhadas: _horasTrabalhadas!,
                  tipoAtividade: _tipoAtividadeSelecionada!,
                );

                if (widget.registroParaEditar?.id != null) {
                  await widget.pontoRepository.updatePonto(ponto);
                  successMessage = 'Registro de ponto atualizado com sucesso!';
                } else {
                  await widget.pontoRepository.insertPonto(ponto);
                  successMessage = 'Registro de ponto salvo com sucesso!';
                }
              } else {
                List<PontoRegistroModel> pontosToInsert = [];
                for (DateTime date = widget.startDate;
                date.isBefore(widget.endDate.add(const Duration(days: 1)));
                date = date.add(const Duration(days: 1))) {
                  if (date.weekday >= DateTime.monday && date.weekday <= DateTime.friday) {
                    pontosToInsert.add(PontoRegistroModel(
                      id: null,
                      data: date,
                      horasTrabalhadas: _horasTrabalhadas!,
                      tipoAtividade: _tipoAtividadeSelecionada!,
                    ));
                  }
                }

                if (pontosToInsert.isNotEmpty) {
                  await widget.pontoRepository.bulkInsertPontos(pontosToInsert);
                  successMessage = 'Registros de ponto para os dias úteis do período salvos com sucesso!';
                } else {
                  successMessage = 'Nenhum dia útil encontrado no período selecionado para registrar.';
                }
              }

              Navigator.of(context).pop(successMessage);
            } catch (e) {
              print('Erro ao salvar registro no diálogo: $e');
              Navigator.of(context).pop('Erro ao salvar registro: ${e.toString().split(':')[0]}');
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}