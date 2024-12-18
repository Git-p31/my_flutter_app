import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

  // Выбор изображения из галереи
  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Отправка новости
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

        _resetForm();
        _showMessage('Новость успешно добавлена!');
      } catch (e) {
        _showMessage('Ошибка: $e');
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Отправка события
  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        String imageUrl = '';
        if (_imageFile != null) {
          // Загрузить изображение в Firebase Storage и получить URL (заглушка)
          imageUrl = _imageFile!.path;
        }

        await DatabaseHelper.instance.insertEvent(
          _titleController.text,
          _descriptionController.text,
          imageUrl,
        );

        _resetForm();
        _showMessage('Событие успешно добавлено!');
      } catch (e) {
        _showMessage('Ошибка: $e');
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Сброс формы
  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _imageFile = null;
      _currentAction = '';
    });
  }

  // Показ сообщения
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Отображение списка пользователей
  void _displayUserList() async {
    try {
      List<Map<String, dynamic>> users = await DatabaseHelper.instance.getUsers();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Список пользователей'),
          content: SingleChildScrollView(
            child: Column(
              children: users.map((user) => ListTile(
                title: Text(user['username'] ?? 'Без имени'),
                subtitle: Text(user['email'] ?? 'Без email'),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Ошибка загрузки пользователей: $e');
    }
  }

  // Установка текущего действия
  void _setAction(String action) {
    setState(() {
      _currentAction = action;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Админ-панель')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _displayUserList,
                child: const Text('Просмотреть пользователей'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _setAction('news'),
                child: const Text('Создать новость'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _setAction('event'),
                child: const Text('Создать событие'),
              ),
              const SizedBox(height: 20),
              if (_currentAction == 'news' || _currentAction == 'event')
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Название'),
                        validator: (value) => value!.isEmpty ? 'Название обязательно' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Описание'),
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? 'Описание обязательно' : null,
                      ),
                      const SizedBox(height: 20),
                      if (_currentAction == 'event') ...[
                        ElevatedButton.icon(
                          onPressed: _selectImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Выбрать изображение'),
                        ),
                        const SizedBox(height: 10),
                        _imageFile != null
                            ? Image.file(_imageFile!, height: 150, fit: BoxFit.cover)
                            : const Text('Изображение не выбрано', textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                      ],
                      _isProcessing
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _currentAction == 'news' ? _submitNews : _submitEvent,
                              child: Text(_currentAction == 'news' ? 'Добавить новость' : 'Добавить событие'),
                            ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
