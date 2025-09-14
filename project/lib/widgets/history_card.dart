import 'dart:io';
import 'package:flutter/material.dart';
import '../models/history_item.dart';

class HistoryCard extends StatefulWidget {
  final HistoryItem item;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final photos = [
      widget.item.frontImage,
      widget.item.leftImage,
      widget.item.rightImage,
      widget.item.backImage,
    ];

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Фото ---
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: photos.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
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
                                    size: 40, color: Colors.grey)),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // --- Индикаторы ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (index) {
                final isActive = index == _currentPage;
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
            const SizedBox(height: 12),
            // --- Дата ---
            Text(
              _formatDate(widget.item.date),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            // --- Результаты ---
            Row(
              children: [
                Expanded(
                  child: _buildResultChip(
                    'Чистота',
                    widget.item.cleanliness,
                    widget.item.cleanlinessConfidence,
                    color: _getCleanlinessColor(widget.item.cleanliness),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildResultChip(
                    'Целостность',
                    widget.item.integrity,
                    widget.item.integrityConfidence,
                    color: _getIntegrityColor(widget.item.integrity),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultChip(String label, String value, int confidence,
      {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text('Уверенность: $confidence%',
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
        return Colors.yellow[700]!; // Жёлтый
      case 'Сильно повреждённый':
        return Colors.red; // Красный
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
