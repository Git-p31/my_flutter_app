import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  String _appVersion = '2.0.0';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _getAppVersion();
  }

  /// Загрузка пользовательских настроек
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  /// Получение текущей версии приложения
  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  /// Переключение темы
  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kemo News',
      theme: _isDarkTheme
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
              primaryColor: Colors.blue,
              appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
              iconTheme: const IconThemeData(color: Colors.blue),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
                titleLarge: TextStyle(color: Colors.blue),
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: Colors.white,
              primaryColor: Colors.blue,
              appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
              iconTheme: const IconThemeData(color: Colors.black),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black),
                bodyMedium: TextStyle(color: Colors.black),
                titleLarge: TextStyle(color: Colors.blue),
              ),
            ),
      home: HomePage(
        onToggleTheme: _toggleTheme,
        isDarkTheme: _isDarkTheme,
        appVersion: _appVersion,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDarkTheme;
  final String appVersion;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
    required this.appVersion,
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
        isDarkTheme: widget.isDarkTheme,
        appVersion: widget.appVersion,
        updateAvailable: false, // Передано значение
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
