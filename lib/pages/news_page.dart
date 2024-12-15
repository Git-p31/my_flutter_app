import 'package:flutter/material.dart';
import 'database_helper.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<Map<String, dynamic>> _newsList = [];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    final news = await DatabaseHelper.instance.getNews();
    setState(() {
      _newsList = news;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Новости', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.black,
      ),
      body: _newsList.isEmpty
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
                    title: Text(newsItem['title'], style: const TextStyle(color: Colors.blue)),
                    subtitle: Text(newsItem['content'], style: const TextStyle(color: Colors.white70)),
                    trailing: Text(
                      newsItem['timestamp'],
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
