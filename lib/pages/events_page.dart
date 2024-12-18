import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../database_helper.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

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
                    final String imageUrl = event['image_path'] ?? '';
                    final String docId = event['id'] ?? '';

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        title: Text(title, style: const TextStyle(color: Colors.blue)),
                        subtitle: Text(content, style: const TextStyle(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (imageUrl.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error, color: Colors.red),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEvent(docId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
