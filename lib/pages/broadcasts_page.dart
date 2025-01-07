import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BroadcastsPage extends StatefulWidget {
  const BroadcastsPage({super.key});

  @override
  State<BroadcastsPage> createState() => _BroadcastsPageState();
}

class _BroadcastsPageState extends State<BroadcastsPage> {
  final String apiKey = 'AIzaSyC7SgfsXWy-MGe78rrD_40xk9d2sIKg8Fs';
  final List<Map<String, String>> channels = [
    {'id': 'UCWLxarOxx4Aeh959lrV31Lg', 'name': 'Kemo'},
    {'id': 'UCELCPjx3rq0d-G6WfhjwXyA', 'name': 'ShomerTV'},
  ];

  late Future<Map<String, List<dynamic>>> _broadcastsFuture;

  @override
  void initState() {
    super.initState();
    _broadcastsFuture = fetchBroadcasts();
  }

  Future<Map<String, List<dynamic>>> fetchBroadcasts() async {
    Map<String, List<dynamic>> results = {};

    for (var channel in channels) {
      final channelId = channel['id']!;
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&eventType=live&key=$apiKey',
      );

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          results[channel['name']!] = data['items'];
        } else {
          debugPrint('Ошибка при загрузке данных для канала $channelId: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Ошибка сети: $e');
      }
    }
    return results;
  }

  void _launchVideo(String videoId) async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Трансляции'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _broadcastsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка загрузки данных: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            final broadcastsByChannel = snapshot.data ?? {};

            if (broadcastsByChannel.isEmpty) {
              return const Center(
                child: Text('Нет доступных трансляций', style: TextStyle(fontSize: 18)),
              );
            }

            return ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channelName = channels[index]['name']!;
                final broadcasts = broadcastsByChannel[channelName] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurpleAccent, Colors.blueAccent],
                        ),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Канал: $channelName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    broadcasts.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'На данный момент на этом канале нет активных трансляций.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : Column(
                            children: broadcasts.map((broadcast) {
                              final title = broadcast['snippet']['title'];
                              final thumbnailUrl = broadcast['snippet']['thumbnails']['high']['url'];
                              final videoId = broadcast['id']['videoId'];

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(10.0),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      thumbnailUrl,
                                      width: 100,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return const SizedBox(
                                          width: 100,
                                          height: 60,
                                          child: Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.deepPurpleAccent,
                                    size: 30,
                                  ),
                                  onTap: () => _launchVideo(videoId),
                                ),
                              );
                            }).toList(),
                          ),
                    const Divider(height: 2, color: Colors.grey),
                  ],
                );
              },
            );
          }
        },
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
