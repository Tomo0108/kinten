import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen_fixed.dart';

void _ignoreSigPipe() {
  try {
    // macOS / Linux: SIGPIPE を無視して異常終了を防止
    ProcessSignal.sigpipe.watch().listen((_) {});
  } catch (_) {
    // 非対応環境では無視
  }
}

void _ensureRequiredDirectories() {
  try {
    final Directory currentDir = Directory.current;
    final Directory inputDir = Directory('${currentDir.path}${Platform.pathSeparator}input');
    final Directory outputDir = Directory('${currentDir.path}${Platform.pathSeparator}output');
    final Directory templatesDir = Directory('${currentDir.path}${Platform.pathSeparator}templates');

    if (!inputDir.existsSync()) {
      inputDir.createSync(recursive: true);
    }
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    if (!templatesDir.existsSync()) {
      templatesDir.createSync(recursive: true);
    }

    // 雛形ファイルは配布ZIPに同梱される想定。
    // ここではディレクトリの存在のみ保証する。
  } catch (_) {
    // 起動妨げないため握りつぶす
  }
}

void main() {
  _ignoreSigPipe();
  _ensureRequiredDirectories();
  if (kReleaseMode) {
    runZonedGuarded(() {
      runApp(
        const ProviderScope(
          child: KintenApp(),
        ),
      );
    }, (error, stack) {
      // releaseでは未捕捉例外で落ちないようにする
    }, zoneSpecification: ZoneSpecification(
      // print抑制（パイプへの書き込みを避ける）
      print: (self, parent, zone, line) {},
    ));
  } else {
    runApp(
      const ProviderScope(
        child: KintenApp(),
      ),
    );
  }
}

class KintenApp extends StatelessWidget {
  const KintenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinten（勤転）',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A6B8C),
          background: const Color(0xFFF2F3F5),
        ),
        useMaterial3: true,
        fontFamily: 'Noto Sans JP',
        // レスポンシブデザインのためのテキストスケール設定
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        // アプリバーのテーマ設定
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.transparent),
          titleTextStyle: TextStyle(color: Colors.transparent),
        ),
      ),
      home: const HomeScreen(),
    );
  }
} 