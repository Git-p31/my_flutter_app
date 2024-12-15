import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final void Function(bool) onToggleTheme;
  final void Function(bool) onToggleNotifications;
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
              onChanged: onToggleTheme,
            ),
            const Divider(),
            const Text(
              'Настройки уведомлений',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Уведомления'),
              value: notificationsEnabled,
              onChanged: onToggleNotifications,
            ),
          ],
        ),
      ),
    );
  }
}
