import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../database_helper.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  bool _isProcessing = false;
  String _currentAction = '';
  List<Map<String, dynamic>> _users = [];
  bool _isLoadingUsers = false;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  String? _imageToBase64(File? imageFile) {
    if (imageFile == null) return null;
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }

  Future<void> _submitNews() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        await DatabaseHelper.instance.insertNews(
          _titleController.text,
          _descriptionController.text,
        );
        if (mounted) {
          _resetForm();
          _showMessage('Новость добавлена!');
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Ошибка: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        String? imageBase64 = _imageToBase64(_imageFile);
        await DatabaseHelper.instance.insertEvent(
          _titleController.text,
          _descriptionController.text,
          imageBase64 ?? '',
        );
        if (mounted) {
          _resetForm();
          _showMessage('Событие добавлено!');
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Ошибка: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _imageFile = null;
      _currentAction = '';
    });
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _setAction(String action) {
    setState(() {
      _currentAction = _currentAction == action ? '' : action;
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final users = await DatabaseHelper.instance.getUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      if (mounted) {
        _showMessage('Ошибка при загрузке пользователей: $e');
      }
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _changeUserRole(String userId, String newRole) async {
    try {
      await DatabaseHelper.instance.updateUserRole(userId, newRole);
      _loadUsers();
      _showMessage('Роль обновлена!');
    } catch (e) {
      _showMessage('Ошибка: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ-панель'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Управление контентом',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _setAction('news'),
                icon: const Icon(Icons.article),
                label: const Text('Создать новость'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _setAction('event'),
                icon: const Icon(Icons.event),
                label: const Text('Создать событие'),
              ),
              const SizedBox(height: 20),
              if (_currentAction.isNotEmpty)
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Название'),
                            validator: (value) => value!.isEmpty ? 'Заполните название' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(labelText: 'Описание'),
                            maxLines: 3,
                            validator: (value) => value!.isEmpty ? 'Заполните описание' : null,
                          ),
                          const SizedBox(height: 20),
                          if (_currentAction == 'event') ...[
                            ElevatedButton.icon(
                              onPressed: _selectImage,
                              icon: const Icon(Icons.image),
                              label: const Text('Выбрать изображение'),
                            ),
                            const SizedBox(height: 10),
                            if (_imageFile != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
                              ),
                          ],
                          const SizedBox(height: 20),
                          _isProcessing
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _currentAction == 'news' ? _submitNews : _submitEvent,
                                  child: Text(_currentAction == 'news' ? 'Добавить новость' : 'Добавить событие'),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Управление пользователями',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.people),
                label: const Text('Загрузить пользователей'),
              ),
              const SizedBox(height: 20),
              _isLoadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isNotEmpty
                      ? Column(
                          children: _users.map((user) {
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                title: Text(user['username'] ?? 'Неизвестный'),
                                subtitle: Text('Роль: ${user['role'] ?? 'Не определено'}'),
                                trailing: DropdownButton<String>(
                                  value: user['role'],
                                  items: ['admin', 'user', 'moderator', 'rebe']
                                      .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                                      .toList(),
                                  onChanged: (newRole) => _changeUserRole(user['id'], newRole!),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : const Center(child: Text('Нет пользователей')),
            ],
          ),
        ),
      ),
    );
  }
}
