import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import 'profile_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _username = '';
  String _email = '';
  String _password = '';
  bool _isLogin = true;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final user = await DatabaseHelper.instance.loginUser(_username, _password);
        if (user != null && user['id'] != null) {
          await _saveLoginState(user['id'].toString(), user['username'], user['email'], user['role']);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  userId: user['id'].toString(),
                  userName: user['username'],
                  userEmail: user['email'],
                  userRole: user['role'],
                ),
              ),
            );
          }
        } else {
          _showSnackbar('Неверные данные для входа или пользователь не найден');
        }
      } else {
        await DatabaseHelper.instance.registerUser(_username, _email, _password);
        await _saveLoginState('0', _username, _email, 'user');
        _showSnackbar('Регистрация успешна. Теперь вы можете войти.');
        setState(() => _isLogin = true);
      }
    } catch (e) {
      _showSnackbar('Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLoginState(String id, String username, String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('id', id);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя пользователя';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Авторизация' : 'Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Имя пользователя'),
                      onSaved: (value) => _username = value!,
                      validator: _validateUsername,
                    ),
                    if (!_isLogin)
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        onSaved: (value) => _email = value!,
                        validator: _validateEmail,
                      ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Пароль'),
                      obscureText: true,
                      onSaved: (value) => _password = value!,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin ? 'Создать аккаунт' : 'Уже есть аккаунт? Войти'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
