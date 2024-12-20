import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_panel.dart';
import 'auth_page.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String userRole;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userRole = 'user',
  });

  // ID пользователя, для которого должна показываться кнопка админ-панели
  static const String adminUserId = 'qmlqEh6TGjWFTIhu4YLK';

  Future<void> _openAdminPanel(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboard()),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Подтвердите выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout(context);
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Используем Navigator.pop для возврата на предыдущий экран
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[300]),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Имя: $userName', style: const TextStyle(fontSize: 18)),
            ),
            Divider(color: Colors.grey[300]),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text('Email: $userEmail', style: const TextStyle(fontSize: 18)),
            ),
            Divider(color: Colors.grey[300]),
            ListTile(
              leading: const Icon(Icons.perm_identity),
              title: Text('ID: $userId', style: const TextStyle(fontSize: 18)),
            ),
            // Условие для отображения кнопки админ панели
            if (userId == adminUserId)
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _openAdminPanel(context),
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Перейти в админ-панель'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
