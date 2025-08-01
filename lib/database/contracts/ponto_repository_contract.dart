import '../models/ponto_registro_model.dart';

abstract class IPontoRepository {

  /// Insere um novo registro de ponto no repositório.
  Future<int> insertPonto(PontoRegistroModel ponto);

  /// Busca um registro de ponto pelo seu ID único.
  Future<PontoRegistroModel?> getPontoById(int id);

  /// Retorna todos os registros de ponto presentes no repositório.
  Future<List<PontoRegistroModel>> getAllPontos();

  /// Busca registros de ponto para uma data específica.
  Future<List<PontoRegistroModel>> getPontosByDate(DateTime date);

  /// Atualiza um registro de ponto existente no repositório.
  Future<int> updatePonto(PontoRegistroModel ponto);

  /// Exclui um registro de ponto pelo seu ID único.
  Future<int> deletePonto(int id);

  /// Insere múltiplos registros de ponto.
  Future<int> bulkInsertPontos(List<PontoRegistroModel> pontos);
}