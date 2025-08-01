import 'package:sqflite/sqflite.dart';
import '../contracts/ponto_repository_contract.dart';
import '../helpers/db_helper.dart';
import '../models/ponto_registro_model.dart';

class PontoRepositoryImpl implements IPontoRepository {
  static const String _tableName = 'pontos';

  Future<Database> get _database async => DBHelper().database;

  @override
  Future<int> insertPonto(PontoRegistroModel ponto) async {
    final db = await _database;

    try {
      return await db.insert(
        _tableName,
        ponto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      print('Erro ao inserir ponto: $e');
      throw Exception('Falha ao inserir registro de ponto.');
    }
  }

  @override
  Future<PontoRegistroModel?> getPontoById(int id) async {
    final db = await _database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return PontoRegistroModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Erro ao obter ponto por ID: $e');
      throw Exception('Falha ao buscar registro de ponto por ID.');
    }
  }

  @override
  Future<List<PontoRegistroModel>> getPontosByDate(DateTime date) async {
    final db = await _database;

    try {
      final startOfDay =
          DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
      final endOfNextDay =
          DateTime(
            date.year,
            date.month,
            date.day,
          ).add(const Duration(days: 1)).millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'data >= ? AND data < ?',
        whereArgs: [startOfDay, endOfNextDay],
        orderBy: 'data ASC',
      );
      return List.generate(maps.length, (i) {
        return PontoRegistroModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Erro ao obter pontos por data: $e');
      throw Exception('Falha ao buscar registros de ponto por data.');
    }
  }

  @override
  Future<List<PontoRegistroModel>> getAllPontos() async {
    final db = await _database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'data DESC',
      );
      return List.generate(maps.length, (i) {
        return PontoRegistroModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Erro ao obter todos os pontos: $e');
      throw Exception('Falha ao buscar todos os registros de ponto.');
    }
  }

  @override
  Future<int> updatePonto(PontoRegistroModel ponto) async {
    final db = await _database;

    try {
      if (ponto.id == null) {
        throw ArgumentError(
          'O ID do registro de ponto não pode ser nulo para atualização.',
        );
      }
      return await db.update(
        _tableName,
        ponto.toMap(),
        where: 'id = ?',
        whereArgs: [ponto.id],
      );
    } catch (e) {
      print('Erro ao atualizar ponto: $e');
      throw Exception('Falha ao atualizar registro de ponto.');
    }
  }

  @override
  Future<int> deletePonto(int id) async {
    final db = await _database;

    try {
      return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Erro ao deletar ponto: $e');
      throw Exception('Falha ao deletar registro de ponto.');
    }
  }

  @override
  Future<int> bulkInsertPontos(List<PontoRegistroModel> pontos) async {
    final db = await _database;
    int insertedRows = 0;

    try {
      for (var ponto in pontos) {
        if (ponto.id != null) {
          throw ArgumentError(
            'Registros para bulkInsertPontos devem ter ID nulo. Use updatePonto para editar.',
          );
        }
      }

      await db.transaction((txn) async {
        final batch = txn.batch();
        for (var ponto in pontos) {
          batch.insert(
            _tableName,
            ponto.toMap(),
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
        }

        final results = await batch.commit();
        insertedRows = results.whereType<int>().length;
      });
      return insertedRows;
    } catch (e) {
      print('Erro em bulkInsertPontos: $e');
      if (e is ArgumentError) rethrow;
      throw Exception('Falha em inserir múltiplos registros de ponto.');
    }
  }
}
