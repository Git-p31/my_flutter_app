import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BroadcastsPage extends StatelessWidget {
  BroadcastsPage({super.key});

  final String apiKey = 'AIzaSyC7SgfsXWy-MGe78rrD_40xk9d2sIKg8Fs';
  final List<Map<String, String>> channels = [
    {'id': 'UCWLxarOxx4Aeh959lrV31Lg', 'name': 'Kemo'},
    {'id': 'UCELCPjx3rq0d-G6WfhjwXyA', 'name': 'ShomerTV'},
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Трансляции')),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: fetchBroadcasts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных'));
          } else {
            final broadcastsByChannel = snapshot.data ?? {};

            return ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channelName = channels[index]['name']!;
                final broadcasts = broadcastsByChannel[channelName] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Канал: $channelName',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    broadcasts.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'На данный момент на этом канале не идёт трансляция.',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          )
                        : Column(
                            children: broadcasts.map((broadcast) {
                              final title = broadcast['snippet']['title'];
                              final thumbnailUrl =
                                  broadcast['snippet']['thumbnails']['high']['url'];
                              final videoId = broadcast['id']['videoId'];

                              return ListTile(
                                leading: Image.network(
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
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                title: Text(title, style: const TextStyle(color: Colors.white)),
                                onTap: () => _launchVideo(videoId),
                              );
                            }).toList(),
                          ),
                    const Divider(color: Colors.white),
                  ],
                );
              },
            );
          }
        },
      ),
      backgroundColor: Colors.black,
    );
  }

  void _launchVideo(String videoId) async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
