import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_new.dart';

// ═════════════════════════════════════════════════════════════════════════════
// MAIN ENTRY POINT - OFFRAMP Digital Wellness App
// ═════════════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1A1F2E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const OfframpApp());
}
