import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  DatabaseHelper._init();

  // ------------------- Методы для новостей -------------------

  // Добавление новости
  Future<void> insertNews(String title, String content) async {
    try {
      await _firestore.collection('news').add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _logger.i('News inserted successfully');
    } catch (e) {
      _logger.e('Error inserting news', error: e);
      rethrow;
    }
  }

  // Получение всех новостей
  Future<List<Map<String, dynamic>>> getNews() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('news')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Нет заголовка',
          'content': data['content'] ?? 'Нет содержания',
          'timestamp': data['timestamp']?.toDate().toString() ?? '',
        };
      }).toList();
    } catch (e) {
      _logger.e('Error fetching news', error: e);
      rethrow;
    }
  }

  // Удаление новости по ID документа
  Future<void> deleteNewsById(String docId) async {
    try {
      await _firestore.collection('news').doc(docId).delete();
      _logger.i('News with ID $docId deleted');
    } catch (e) {
      _logger.e('Error deleting news', error: e);
      rethrow;
    }
  }

  // ------------------- Методы для событий -------------------

  // Добавление события
  Future<void> insertEvent(String title, String content, String imagePath) async {
    try {
      await _firestore.collection('events').add({
        'title': title,
        'content': content,
        'image_path': imagePath,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _logger.i('Event inserted successfully');
    } catch (e) {
      _logger.e('Error inserting event', error: e);
      rethrow;
    }
  }

  // Получение всех событий
  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('events')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Нет заголовка',
          'content': data['content'] ?? 'Нет описания',
          'image_path': data['image_path'] ?? '',
          'timestamp': data['timestamp']?.toDate().toString() ?? '',
        };
      }).toList();
    } catch (e) {
      _logger.e('Error fetching events', error: e);
      rethrow;
    }
  }

  // Удаление события по ID документа
  Future<void> deleteEventById(String docId) async {
    try {
      await _firestore.collection('events').doc(docId).delete();
      _logger.i('Event with ID $docId deleted');
    } catch (e) {
      _logger.e('Error deleting event', error: e);
      rethrow;
    }
  }

  // ------------------- Методы для пользователей -------------------

  // Регистрация пользователя
  Future<void> registerUser(String username, String email, String password, {String role = 'user'}) async {
    try {
      final hashedPassword = _hashPassword(password);
      await _firestore.collection('users').add({
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

  // Вход пользователя
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final hashedPassword = _hashPassword(password);
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: hashedPassword)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return {
          'id': querySnapshot.docs.first.id,
          ...querySnapshot.docs.first.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      _logger.e('Error logging in user', error: e);
      rethrow;
    }
  }

  // Получение всех пользователей
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'username': data['username'] ?? 'Без имени',
          'email': data['email'] ?? 'Без email',
          'role': data['role'] ?? 'user',
        };
      }).toList();
    } catch (e) {
      _logger.e('Error fetching users', error: e);
      rethrow;
    }
  }

  // Удаление пользователя по ID
  Future<void> deleteUserById(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      _logger.i('User with ID $userId deleted');
    } catch (e) {
      _logger.e('Error deleting user', error: e);
      rethrow;
    }
  }

  // ------------------- Вспомогательные методы -------------------

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
