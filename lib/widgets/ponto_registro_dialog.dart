import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/contracts/ponto_repository_contract.dart';
import '../database/models/ponto_registro_model.dart';
import '../database/models/tipo_atividade_enum.dart';

// Enum para o tipo de registro que o usuário deseja fazer
enum TipoRegistroOpcao { porHoras, porQuantidade }

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
  TipoRegistroOpcao?
  _tipoRegistroSelecionado; // Novo estado para controlar a opção de registro

  final TextEditingController _horasTrabalhadasController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche os campos se estiver editando um registro existente
    if (widget.registroParaEditar != null) {
      _entrada = widget.registroParaEditar!.horaEntrada;
      _saida = widget.registroParaEditar!.horaSaida;
      _horasTrabalhadas = widget.registroParaEditar!.horasTrabalhadas;
      _tipoAtividadeSelecionada = widget.registroParaEditar!.tipoAtividade;

      // Define o tipo de registro selecionado com base nos dados existentes
      if (_horasTrabalhadas != null) {
        _tipoRegistroSelecionado = TipoRegistroOpcao.porQuantidade;
        _horasTrabalhadasController.text = _horasTrabalhadas!.toStringAsFixed(
          2,
        );
      } else if (_entrada != null || _saida != null) {
        _tipoRegistroSelecionado = TipoRegistroOpcao.porHoras;
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
      title: Text(
        'Registrar Ponto - ${DateFormat.yMd('pt_BR').format(widget.selectedDay)}',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Seleção do Tipo de Atividade (Radio Buttons) ---
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

            // --- Seleção do Tipo de Registro (Radio Buttons) ---
            const Text(
              'Forma de Registro:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile<TipoRegistroOpcao>(
              title: const Text('Por Horas de Entrada/Saída'),
              value: TipoRegistroOpcao.porHoras,
              groupValue: _tipoRegistroSelecionado,
              onChanged: (TipoRegistroOpcao? newValue) {
                setState(() {
                  _tipoRegistroSelecionado = newValue;
                  // Limpa o outro campo ao trocar a opção
                  _horasTrabalhadasController.clear();
                  _horasTrabalhadas = null;
                });
              },
            ),
            RadioListTile<TipoRegistroOpcao>(
              title: const Text('Por Quantidade de Horas'),
              value: TipoRegistroOpcao.porQuantidade,
              groupValue: _tipoRegistroSelecionado,
              onChanged: (TipoRegistroOpcao? newValue) {
                setState(() {
                  _tipoRegistroSelecionado = newValue;
                  // Limpa os campos de entrada/saída ao trocar a opção
                  _entrada = null;
                  _saida = null;
                });
              },
            ),
            const Divider(height: 20, thickness: 1),

            // --- Campos Condicionais baseados na seleção ---
            if (_tipoRegistroSelecionado == TipoRegistroOpcao.porHoras)
              Column(
                children: [
                  ListTile(
                    title: const Text('Hora de Entrada'),
                    trailing: Text(_entrada?.format(context) ?? 'Selecionar'),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _entrada ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Localizations.override(
                            context: context,
                            locale: const Locale('pt', 'BR'),
                            child: child,
                          );
                        },
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _entrada = pickedTime;
                        });
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
                          return Localizations.override(
                            context: context,
                            locale: const Locale('pt', 'BR'),
                            child: child,
                          );
                        },
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _saida = pickedTime;
                        });
                      }
                    },
                  ),
                ],
              )
            else if (_tipoRegistroSelecionado ==
                TipoRegistroOpcao.porQuantidade)
              TextFormField(
                controller: _horasTrabalhadasController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Horas Trabalhadas (ex: 8.5)',
                  hintText: 'Digite a quantidade de horas',
                  border:
                      OutlineInputBorder(), // Adiciona borda para melhor visual
                ),
                onChanged: (value) {
                  setState(() {
                    _horasTrabalhadas = double.tryParse(value);
                  });
                },
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Selecione uma forma de registro acima.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16), // Espaçamento final
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
                const SnackBar(
                  content: Text('Por favor, selecione o tipo de atividade.'),
                ),
              );
              return;
            }

            if (_tipoRegistroSelecionado == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, selecione uma forma de registro.'),
                ),
              );
              return;
            }

            // Validações específicas para cada tipo de registro
            if (_tipoRegistroSelecionado == TipoRegistroOpcao.porHoras) {
              if (_entrada == null && _saida == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Por favor, insira a hora de entrada OU saída.',
                    ),
                  ),
                );
                return;
              }
            } else if (_tipoRegistroSelecionado ==
                TipoRegistroOpcao.porQuantidade) {
              if (_horasTrabalhadas == null || _horasTrabalhadas! <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Por favor, insira um valor válido para horas trabalhadas.',
                    ),
                  ),
                );
                return;
              }
            }

            final normalizedDay = DateTime(
              widget.selectedDay.year,
              widget.selectedDay.month,
              widget.selectedDay.day,
            );
            String mensagemSucesso = '';

            try {
              final PontoRegistroModel ponto;
              if (widget.registroParaEditar != null &&
                  widget.registroParaEditar!.id != null) {
                ponto = PontoRegistroModel(
                  id: widget.registroParaEditar!.id,
                  data: normalizedDay,
                  // Garante que apenas os campos relevantes ao tipo de registro selecionado sejam passados
                  horaEntrada:
                      _tipoRegistroSelecionado == TipoRegistroOpcao.porHoras
                          ? _entrada
                          : null,
                  horaSaida:
                      _tipoRegistroSelecionado == TipoRegistroOpcao.porHoras
                          ? _saida
                          : null,
                  horasTrabalhadas:
                      _tipoRegistroSelecionado ==
                              TipoRegistroOpcao.porQuantidade
                          ? _horasTrabalhadas
                          : null,
                  tipoAtividade: _tipoAtividadeSelecionada!,
                );
                await widget.pontoRepository.updatePonto(ponto);
                mensagemSucesso = 'Registro de ponto atualizado com sucesso!';
              } else {
                ponto = PontoRegistroModel(
                  data: normalizedDay,
                  // Garante que apenas os campos relevantes ao tipo de registro selecionado sejam passados
                  horaEntrada:
                      _tipoRegistroSelecionado == TipoRegistroOpcao.porHoras
                          ? _entrada
                          : null,
                  horaSaida:
                      _tipoRegistroSelecionado == TipoRegistroOpcao.porHoras
                          ? _saida
                          : null,
                  horasTrabalhadas:
                      _tipoRegistroSelecionado ==
                              TipoRegistroOpcao.porQuantidade
                          ? _horasTrabalhadas
                          : null,
                  tipoAtividade: _tipoAtividadeSelecionada!,
                );
                await widget.pontoRepository.insertPonto(ponto);
                mensagemSucesso = 'Registro de ponto salvo com sucesso!';
              }

              Navigator.of(context).pop(mensagemSucesso);
            } catch (e) {
              Navigator.of(context).pop('Erro ao salvar registro: $e');
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
