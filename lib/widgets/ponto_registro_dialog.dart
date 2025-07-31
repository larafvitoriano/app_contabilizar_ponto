import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/contracts/ponto_repository_contract.dart';
import '../database/models/ponto_registro_model.dart';
import '../database/models/tipo_atividade_enum.dart';


class PontoRegistroDialog extends StatefulWidget {
  final DateTime selectedDay;
  final PontoRegistroModel? registroParaEditar;
  final IPontoRepository pontoRepository;

  const PontoRegistroDialog({
    super.key,
    required this.selectedDay,
    this.registroParaEditar,
    required this.pontoRepository,
  });

  @override
  State<PontoRegistroDialog> createState() => _PontoRegistroDialogState();
}

class _PontoRegistroDialogState extends State<PontoRegistroDialog> {
  TimeOfDay? _entrada;
  TimeOfDay? _saida;
  double? _horasTrabalhadas;
  TipoAtividade? _tipoAtividadeSelecionada;

  final TextEditingController _horasTrabalhadasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.registroParaEditar != null) {
      _entrada = widget.registroParaEditar!.horaEntrada;
      _saida = widget.registroParaEditar!.horaSaida;
      _horasTrabalhadas = widget.registroParaEditar!.horasTrabalhadas;
      _tipoAtividadeSelecionada = widget.registroParaEditar!.tipoAtividade;

      if (_horasTrabalhadas != null) {
        _horasTrabalhadasController.text = _horasTrabalhadas!.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _horasTrabalhadasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Registrar Ponto - ${DateFormat.yMd('pt_BR').format(widget.selectedDay)}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Registrar por Horas de Entrada/Saída', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('Hora de Entrada'),
              trailing: Text(_entrada?.format(context) ?? 'Selecionar'),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _entrada ?? TimeOfDay.now(),
                  builder: (context, child) {
                    return Localizations.override(context: context, locale: const Locale('pt', 'BR'), child: child);
                  },
                );
                if (pickedTime != null) {
                  setState(() { _entrada = pickedTime; });
                  _horasTrabalhadasController.clear();
                  _horasTrabalhadas = null;
                }
              },
            ),
            ListTile(
              title: const Text('Hora de Saída'),
              trailing: Text(_saida?.format(context) ?? 'Selecionar'),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _saida ?? _entrada ?? TimeOfDay.now(),
                  builder: (context, child) {
                    return Localizations.override(context: context, locale: const Locale('pt', 'BR'), child: child);
                  },
                );
                if (pickedTime != null) {
                  setState(() { _saida = pickedTime; });
                  _horasTrabalhadasController.clear();
                  _horasTrabalhadas = null;
                }
              },
            ),
            const Divider(),
            const Text('Registrar Quantidade de Horas', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _horasTrabalhadasController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Horas Trabalhadas',
                hintText: 'Digite a quantidade de horas',
              ),
              onChanged: (value) {
                setState(() {
                  _horasTrabalhadas = double.tryParse(value);
                  _entrada = null;
                  _saida = null;
                });
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<TipoAtividade>(
              value: _tipoAtividadeSelecionada,
              decoration: const InputDecoration(
                labelText: 'Tipo de Atividade',
                border: OutlineInputBorder(),
              ),
              items: TipoAtividade.values.map((TipoAtividade tipo) {
                return DropdownMenuItem<TipoAtividade>(
                  value: tipo,
                  child: Text(tipo.toDisplayString()),
                );
              }).toList(),
              onChanged: (TipoAtividade? newValue) {
                setState(() { _tipoAtividadeSelecionada = newValue; });
              },
              validator: (value) => value == null ? 'Selecione o tipo de atividade' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            if (_tipoAtividadeSelecionada == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor, selecione o tipo de atividade.')),
              );
              return;
            }

            if ((_entrada == null && _saida == null) && _horasTrabalhadas == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor, insira a hora de entrada/saída ou as horas trabalhadas.')),
              );
              return;
            }

            final normalizedDay = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
            String mensagemSucesso = '';

            try {
              final PontoRegistroModel ponto;
              if (widget.registroParaEditar != null && widget.registroParaEditar!.id != null) {
                ponto = PontoRegistroModel(
                  id: widget.registroParaEditar!.id,
                  data: normalizedDay,
                  horaEntrada: _entrada,
                  horaSaida: _saida,
                  horasTrabalhadas: _horasTrabalhadas,
                  tipoAtividade: _tipoAtividadeSelecionada!,
                );
                await widget.pontoRepository.updatePonto(ponto);
                mensagemSucesso = 'Registro de ponto atualizado com sucesso!';
              } else {
                ponto = PontoRegistroModel(
                  data: normalizedDay,
                  horaEntrada: _entrada,
                  horaSaida: _saida,
                  horasTrabalhadas: _horasTrabalhadas,
                  tipoAtividade: _tipoAtividadeSelecionada!,
                );
                await widget.pontoRepository.insertPonto(ponto);
                mensagemSucesso = 'Registro de ponto salvo com sucesso!';
              }

              Navigator.of(context).pop(mensagemSucesso); // Retorna a mensagem de sucesso
            } catch (e) {
              Navigator.of(context).pop('Erro ao salvar registro: $e'); // Retorna mensagem de erro
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}