/// Enum que representa o tipo de atividade para o registro de ponto.
enum TipoAtividade {
  presencial,
  aula,
}

/// Extensão para adicionar métodos úteis ao enum TipoAtividade.
extension TipoAtividadeExtension on TipoAtividade {
  /// Retorna uma string legível para o tipo de atividade.
  String toDisplayString() {
    switch (this) {
      case TipoAtividade.presencial:
        return 'Presencial';
      case TipoAtividade.aula:
        return 'Aula';
    }
  }
}