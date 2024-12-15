import 'package:flutter/material.dart';
import 'pages/broadcasts_page.dart';
import 'pages/charity_page.dart';
import 'pages/events_page.dart';
import 'pages/news_page.dart';
import 'pages/workshops_page.dart';
import 'pages/profile_page.dart'; // Импорт для профиля

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  void _toggleNotifications(bool isEnabled) {
    setState(() {
      _notificationsEnabled = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(
        onToggleTheme: _toggleTheme,
        onToggleNotifications: _toggleNotifications,
        isDarkTheme: _isDarkTheme,
        notificationsEnabled: _notificationsEnabled,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final Function(bool) onToggleNotifications;
  final bool isDarkTheme;
  final bool notificationsEnabled;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.onToggleNotifications,
    required this.isDarkTheme,
    required this.notificationsEnabled,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Новости',
    'События',
    'Трансляции',
    'Воркшопы',
    'Цдака',
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const NewsPage(),
      const EventsPage(),
            BroadcastsPage(),
      const WorkshopsPage(),
      const CharityPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Закрывает drawer после выбора страницы
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(
          userName: 'Иван Иванов',
          userEmail: 'ivan@example.com',
        ),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SettingsPage(
          onToggleTheme: widget.onToggleTheme,
          onToggleNotifications: widget.onToggleNotifications,
          isDarkTheme: widget.isDarkTheme,
          notificationsEnabled: widget.notificationsEnabled,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _openProfile,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Навигация',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Профиль'),
              onTap: () {
                Navigator.pop(context);
                _openProfile();
              },
            ),
            _buildDrawerItem(Icons.article, 'Новости', 0),
            _buildDrawerItem(Icons.event, 'События', 1),
            _buildDrawerItem(Icons.live_tv, 'Трансляции', 2),
            _buildDrawerItem(Icons.work, 'Воркшопы', 3),
            _buildDrawerItem(Icons.volunteer_activism, 'Цдака', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () => _onItemTapped(index),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Function(bool) onToggleTheme;
  final Function(bool) onToggleNotifications;
  final bool isDarkTheme;
  final bool notificationsEnabled;

  const SettingsPage({
    super.key,
    required this.onToggleTheme,
    required this.onToggleNotifications,
    required this.isDarkTheme,
    required this.notificationsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Тёмная тема'),
            value: isDarkTheme,
            onChanged: onToggleTheme,
          ),
          SwitchListTile(
            title: const Text('Уведомления'),
            value: notificationsEnabled,
            onChanged: onToggleNotifications,
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
