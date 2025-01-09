import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  DatabaseHelper._init();

  // ------------------- Инициализация локальных уведомлений -------------------
  Future<void> initNotifications() async {
    tz_data.initializeTimeZones(); // Инициализация часовых поясов
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // ------------------- Методы для новостей -------------------

  // Добавление новости
  Future<void> insertNews(String title, String content) async {
    try {
      // Добавление новости в Firestore
      await _firestore.collection('news').add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _logger.i('Новость успешно добавлена');

      // Отправка уведомления через минуту
      _sendNotification("Появились новые новости", "Загляните, чтобы не пропустить!");
    } catch (e) {
      _logger.e('Ошибка добавления новости: $e');
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
          'title': data['title'] ?? 'Без заголовка',
          'content': data['content'] ?? 'Без содержания',
          'timestamp': data['timestamp']?.toDate().toString() ?? '',
        };
      }).toList();
    } catch (e) {
      _logger.e('Ошибка получения новостей: $e');
      rethrow;
    }
  }

  // Удаление новости по ID документа
  Future<void> deleteNewsById(String docId) async {
    try {
      await _firestore.collection('news').doc(docId).delete();
      _logger.i('Новость с ID $docId успешно удалена');
    } catch (e) {
      _logger.e('Ошибка удаления новости: $e');
      rethrow;
    }
  }

  // ------------------- Методы для событий -------------------

  // Добавление события
  Future<void> insertEvent(String title, String content, String imageBase64) async {
    try {
      // Добавление события в Firestore
      await _firestore.collection('events').add({
        'title': title,
        'content': content,
        'image_base64': imageBase64, // Сохраняем строку Base64
        'timestamp': FieldValue.serverTimestamp(),
      });

      _logger.i('Событие успешно добавлено');

      // Отправка уведомления через минуту
      _sendNotification("Появилось новое событие", "Загляните, чтобы не пропустить!");
    } catch (e) {
      _logger.e('Ошибка добавления события: $e');
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
          'title': data['title'] ?? 'Без заголовка',
          'content': data['content'] ?? 'Без описания',
          'image_base64': data['image_base64'] ?? '',
          'timestamp': data['timestamp']?.toDate().toString() ?? '',
        };
      }).toList();
    } catch (e) {
      _logger.e('Ошибка получения событий: $e');
      rethrow;
    }
  }

  // Удаление события по ID документа
  Future<void> deleteEventById(String docId) async {
    try {
      await _firestore.collection('events').doc(docId).delete();
      _logger.i('Событие с ID $docId успешно удалено');
    } catch (e) {
      _logger.e('Ошибка удаления события: $e');
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
      _logger.i('Пользователь успешно зарегистрирован');
    } catch (e) {
      _logger.e('Ошибка регистрации пользователя: $e');
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
      _logger.e('Ошибка авторизации пользователя: $e');
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
      _logger.e('Ошибка получения пользователей: $e');
      rethrow;
    }
  }

  // Удаление пользователя по ID
  Future<void> deleteUserById(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      _logger.i('Пользователь с ID $userId успешно удалён');
    } catch (e) {
      _logger.e('Ошибка удаления пользователя: $e');
      rethrow;
    }
  }

  // Обновление роли пользователя
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });
      _logger.i('Роль пользователя с ID $userId успешно обновлена на $newRole');
    } catch (e) {
      _logger.e('Ошибка обновления роли пользователя: $e');
      rethrow;
    }
  }

  // ------------------- Логика уведомлений -------------------

  // Отправка уведомления через минуту
  Future<void> _sendNotification(String title, String message) async {
    var scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: 1)); // Создаем TZDateTime
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title, // Динамическое название
      message, // Динамическое сообщение
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Новый обязательный параметр
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ------------------- Вспомогательные методы -------------------

  // Хеширование пароля
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
