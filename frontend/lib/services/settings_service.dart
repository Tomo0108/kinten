import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class SettingsService {
  static const String _templatePathKey = 'template_path';
  static const String _outputPathKey = 'output_path';
  static const String _employeeNameKey = 'employee_name';
  
  // SharedPreferencesの安全な初期化
  static Future<SharedPreferences?> _getPreferences() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      print('SharedPreferences初期化エラー: $e');
      return null;
    }
  }
  
  // デフォルトテンプレートパスを動的に解決
  static Future<String> get _defaultTemplatePath async {
    // プロジェクトルートを取得（Windows/macOS/開発・本番ビルドの両方に対応）
    final currentDir = Directory.current.path;
    String projectRoot = currentDir;

    try {
      if (currentDir.contains('frontend${path.separator}build${path.separator}windows${path.separator}x64${path.separator}runner${path.separator}Release')) {
        // Windows Releaseディレクトリからプロジェクトルートを取得
        final releaseDir = Directory(currentDir);
        final runnerDir = releaseDir.parent;
        final x64Dir = runnerDir.parent;
        final windowsDir = x64Dir.parent;
        final buildDir = windowsDir.parent;
        final frontendDir = buildDir.parent;
        projectRoot = frontendDir.parent.path;
      } else if (currentDir.contains('frontend${path.separator}build${path.separator}macos${path.separator}Build${path.separator}Products')) {
        // macOSビルド出力ディレクトリからプロジェクトルートを取得（開発時）
        final productsDir = Directory(currentDir);
        final buildDir = productsDir.parent;   // Build
        final macosDir = buildDir.parent;      // macos
        final buildRoot = macosDir.parent;     // build
        final frontendDir = buildRoot.parent;  // frontend
        projectRoot = frontendDir.parent.path; // プロジェクトルート
      } else if (Platform.isMacOS && (
        currentDir.contains('kinten.app${path.separator}Contents${path.separator}MacOS') ||
        File(Platform.resolvedExecutable).parent.path.contains('kinten.app${path.separator}Contents${path.separator}MacOS')
      )) {
        // アプリバンドル内からの実行（配布時）: 実行バイナリの位置から kinten/ を特定
        final exeDir = File(Platform.resolvedExecutable).parent.path;
        var up = Directory(exeDir);
        for (int i = 0; i < 3; i++) { up = up.parent; }
        final pkgCandidate = up.path; // .../kinten
        // kinten/backend/main.py があれば kinten をルートとして扱う
        final pkgBackendMain = File(path.join(pkgCandidate, 'backend', 'main.py'));
        if (pkgBackendMain.existsSync()) {
          projectRoot = pkgCandidate;
        } else {
          // フォールバック: さらに1階層上（リポジトリ直下想定）
          final repoCandidate = Directory(pkgCandidate).parent.path;
          final repoBackendMain = File(path.join(repoCandidate, 'backend', 'main.py'));
          if (repoBackendMain.existsSync()) {
            projectRoot = repoCandidate;
          }
        }
      } else if (currentDir.endsWith('frontend') || currentDir.endsWith('frontend${path.separator}')) {
        projectRoot = Directory(currentDir).parent.path;
      }
    } catch (_) {
      // 失敗時は currentDir を継続利用
    }
    
    // デフォルト: プロジェクト直下の templates（配布時は kinten/templates を優先チェック）
    final primary = path.join(projectRoot, 'templates', '勤怠表雛形_2025年版.xlsx');
    try {
      if (await File(primary).exists()) {
        return primary;
      }
    } catch (_) {}

    // フォールバック: パッケージルートからの参照（同一パス）
    final fallback = primary;
    try {
      if (await File(fallback).exists()) {
        return fallback;
      }
    } catch (_) {}
    // いずれも無ければ primary を返す（後段でユーザー選択可能）
    return primary;
  }

  // テンプレートパスを取得（デフォルト値または保存された値）
  static Future<String> getTemplatePath() async {
    try {
      final prefs = await _getPreferences();
      if (prefs == null) {
        return await _defaultTemplatePath;
      }
      
      final savedPath = prefs.getString(_templatePathKey);
      if (savedPath != null && savedPath.isNotEmpty) {
        return savedPath;
      }
      return await _defaultTemplatePath;
    } catch (e) {
      print('テンプレートパス取得エラー: $e');
      return await _defaultTemplatePath;
    }
  }

  // テンプレートパスを保存
  static Future<void> setTemplatePath(String path) async {
    try {
      final prefs = await _getPreferences();
      if (prefs != null) {
        await prefs.setString(_templatePathKey, path);
      }
    } catch (e) {
      print('テンプレートパス保存エラー: $e');
    }
  }

  // 出力先パスを取得
  static Future<String> getOutputPath() async {
    try {
      final prefs = await _getPreferences();
      if (prefs == null) {
        return '';
      }
      return prefs.getString(_outputPathKey) ?? '';
    } catch (e) {
      print('出力先パス取得エラー: $e');
      return '';
    }
  }

  // 出力先パスを保存
  static Future<void> setOutputPath(String path) async {
    try {
      final prefs = await _getPreferences();
      if (prefs != null) {
        await prefs.setString(_outputPathKey, path);
      }
    } catch (e) {
      print('出力先パス保存エラー: $e');
    }
  }

  // 従業員名を取得
  static Future<String> getEmployeeName() async {
    try {
      final prefs = await _getPreferences();
      if (prefs == null) {
        return '';
      }
      return prefs.getString(_employeeNameKey) ?? '';
    } catch (e) {
      print('従業員名取得エラー: $e');
      return '';
    }
  }

  // 従業員名を保存
  static Future<void> setEmployeeName(String name) async {
    try {
      final prefs = await _getPreferences();
      if (prefs != null) {
        await prefs.setString(_employeeNameKey, name);
      }
    } catch (e) {
      print('従業員名保存エラー: $e');
    }
  }

  // デフォルトの出力先ディレクトリを取得
  static Future<String> getDefaultOutputDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'Kinten_Output');
    } catch (e) {
      print('デフォルト出力ディレクトリ取得エラー: $e');
      // フォールバック: プロジェクトルートのoutputディレクトリ
      final currentDir = Directory.current.path;
      String projectRoot;
      
      if (currentDir.contains('frontend${path.separator}build${path.separator}windows${path.separator}x64${path.separator}runner${path.separator}Release')) {
        final releaseDir = Directory(currentDir);
        final runnerDir = releaseDir.parent;
        final x64Dir = runnerDir.parent;
        final windowsDir = x64Dir.parent;
        final buildDir = windowsDir.parent;
        final frontendDir = buildDir.parent;
        projectRoot = frontendDir.parent.path;
      } else if (currentDir.endsWith('frontend') || currentDir.endsWith('frontend${path.separator}')) {
        projectRoot = Directory(currentDir).parent.path;
      } else {
        projectRoot = currentDir;
      }
      
      return path.join(projectRoot, 'output');
    }
  }

  // デフォルトテンプレートファイルが存在するかチェック
  static Future<bool> isDefaultTemplateAvailable() async {
    try {
      final templatePath = await _defaultTemplatePath;
      final file = File(templatePath);
      return await file.exists();
    } catch (e) {
      print('テンプレートファイル存在チェックエラー: $e');
      return false;
    }
  }

  // 設定をリセット
  static Future<void> resetSettings() async {
    try {
      final prefs = await _getPreferences();
      if (prefs != null) {
        await prefs.remove(_templatePathKey);
        await prefs.remove(_outputPathKey);
        await prefs.remove(_employeeNameKey);
      }
    } catch (e) {
      print('設定リセットエラー: $e');
    }
  }
} 