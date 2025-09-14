// lib/screens/car_photo_wizard.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:indrive_car_condition/models/history_item.dart';
import 'package:indrive_car_condition/providers/history_provider.dart';
import 'package:indrive_car_condition/widgets/exit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

class CarPhotoWizard extends StatefulWidget {
  const CarPhotoWizard({super.key});

  @override
  State<CarPhotoWizard> createState() => _CarPhotoWizardState();
}

class _CarPhotoWizardState extends State<CarPhotoWizard> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _currentStep = 0;
  final Map<String, File?> _photos = {
    "front": null,
    "left": null,
    "right": null,
    "back": null,
  };
  bool _flashOn = false;
  File? _previewPhoto;

  late AudioPlayer _player;
  bool _soundOn = true;

  bool _isCapturing = false; // 🔹 флаг для защиты от повторного нажатия

  final List<Map<String, String>> _steps = [
    {
      "title": "Фото спереди",
      "overlay": "assets/overlays/car_front.png",
      "audio": "assets/audio/car_front.mp3",
      "key": "front"
    },
    {
      "title": "Фото слева",
      "overlay": "assets/overlays/car_left.png",
      "audio": "assets/audio/car_left.mp3",
      "key": "left"
    },
    {
      "title": "Фото справа",
      "overlay": "assets/overlays/car_right.png",
      "audio": "assets/audio/car_right.mp3",
      "key": "right"
    },
    {
      "title": "Фото сзади",
      "overlay": "assets/overlays/car_back.png",
      "audio": "assets/audio/car_back.mp3",
      "key": "back"
    },
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _lockLandscape();
    _initCamera();
    _playCurrentStepAudio();
  }

  Future<void> _lockLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras!.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return; // 🔹 игнорируем, если ещё идёт съёмка

    try {
      setState(() => _isCapturing = true);
      final picture = await _controller!.takePicture();
      setState(() {
        _previewPhoto = File(picture.path);
      });
    } catch (e) {
      debugPrint("Ошибка при съемке: $e");
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _confirmPhoto() async {
    final stepKey = _steps[_currentStep]["key"]!;
    setState(() {
      _photos[stepKey] = _previewPhoto;
      _previewPhoto = null;
    });

    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _playCurrentStepAudio();
    } else {
      // 🔹 пока используем моковые результаты
      final results = _generateMockResults();
      final item = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        cleanliness: results['cleanliness']['label'],
        cleanlinessConfidence: results['cleanliness']['confidence'],
        integrity: results['integrity']['label'],
        integrityConfidence: results['integrity']['confidence'],
        frontImage: _photos['front']?.path,
        leftImage: _photos['left']?.path,
        rightImage: _photos['right']?.path,
        backImage: _photos['back']?.path,
      );

      final provider =
          Provider.of<HistoryProvider>(context, listen: false);
      await provider.addItem(item);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/result", arguments: item);
    }
  }

  Map<String, dynamic> _generateMockResults() {
    final random = Random();
    final cleanlinessOptions = [
      {'label': 'Чистый', 'confidence': 85 + random.nextInt(15)},
      {'label': 'Слегка грязный', 'confidence': 75 + random.nextInt(20)},
      {'label': 'Сильно грязный', 'confidence': 80 + random.nextInt(20)},
    ];
    final integrityOptions = [
      {'label': 'Целый', 'confidence': 90 + random.nextInt(10)},
      {'label': 'Повреждённый', 'confidence': 85 + random.nextInt(15)},
    ];
    return {
      'cleanliness':
          cleanlinessOptions[random.nextInt(cleanlinessOptions.length)],
      'integrity':
          integrityOptions[random.nextInt(integrityOptions.length)],
    };
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    _flashOn = !_flashOn;
    await _controller!
        .setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _playCurrentStepAudio() async {
    if (!_soundOn) return;
    final audioPath = _steps[_currentStep]["audio"]!;
    await _player.stop();
    await _player.play(AssetSource(audioPath.replaceFirst("assets/", "")));
  }

  void _toggleSound() {
    setState(() => _soundOn = !_soundOn);
    if (_soundOn) {
      _playCurrentStepAudio();
    } else {
      _player.stop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _player.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showExitConfirmationDialog(context);
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller == null || !_controller!.value.isInitialized
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (_previewPhoto == null) ...[
                    CameraPreview(_controller!),
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: Image.asset(
                          step["overlay"]!,
                          fit: BoxFit.contain,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Text(
                        step["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(
                            blurRadius: 4,
                            color: Colors.black,
                          )],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          Transform.rotate(
                            angle: 2 * pi,
                            child: IconButton(
                              icon: Icon(
                                _soundOn
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: _toggleSound,
                            ),
                          ),
                          const Spacer(flex: 2),
                          Transform.rotate(
                            angle: 2 * pi,
                            child: GestureDetector(
                              onTap: _isCapturing ? null : _takePhoto,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isCapturing
                                      ? Colors.grey
                                      : Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 4,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(flex: 1),
                          Transform.rotate(
                            angle: 2 * pi,
                            child: IconButton(
                              icon: Icon(
                                _flashOn
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: _toggleFlash,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Positioned.fill(
                      child: Image.file(
                        _previewPhoto!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 30,
                      right: 30,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () =>
                                setState(() => _previewPhoto = null),
                            icon: const Icon(Icons.close),
                            label: const Text("Переснять"),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: _confirmPhoto,
                            icon: const Icon(Icons.check),
                            label: const Text("Подтвердить"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
