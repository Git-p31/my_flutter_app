import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final Logger _logger = Logger();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user'
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await _addColumnIfNotExists(db, 'users', 'email', 'TEXT NOT NULL DEFAULT ""');
      await _addColumnIfNotExists(db, 'users', 'role', 'TEXT NOT NULL DEFAULT "user"');
    }
  }

  Future<void> _addColumnIfNotExists(Database db, String tableName, String columnName, String columnType) async {
    final result = await db.rawQuery("PRAGMA table_info($tableName)");
    final columnExists = result.any((element) => element['name'] == columnName);
    if (!columnExists) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType');
    }
  }

  // ------------------- Методы для новостей -------------------

  Future<void> insertNews(String title, String content) async {
    try {
      final db = await instance.database;
      await db.insert('news', {
        'title': title,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.e('Error inserting news', error: e);
    }
  }

  Future<List<Map<String, dynamic>>> getNews() async {
    final db = await instance.database;
    return await db.query('news', orderBy: 'timestamp DESC');
  }

  Future<void> deleteNewsById(int id) async {
    final db = await instance.database;
    await db.delete('news', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------- Методы для событий -------------------

  Future<void> insertEvent(String title, String content, String imagePath) async {
    try {
      final db = await instance.database;
      await db.insert('events', {
        'title': title,
        'content': content,
        'image_path': imagePath,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.e('Error inserting event', error: e);
    }
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await instance.database;
    return await db.query('events', orderBy: 'timestamp DESC');
  }

  Future<void> deleteEventById(int id) async {
    final db = await instance.database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------- Методы для пользователей -------------------

  Future<void> registerUser(String username, String email, String password, {String role = 'user'}) async {
    try {
      final db = await instance.database;
      final hashedPassword = _hashPassword(password);
      await db.insert('users', {
        'username': username,
        'email': email,
        'password': hashedPassword,
        'role': role,
      });
    } catch (e) {
      _logger.e('Error registering user', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await instance.database;
    final hashedPassword = _hashPassword(password);
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );
    return result.isNotEmpty ? result.first : null;
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<void> deleteUserById(int id) async {
    final db = await instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------- Вспомогательные методы -------------------

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('news');
    await db.delete('events');
    await db.delete('users');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
