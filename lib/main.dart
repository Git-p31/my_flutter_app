import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'pages/broadcasts_page.dart';
import 'pages/charity_page.dart';
import 'pages/events_page.dart';
import 'pages/news_page.dart';
import 'pages/workshops_page.dart';
import 'pages/profile_page.dart';
import 'pages/auth_page.dart';
import 'pages/settings_page.dart';
import 'pages/cards_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(ErrorApp(message: 'Ошибка инициализации Firebase: $e'));
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
      home: Scaffold(
        body: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  void _toggleNotifications(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', isEnabled);
    setState(() {
      _notificationsEnabled = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        iconTheme: const IconThemeData(color: Colors.blue),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.blue),
        ),
      ),
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
  String _userRole = 'user';

  final List<String> _titles = [
    'Новости',
    'События',
    'Трансляции',
    'Воркшопы',
    'Цдака',
    'Проекты',
  ];

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role') ?? 'user';
      _pages = [
        NewsPage(userRole: _userRole),
        EventsPage(userRole: _userRole),
        const BroadcastsPage(),
        const WorkshopsPage(),
        const CharityPage(),
        if (_userRole == 'admin') const CardsPage(), // Страница «Проекты» только для админов
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  void _openProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      final userId = prefs.getString('id') ?? 'Неизвестный ID';
      final userName = prefs.getString('username') ?? 'Пользователь';
      final userEmail = prefs.getString('email') ?? 'user@example.com';
      final userRole = prefs.getString('role') ?? 'user';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userId: userId,
            userName: userName,
            userEmail: userEmail,
            userRole: userRole,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    }
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
      body: _pages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
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
            _buildDrawerItem(Icons.account_circle, 'Профиль', _openProfile),
            _buildDrawerItem(Icons.article, 'Новости', 0),
            _buildDrawerItem(Icons.event, 'События', 1),
            _buildDrawerItem(Icons.live_tv, 'Трансляции', 2),
            _buildDrawerItem(Icons.work, 'Воркшопы', 3),
            _buildDrawerItem(Icons.volunteer_activism, 'Цдака', 4),
            if (_userRole == 'admin')
              _buildDrawerItem(Icons.folder, 'Проекты', 5), // Пункт «Проекты» только для админов
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, dynamic action) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      selected: action is int ? _selectedIndex == action : false,
      onTap: () {
        if (action is int) {
          _onItemTapped(action);
        } else if (action is Function) {
          action();
        }
      },
    );
  }
}
