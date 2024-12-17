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

  // ------------------- Инициализация базы данных -------------------

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
      version: 7, // Увеличение версии базы данных
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    _logger.i('Creating database with version $version');
    try {
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
      _logger.i('Tables created successfully');
    } catch (e) {
      _logger.e('Error creating database', error: e);
      rethrow;
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from version $oldVersion to $newVersion');
    try {
      if (oldVersion < 7) {
        await db.execute('DROP TABLE IF EXISTS news');
        await db.execute('DROP TABLE IF EXISTS events');
        await db.execute('DROP TABLE IF EXISTS users');
        await _createDB(db, newVersion);
      }
    } catch (e) {
      _logger.e('Error upgrading database', error: e);
      rethrow;
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
      _logger.i('News inserted successfully');
    } catch (e) {
      _logger.e('Error inserting news', error: e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getNews() async {
    final db = await instance.database;
    try {
      return await db.query('news', orderBy: 'timestamp DESC');
    } catch (e) {
      _logger.e('Error fetching news', error: e);
      rethrow;
    }
  }

  Future<void> deleteNewsById(int id) async {
    try {
      final db = await instance.database;
      await db.delete('news', where: 'id = ?', whereArgs: [id]);
      _logger.i('News with ID $id deleted');
    } catch (e) {
      _logger.e('Error deleting news', error: e);
      rethrow;
    }
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
      _logger.i('Event inserted successfully');
    } catch (e) {
      _logger.e('Error inserting event', error: e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await instance.database;
    try {
      return await db.query('events', orderBy: 'timestamp DESC');
    } catch (e) {
      _logger.e('Error fetching events', error: e);
      rethrow;
    }
  }

  Future<void> deleteEventById(int id) async {
    try {
      final db = await instance.database;
      await db.delete('events', where: 'id = ?', whereArgs: [id]);
      _logger.i('Event with ID $id deleted');
    } catch (e) {
      _logger.e('Error deleting event', error: e);
      rethrow;
    }
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
      _logger.i('User registered successfully');
    } catch (e) {
      _logger.e('Error registering user', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await instance.database;
    final hashedPassword = _hashPassword(password);
    try {
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, hashedPassword],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      _logger.e('Error logging in user', error: e);
      rethrow;
    }
  }

  Future<void> updateUserRole(int userId, String newRole) async {
    try {
      final db = await instance.database;
      await db.update(
        'users',
        {'role': newRole},
        where: 'id = ?',
        whereArgs: [userId],
      );
      _logger.i('User with ID $userId role updated to $newRole');
    } catch (e) {
      _logger.e('Error updating user role', error: e);
      rethrow;
    }
  }

  Future<void> updateUserName(int userId, String newName) async {
    try {
      final db = await instance.database;
      await db.update(
        'users',
        {'username': newName},
        where: 'id = ?',
        whereArgs: [userId],
      );
      _logger.i('User with ID $userId name updated to $newName');
    } catch (e) {
      _logger.e('Error updating user name', error: e);
      rethrow;
    }
  }

  Future<void> deleteUserById(int id) async {
    try {
      final db = await instance.database;
      await db.delete('users', where: 'id = ?', whereArgs: [id]);
      _logger.i('User with ID $id deleted');
    } catch (e) {
      _logger.e('Error deleting user', error: e);
      rethrow;
    }
  }

  // ------------------- Вспомогательные методы -------------------

  Future<void> clearAllData() async {
    try {
      final db = await instance.database;
      await db.delete('news');
      await db.delete('events');
      await db.delete('users');
      _logger.i('All data cleared');
    } catch (e) {
      _logger.e('Error clearing all data', error: e);
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _logger.i('Database closed');
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<int?> getLastUserId() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT MAX(id) as lastId FROM users');
    return result.first['lastId'] as int?;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;
    try {
      return await db.query('users');
    } catch (e) {
      _logger.e('Error fetching users', error: e);
      rethrow;
    }
  }
}
