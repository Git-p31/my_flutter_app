import 'package:flutter/material.dart';

void main() {
  runApp(const CardsPage());
}

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        appBar: AppBar(
          title: const Text('Projects'),
          backgroundColor: const Color(0xFF1E1E2C),
          elevation: 0,
        ),
        body: const SingleChildScrollView(
          child: CardsGrid(),
        ),
      ),
    );
  }
}

class CardsGrid extends StatelessWidget {
  const CardsGrid({super.key});

  final List<CardData> cards = const [
    CardData(
      title: 'Создание мобильного приложения',
      subtitle: 'UI/UX дизайн',
      progress: 40,
      gradient: LinearGradient(
        colors: [Color(0xFF00BFA5), Color(0xFF004D40)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),

    CardData(
      title: 'Создание CRM-системы',
      subtitle: 'Автоматизация процессов',
      progress: 0,
      gradient: LinearGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFFFA726)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),

    CardData(
      title: 'Свой маркетплейс',
      subtitle: 'Разработка для продалжения ',
      progress: 0,
      gradient: LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),

    CardData(
      title: 'Доски задач',
      subtitle: 'Управление проектами',
      progress: 0,
      gradient: LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CardWidget(cardData: card),
                ))
            .toList(),
      ),
    );
  }
}

class CardData {
  final String title;
  final String subtitle;
  final int progress;
  final LinearGradient gradient;

  const CardData({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.gradient,
  });
}

class CardWidget extends StatelessWidget {
  final CardData cardData;

  const CardWidget({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: cardData.gradient,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cardData.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cardData.subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: cardData.progress / 100,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${cardData.progress}% Complete',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
