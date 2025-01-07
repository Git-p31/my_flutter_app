import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CharityPage extends StatefulWidget {
  const CharityPage({super.key});

  @override
  State<CharityPage> createState() => _CharityPageState();
}

class _CharityPageState extends State<CharityPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/video/charity_video.mp4', // Укажите путь к вашему видео в папке assets
    )
      ..initialize().then((_) {
        setState(() {}); // Обновляем состояние, чтобы отобразить видео после инициализации
        _controller.play(); // Запускаем воспроизведение автоматически
      })
      ..setLooping(true); // Включаем зацикливание видео
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Цдака'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const Text(
                'Ошибка загрузки видео',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
      ),
    );
  }
}
