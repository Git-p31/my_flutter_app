import 'package:flutter/material.dart';
import 'dart:io';
import '../database_helper.dart';


class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Map<String, dynamic>> _eventsList = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await DatabaseHelper.instance.getEvents();
    setState(() {
      _eventsList = events;
    });
  }

  Future<void> _deleteEvent(int id) async {
    await DatabaseHelper.instance.deleteEventById(id);
    _loadEvents(); // Перезагружаем список после удаления
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('События')),
      body: _eventsList.isEmpty
          ? const Center(child: Text('Нет доступных событий'))
          : ListView.builder(
              itemCount: _eventsList.length,
              itemBuilder: (context, index) {
                final event = _eventsList[index];
                return Card(
                  child: ListTile(
                    title: Text(event['title']),
                    subtitle: Text(event['content']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (event['image_path'] != null && event['image_path'].isNotEmpty)
                          Image.file(File(event['image_path']), width: 50, height: 50, fit: BoxFit.cover),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(event['id']),
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
