import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE news (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      image_path TEXT,
      timestamp TEXT NOT NULL
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        image_path TEXT,
        timestamp TEXT NOT NULL
      )
      ''');
    }
  }

  // Вставка новости
  Future<void> insertNews(String title, String content) async {
    final db = await instance.database;
    await db.insert('news', {
      'title': title,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Получение всех новостей
  Future<List<Map<String, dynamic>>> getNews() async {
    final db = await instance.database;
    return await db.query('news', orderBy: 'timestamp DESC');
  }

  // Вставка события с изображением
  Future<void> insertEvent(String title, String content, String imagePath) async {
    final db = await instance.database;
    await db.insert('events', {
      'title': title,
      'content': content,
      'image_path': imagePath,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Получение всех событий
  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await instance.database;
    return await db.query('events', orderBy: 'timestamp DESC');
  }

  // Удаление всех данных (для тестирования)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('news');
    await db.delete('events');
  }
}
