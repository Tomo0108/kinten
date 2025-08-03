import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KintenApp(),
    ),
  );
}

class KintenApp extends StatelessWidget {
  const KintenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinten（勤転）',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A6B8C),
          background: const Color(0xFFF2F3F5),
        ),
        useMaterial3: true,
        fontFamily: 'Noto Sans JP',
      ),
      home: const HomeScreen(),
    );
  }
} 