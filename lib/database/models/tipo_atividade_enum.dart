enum TipoAtividade {
  presencial,
  aula,
  feriado
}

extension TipoAtividadeExtension on TipoAtividade {
  String toDisplayString() {
    switch (this) {
      case TipoAtividade.presencial:
        return 'Presencial';
      case TipoAtividade.aula:
        return 'Aula';
      case TipoAtividade.feriado:
        return 'Feriado';
    }
  }
}