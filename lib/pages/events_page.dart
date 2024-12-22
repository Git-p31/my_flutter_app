import 'package:flutter/material.dart';
import 'dart:convert'; // Для декодирования Base64
import '../database_helper.dart';

class EventsPage extends StatefulWidget {
  final String userRole; // Роль пользователя

  const EventsPage({super.key, required this.userRole});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Map<String, dynamic>> _eventsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Загрузка событий из Firestore
  Future<void> _loadEvents() async {
    try {
      final events = await DatabaseHelper.instance.getEvents();
      setState(() {
        _eventsList = events;
        _isLoading = false;
      });
    } catch (e) {
      _showMessage('Ошибка загрузки событий: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Удаление события по ID документа Firestore
  Future<void> _deleteEvent(String docId) async {
    try {
      await DatabaseHelper.instance.deleteEventById(docId);
      _showMessage('Событие успешно удалено');
      setState(() {
        _eventsList.removeWhere((event) => event['id'] == docId);
      });
    } catch (e) {
      _showMessage('Ошибка удаления события: $e');
    }
  }

  // Показ сообщения
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('События', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _eventsList.isEmpty
              ? const Center(
                  child: Text('Нет доступных событий', style: TextStyle(color: Colors.white)),
                )
              : ListView.builder(
                  itemCount: _eventsList.length,
                  itemBuilder: (context, index) {
                    final event = _eventsList[index];
                    final String title = event['title'] ?? 'Нет заголовка';
                    final String content = event['content'] ?? 'Нет описания';
                    final String imageBase64 = event['image_base64'] ?? ''; // Получаем Base64 строку
                    final String docId = event['id'] ?? '';

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageBase64.isNotEmpty)
                            Image.memory(
                              base64Decode(imageBase64), // Декодируем Base64 строку
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  content,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.userRole == 'admin')
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteEvent(docId),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
