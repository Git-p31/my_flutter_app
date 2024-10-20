import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kemo-APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Text('Главная страница', style: TextStyle(fontSize: 24)),
    const LivestreamsPage(), // Страница с трансляциями
    const Text('Цдака', style: TextStyle(fontSize: 24)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kemo-app'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Меню',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Главная'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.live_tv),
              title: const Text('Трансляция'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text('Цдака'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            label: 'Трансляции',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Цдака',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Страница с трансляциями
class LivestreamsPage extends StatefulWidget {
  const LivestreamsPage({super.key});

  @override
  State<LivestreamsPage> createState() => _LivestreamsPageState();
}

class _LivestreamsPageState extends State<LivestreamsPage> {
  String? shomerTvLiveId;
  String? kemoNetworkLiveId;

  final String apiKey = 'AIzaSyCCzzbY3RRVYorlQrdQf6ubECP_B5ltS5Y'; // Ваш API ключ
  final String shomerTvChannelId = 'UCELCPjx3rq0d-G6WfhjwXyA'; // ID канала ShomerTV
  final String kemoNetworkChannelId = 'UCWLxarOxx4Aeh959lrV31Lg'; // ID канала KEMOnetwork

  @override
  void initState() {
    super.initState();
    fetchLiveStreams();
  }

  // Метод для получения информации о прямых трансляциях
  Future<void> fetchLiveStreams() async {
    final shomerTvLive = await getLiveStreamId(shomerTvChannelId);
    final kemoNetworkLive = await getLiveStreamId(kemoNetworkChannelId);

    setState(() {
      shomerTvLiveId = shomerTvLive;
      kemoNetworkLiveId = kemoNetworkLive;
    });
  }

  // Запрос к YouTube API для получения ID текущей трансляции
  Future<String?> getLiveStreamId(String channelId) async {
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&eventType=live&type=video&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['items'].isNotEmpty) {
        return jsonResponse['items'][0]['id']['videoId'];
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        if (shomerTvLiveId != null)
          ListTile(
            title: const Text('ShomerTV'),
            subtitle: const Text('Трансляция на ShomerTV'),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_fill),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        YoutubePlayerScreen(videoId: shomerTvLiveId!),
                  ),
                );
              },
            ),
          )
        else
          const ListTile(
            title: Text('ShomerTV'),
            subtitle: Text('Нет активных трансляций'),
          ),
        if (kemoNetworkLiveId != null)
          ListTile(
            title: const Text('KEMOnetwork'),
            subtitle: const Text('Трансляция на KEMOnetwork'),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_fill),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        YoutubePlayerScreen(videoId: kemoNetworkLiveId!),
                  ),
                );
              },
            ),
          )
        else
          const ListTile(
            title: Text('KEMOnetwork'),
            subtitle: Text('Нет активных трансляций'),
          ),
      ],
    );
  }
}

// Экран YouTube Player
class YoutubePlayerScreen extends StatefulWidget {
  final String videoId;

  const YoutubePlayerScreen({required this.videoId, super.key});

  @override
  YoutubePlayerScreenState createState() => YoutubePlayerScreenState();
}

class YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Трансляция')),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
