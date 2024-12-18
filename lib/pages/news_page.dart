import 'package:flutter/material.dart';
import '../database_helper.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<Map<String, dynamic>> _newsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  // Загрузка новостей из Firestore
  Future<void> _loadNews() async {
    try {
      final news = await DatabaseHelper.instance.getNews();
      setState(() {
        _newsList = news;
        _isLoading = false;
      });
    } catch (e) {
      _showMessage('Ошибка загрузки новостей: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Удаление новости по ID документа Firestore
  Future<void> _deleteNews(String docId) async {
    try {
      await DatabaseHelper.instance.deleteNewsById(docId);
      _showMessage('Новость успешно удалена');
      _loadNews(); // Перезагрузка списка после удаления
    } catch (e) {
      _showMessage('Ошибка удаления новости: $e');
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
        title: const Text('Новости', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _newsList.isEmpty
              ? const Center(
                  child: Text('Нет доступных новостей', style: TextStyle(color: Colors.white)),
                )
              : ListView.builder(
                  itemCount: _newsList.length,
                  itemBuilder: (context, index) {
                    final newsItem = _newsList[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(newsItem['title'] ?? 'Нет заголовка',
                            style: const TextStyle(color: Colors.blue)),
                        subtitle: Text(newsItem['content'] ?? 'Нет содержания',
                            style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNews(newsItem['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
