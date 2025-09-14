import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О проверке'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF32D583).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_user,
                      size: 48,
                      color: Color(0xFF32D583),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Проверка состояния автомобиля',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              _buildInfoSection(
                context,
                icon: Icons.star,
                title: 'Зачем нужна проверка',
                content: 'Система автоматически определяет состояние автомобиля, что помогает обеспечить доверие пассажиров, высокое качество сервиса и безопасность поездок.',
              ),
              const SizedBox(height: 24),
              
              _buildInfoSection(
                context,
                icon: Icons.cleaning_services,
                title: 'Оценка чистоты',
                content: 'Анализ фотографии позволяет определить уровень чистоты автомобиля: чистый, слегка грязный или сильно грязный.',
              ),
              const SizedBox(height: 24),
              
              _buildInfoSection(
                context,
                icon: Icons.build_circle,
                title: 'Проверка целостности',
                content: 'Система выявляет внешние повреждения кузова автомобиля и определяет его общую целостность.',
              ),
              const SizedBox(height: 24),
              
              _buildInfoSection(
                context,
                icon: Icons.speed,
                title: 'Быстрый анализ',
                content: 'Результаты проверки готовы в течение нескольких секунд после загрузки фотографии.',
              ),
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Советы для лучших результатов',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Фотографируйте автомобиль при хорошем освещении\n'
                      '• Убедитесь, что автомобиль полностью виден в кадре\n'
                      '• Избегайте размытых или тёмных снимков\n'
                      '• Делайте фото с расстояния 2-3 метров',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
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

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF32D583).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF32D583),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}