import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Для выбора фото
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
import 'dart:io';


// Точка входа в приложение
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Инициализация Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(ErrorApp(message: 'Ошибка инициализации Firebase: $e'));
  }
}

// Экран с ошибкой при сбое Firebase
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

// Основной виджет приложения
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Загрузка предпочтений (темы)
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  // Переключение темы
  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
    if (!mounted) return;
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
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Главная страница приложения
class HomePage extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDarkTheme;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userRole = 'user';
  String _userName = 'Пользователь';
  String? _userPhoto;

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
    _loadUserData();
  }

  // Загрузка роли пользователя
  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userRole = prefs.getString('role') ?? 'user';
      _pages = [
        NewsPage(userRole: _userRole),
        EventsPage(userRole: _userRole),
        const BroadcastsPage(),
        const WorkshopsPage(),
        const CharityPage(),
        if (_userRole == 'admin' || _userRole == 'rebe' || _userRole == 'moderator') const CardsPage(),
      ];
    });
  }

  // Загрузка данных пользователя
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('username') ?? 'Пользователь';
      _userPhoto = prefs.getString('userPhoto');
    });
  }

  // Выбор фото пользователя
  Future<void> _selectPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userPhoto', pickedFile.path);
      setState(() {
        _userPhoto = pickedFile.path;
      });
    }
  }

  // Обработка выбора элемента бокового меню
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Закрытие бокового меню
  }

  // Открытие профиля пользователя
  void _openProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      final userId = prefs.getString('id') ?? 'Неизвестный ID';
      final userEmail = prefs.getString('email') ?? 'user@example.com';
      final userRole = prefs.getString('role') ?? 'user';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userId: userId,
            userName: _userName,
            userEmail: userEmail,
            userRole: userRole,
          ),
        ),
      ).then((_) => _loadUserData());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    }
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
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => SettingsPage(
                onToggleTheme: widget.onToggleTheme,
                isDarkTheme: widget.isDarkTheme,
                appVersion: '',
              ),
            ),
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
            GestureDetector(
              onTap: _selectPhoto, // Открытие выбора фото
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                accountName: Text(
                  _userName,
                  style: const TextStyle(fontSize: 16),
                ),
                accountEmail: null,
                currentAccountPicture: CircleAvatar(
                  backgroundImage: _userPhoto != null
                      ? FileImage(File(_userPhoto!))
                      : null,
                  child: _userPhoto == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
            ),
            _buildDrawerItem(Icons.account_circle, 'Профиль', _openProfile),
            _buildDrawerItem(Icons.article, 'Новости', 0),
            _buildDrawerItem(Icons.event, 'События', 1),
            _buildDrawerItem(Icons.live_tv, 'Трансляции', 2),
            _buildDrawerItem(Icons.work, 'Воркшопы', 3),
            _buildDrawerItem(Icons.volunteer_activism, 'Цдака', 4),
            if (_userRole == 'admin' || _userRole == 'rebe' || _userRole == 'moderator')
              _buildDrawerItem(Icons.folder, 'Проекты', 5),
          ],
        ),
      ),
    );
  }

  // Виджет для элементов бокового меню
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