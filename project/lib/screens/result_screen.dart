// lib/screens/result_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/history_item.dart';
import '../widgets/result_card.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _loading = true;
  Map<String, dynamic>? _apiResult;
  HistoryItem? _args;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _args = ModalRoute.of(context)!.settings.arguments as HistoryItem?;
      _sendPhotos();
      _initialized = true;
    }
  }

  Future<void> _sendPhotos() async {
    if (_args == null) return;
    final api = ApiService();

    try {
      final result = await api.sendCarPhotos(
        frontImage: File(_args!.frontImage!),
        leftImage: File(_args!.leftImage!),
        rightImage: File(_args!.rightImage!),
        rearImage: File(_args!.backImage!),
      );
      setState(() {
        _apiResult = result;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Ошибка API: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;

    if (args == null) {
      return const Scaffold(
        body: Center(child: Text("Нет данных")),
      );
    }

    final Map<String, String?> photos = {
      'front': args.frontImage,
      'left': args.leftImage,
      'right': args.rightImage,
      'back': args.backImage,
    };

    final issues = _getIssues();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат проверки'),
        backgroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Фото автомобиля ---
                    ...photos.entries.map((entry) {
                      final side = entry.key;
                      final path = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _getSideName(side),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (path != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(path),
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Фото не сделано",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }).toList(),

                    // --- Заголовок ---
                    const Text(
                      'Обнаруженные проблемы',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // --- Карточки проблем ---
                    if (issues.isNotEmpty)
                      ...issues.map((issue) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ResultCard(
                            title: issue['title'] as String,
                            result: issue['message'] as String,
                            confidence: issue['confidence'] as int,
                            icon: issue['icon'] as IconData,
                            color: issue['color'] as Color,
                          ),
                        );
                      }).toList()
                    else
                      const Center(
                        child: Text(
                          'Поздравляем! Автомобиль выглядит чистым и целым.',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // --- Зелёная кнопка ---
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff32D583),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/'),
                      child: const Text(
                        'Сфотографировать заново',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Map<String, dynamic>> _getIssues() {
    final List<Map<String, dynamic>> issues = [];
    if (_apiResult == null || _apiResult!['details'] == null) return issues;

    for (final detail in _apiResult!['details'] as List) {
      final side = detail['side'] ?? '';
      final name = _getSideName(side);
      final cleanliness = (detail['cleanliness'] ?? '').toLowerCase();
      final integrity = (detail['integrity'] ?? '').toLowerCase();

      // --- Чистота ---
      if (cleanliness == 'slightly dirty') {
        issues.add({
          'title': 'Чистота',
          'message': 'Похоже, $name слегка загрязнена.',
          'icon': Icons.cleaning_services,
          'color': Colors.orange,
          'confidence': 70,
        });
      } else if (cleanliness == 'dirty') {
        issues.add({
          'title': 'Чистота',
          'message': 'Похоже, $name сильно загрязнена.',
          'icon': Icons.cleaning_services,
          'color': Colors.red,
          'confidence': 90,
        });
      }

      // --- Целостность ---
      if (integrity == 'damaged') {
        issues.add({
          'title': 'Целостность',
          'message': 'Похоже, на $name есть повреждения.',
          'icon': Icons.build_circle,
          'color': Colors.orange,
          'confidence': 75,
        });
      } else if (integrity == 'heavily damaged') {
        issues.add({
          'title': 'Целостность',
          'message': 'Похоже, на $name есть сильные повреждения!',
          'icon': Icons.build_circle,
          'color': Colors.red,
          'confidence': 95,
        });
      }
    }

    return issues;
  }

  String _getSideName(String side) {
    switch (side) {
      case 'front':
        return 'передней части';
      case 'back':
        return 'задней части';
      case 'left':
        return 'левой стороне';
      case 'right':
        return 'правой стороне';
      default:
        return side;
    }
  }
}
