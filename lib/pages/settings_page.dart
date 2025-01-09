import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final Function(bool) onToggleTheme;
  final bool isDarkTheme;
  final bool notificationsEnabled;
  final String appVersion;
  final Function(bool) onToggleNotifications; // Функция для управления уведомлениями

  const SettingsPage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
    required this.notificationsEnabled,
    required this.appVersion,
    required this.onToggleNotifications, // Передаем новый параметр для уведомлений
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Настройки темы',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Тёмная тема'),
              value: isDarkTheme,
              onChanged: onToggleTheme, // Используем переданную функцию для изменения темы
            ),
            const Divider(),
            const Text(
              'Уведомления',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Включить уведомления'),
              value: notificationsEnabled,
              onChanged: onToggleNotifications, // Используем переданную функцию для управления уведомлениями
            ),
            const Divider(),
            const Text(
              'Версия приложения',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text('Текущая версия: $appVersion'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDarkTheme = false; // Состояние тёмной темы
  bool _notificationsEnabled = true;  // Управление состоянием уведомлений
  String appVersion = '1.0.0';  // Текущая версия приложения

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
    return Scaffold(
      appBar: AppBar(title: const Text('Главная страница')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Навигация в настройки
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(
                  onToggleTheme: _toggleTheme,
                  isDarkTheme: _isDarkTheme,
                  notificationsEnabled: _notificationsEnabled,
                  appVersion: appVersion,
                  onToggleNotifications: _toggleNotifications, // Передаем логику для уведомлений
                ),
              ),
            );
          },
          child: const Text('Перейти в настройки'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData.light(), // Начальная тема
    darkTheme: ThemeData.dark(), // Тема для темной версии
    home: const HomePage(),
  ));
}
