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
    final path = join(dbPath, 'ponto_eletronico.db'); // Nome do seu arquivo de banco de dados

    return await openDatabase(
      path,
      version: 2, // Versão do banco de dados
      onCreate: _onCreate, // Chamado na primeira vez que o banco é criado
      onUpgrade: _onUpgrade, // Chamado quando a versão do banco é atualizada
    );
  }

  /// Método chamado para criar as tabelas do banco de dados.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE pontos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        horaEntrada TEXT,
        horaSaida TEXT,
        horasTrabalhadas REAL,
        tipoAtividade TEXT NOT NULL
      )
      ''',
    );
  }

  /// Método chamado para realizar upgrades no banco de dados.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
    await db.execute("ALTER TABLE pontos ADD COLUMN horasTrabalhadas REAL;");
    }
  }

  /// Fecha a conexão com o banco de dados.
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null; // Reseta a instância para reabrir se necessário
  }
}