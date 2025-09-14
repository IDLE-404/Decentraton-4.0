// lib/screens/gallery_photo_wizard.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indrive_car_condition/widgets/exit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class GalleryPhotoWizard extends StatefulWidget {
  const GalleryPhotoWizard({super.key});

  @override
  State<GalleryPhotoWizard> createState() => _GalleryPhotoWizardState();
}

class _GalleryPhotoWizardState extends State<GalleryPhotoWizard> {
  final ImagePicker _picker = ImagePicker();
  int _currentStep = 0;
  final Map<String, File?> _photos = {
    "front": null,
    "left": null,
    "right": null,
    "back": null,
  };

  final List<Map<String, String>> _steps = [
    {"title": "Фото спереди", "key": "front"},
    {"title": "Фото слева", "key": "left"},
    {"title": "Фото справа", "key": "right"},
    {"title": "Фото сзади", "key": "back"},
  ];

  Future<void> _pickFromGallery(String key) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (picked == null) return;

      // копируем в application documents чтобы гарантировать доступ
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(picked.path)}';
      final saved =
          await File(picked.path).copy(path.join(directory.path, fileName));

      if (!mounted) return;
      setState(() {
        _photos[key] = saved;
      });
    } catch (e) {
      // можно показать ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при выборе изображения')),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      // все фото готовы — переходим к результату
      Navigator.pushReplacementNamed(context, '/result', arguments: _photos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final key = step['key']!;
    final progress = (_currentStep + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Загрузка фото из галереи"),
        backgroundColor: const Color(0xFF32D583),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final shouldExit = await showExitConfirmationDialog(context);
            if (shouldExit == true) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF32D583),
            minHeight: 6,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              step['title']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: _photos[key] == null
                  ? Container(
                      width: 220,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text("Нет фото")),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _photos[key]!,
                        width: 220,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32D583),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _pickFromGallery(key),
                  child: const Text("Выбрать из галереи"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _photos[key] != null ? _nextStep : null,
                  child: Text(
                    _currentStep == _steps.length - 1 ? "Завершить" : "Далее",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // опция пропустить — перейти дальше без фото
                    _nextStep();
                  },
                  child: const Text('Пропустить'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
