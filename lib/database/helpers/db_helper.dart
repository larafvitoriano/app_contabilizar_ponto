import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper para gerenciar a conexão e operações básicas com o banco de dados SQLite.
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  /// Retorna a instância do banco de dados, inicializando-a se necessário.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Inicializa o banco de dados.
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(
      dbPath,
      'ponto_eletronico.db',
    );

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Método chamado para criar as tabelas do banco de dados.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pontos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        horasTrabalhadas REAL NOT NULL,
        tipoAtividade TEXT NOT NULL
      )
      ''');
  }

  /// Método chamado para realizar upgrades no banco de dados.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute("DROP TABLE IF EXISTS pontos");
      await _onCreate(db, newVersion);
    }
    // Para migrações futuras (ex: de v3 para v4):
    // if (oldVersion < 4) {
    //   await db.execute("ALTER TABLE pontos ADD COLUMN novaColuna TEXT");
    // }
  }

  /// Fecha a conexão com o banco de dados.
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  /// Opcional: Deleta o banco de dados. Útil para testes ou redefinições.
  Future<void> deleteDB() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ponto_eletronico.db');
    await deleteDatabase(path);
    _database = null;
  }
}
