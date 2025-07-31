import '../models/ponto_registro_model.dart';

/// Contrato (Interface) para o repositório de registros de ponto.
/// Define as operações que qualquer implementação de repositório de ponto deve ter.
abstract class IPontoRepository {
  Future<int> insertPonto(PontoRegistroModel ponto);
  Future<PontoRegistroModel?> getPontoById(int id);
  Future<List<PontoRegistroModel>> getAllPontos();
  Future<List<PontoRegistroModel>> getPontosByDate(DateTime date);
  Future<int> updatePonto(PontoRegistroModel ponto);
  Future<int> deletePonto(int id);
}