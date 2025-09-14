// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:indrive_car_condition/screens/gallery_photo_wizard.dart';
import 'package:provider/provider.dart';

import 'screens/car_photo_wizard.dart';
import 'screens/landing_screen.dart';
import 'screens/result_screen.dart';
import 'screens/info_screen.dart';
import 'screens/error_screen.dart';
import 'screens/history_screen.dart';
import 'navigation/nav_bar.dart';
import 'models/history_item.dart';
import 'providers/history_provider.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Получаем камеры (как у тебя было)
  cameras = await availableCameras();

await Hive.initFlutter();
Hive.registerAdapter(HistoryItemAdapter());

// Теперь открываем заново
final box = await Hive.openBox('history_box');


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider(box)),
      ],
      child: const InDriveCarConditionApp(),
    ),
  );
}

class InDriveCarConditionApp extends StatelessWidget {
  const InDriveCarConditionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'inDrive - Проверка состояния авто',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFF32D583, {
          50: Color(0xFFE8F9F2),
          100: Color(0xFFC6F0DE),
          200: Color(0xFFA0E6C8),
          300: Color(0xFF7ADCB2),
          400: Color(0xFF5ED4A1),
          500: Color(0xFF32D583),
          600: Color(0xFF2DC177),
          700: Color(0xFF26AB68),
          800: Color(0xFF1F955A),
          900: Color(0xFF137341),
        }),
        primaryColor: const Color(0xFF32D583),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF1A1D21),
          displayColor: const Color(0xFF1A1D21),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF32D583),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            color: const Color(0xFF1A1D21),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF1A1D21),
          ),
        ),
      ),
      initialRoute: '/nav',
      routes: {
        '/nav': (context) => const NavBar(),
        '/camera': (context) => const CarPhotoWizard(),
        '/result': (context) => const ResultScreen(),
        '/info': (context) => const InfoScreen(),
        '/error': (context) => const ErrorScreen(),
        '/history': (context) => const HistoryScreen(),
        '/gallery': (context) => const GalleryPhotoWizard(),
      },
    );
  }
}
