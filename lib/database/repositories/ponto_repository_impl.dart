import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../contracts/ponto_repository_contract.dart';
import '../models/ponto_registro_model.dart';
import '../helpers/db_helper.dart';

/// Implementação do repositório de registros de ponto usando SQLite.
class PontoRepositoryImpl implements IPontoRepository {
  final DBHelper _dbHelper = DBHelper();

  @override
  Future<int> insertPonto(PontoRegistroModel ponto) async {
    final db = await _dbHelper.database;
    // Remove o ID para que o AUTOINCREMENT possa funcionar
    final data = ponto.toMap()..remove('id');
    return await db.insert('pontos', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<PontoRegistroModel?> getPontoById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pontos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PontoRegistroModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<PontoRegistroModel>> getAllPontos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pontos');
    return List.generate(maps.length, (i) {
      return PontoRegistroModel.fromMap(maps[i]);
    });
  }

  @override
  Future<List<PontoRegistroModel>> getPontosByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final List<Map<String, dynamic>> maps = await db.query(
      'pontos',
      where: 'data = ?',
      whereArgs: [dateString],
      orderBy: 'horaEntrada ASC',
    );
    return List.generate(maps.length, (i) {
      return PontoRegistroModel.fromMap(maps[i]);
    });
  }

  @override
  Future<int> updatePonto(PontoRegistroModel ponto) async {
    final db = await _dbHelper.database;
    if (ponto.id == null) {
      throw Exception("ID do registro de ponto não pode ser nulo para atualização.");
    }
    return await db.update(
      'pontos',
      ponto.toMap(),
      where: 'id = ?',
      whereArgs: [ponto.id],
    );
  }

  @override
  Future<int> deletePonto(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'pontos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}