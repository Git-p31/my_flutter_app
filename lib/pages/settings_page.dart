  import 'package:flutter/material.dart';

  class SettingsPage extends StatelessWidget {
    final Function(bool) onToggleTheme;
    final bool isDarkTheme;
    final String appVersion;
    final bool updateAvailable;

    const SettingsPage({
      super.key,
      required this.onToggleTheme,
      required this.isDarkTheme,
      required this.appVersion,
      required this.updateAvailable,
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
                'Версия приложения',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text('Текущая версия: $appVersion'),
                trailing: updateAvailable
                    ? ElevatedButton(
                        onPressed: () {
                          // Логика обновления приложения
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Начинается обновление приложения...')),
                          );
                        },
                        child: const Text('Обновить'),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    }
  }
