import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/history_item.dart';
import '../widgets/history_card.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, this.showAppBar = true});
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('История проверок')) : null,
      body: SafeArea(
        child: Consumer<HistoryProvider>(
          builder: (context, provider, child) {
            final items = provider.items;
            if (items.isEmpty) return _buildEmptyState(context);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: HistoryCard(
                    item: item,
                    onTap: () => _showHistoryDetails(context, item),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'История пуста',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  void _showHistoryDetails(BuildContext context, HistoryItem item) {
    final photos = [
      item.frontImage,
      item.leftImage,
      item.rightImage,
      item.backImage,
    ];

    int currentPage = 0;
    final pageController = PageController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- хэндл ---
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // --- заголовок ---
                    Text(
                      'Детали проверки',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // --- фото карусель ---
                    SizedBox(
                      height: 240,
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: photos.length,
                        onPageChanged: (index) {
                          setState(() => currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          final path = photos[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: path != null
                                ? Image.file(File(path), fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.directions_car,
                                          size: 50, color: Colors.grey),
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- индикаторы ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(photos.length, (index) {
                        final isActive = index == currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 10 : 8,
                          height: isActive ? 10 : 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.black : Colors.grey[400],
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // --- дата ---
                    Text(
                      'Дата: ${_formatDate(item.date)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- результаты в чипах ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultChip(
                            label: 'Чистота',
                            value: item.cleanliness,
                            confidence: item.cleanlinessConfidence,
                            color: _getCleanlinessColor(item.cleanliness),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildResultChip(
                            label: 'Целостность',
                            value: item.integrity,
                            confidence: item.integrityConfidence,
                            color: _getIntegrityColor(item.integrity),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Закрыть',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

// --- вспомогательные методы такие же как в карточке ---
  Widget _buildResultChip({
    required String label,
    required String value,
    required int confidence,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text('$confidence%',
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Color _getCleanlinessColor(String result) {
    switch (result) {
      case 'Чистый':
        return Colors.green;
      case 'Слегка грязный':
        return Colors.orange;
      case 'Сильно грязный':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getIntegrityColor(String result) {
    switch (result) {
      case 'Целый':
        return Colors.green;
      case 'Повреждённый':
        return Colors.orange; // <-- оранжевый для легких повреждений
      case 'Сильно повреждённый':
        return Colors.red; // <-- красный для сильных повреждений
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) return '${difference.inMinutes} мин назад';
      return '${difference.inHours} ч назад';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
  }
}
