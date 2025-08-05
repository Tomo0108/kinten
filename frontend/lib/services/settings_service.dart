import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class SettingsService {
  static const String _templatePathKey = 'template_path';
  static const String _outputPathKey = 'output_path';
  static const String _employeeNameKey = 'employee_name';
  
  // デフォルトテンプレートパスを動的に解決
  static Future<String> get _defaultTemplatePath async {
    // プロジェクトルートを取得
    final currentDir = Directory.current.path;
    String projectRoot;
    
    // Flutterアプリがビルドされて実行される場合のパス処理
    if (currentDir.contains('frontend${path.separator}build${path.separator}windows${path.separator}x64${path.separator}runner${path.separator}Release')) {
      // Releaseディレクトリから4階層上に移動してプロジェクトルートを取得
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
    
    // プラットフォーム固有のパス区切り文字を使用
    return path.join(projectRoot, 'templates', '勤怠表雛形_2025年版.xlsx');
  }

  // テンプレートパスを取得（デフォルト値または保存された値）
  static Future<String> getTemplatePath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_templatePathKey);
    if (savedPath != null && savedPath.isNotEmpty) {
      return savedPath;
    }
    return await _defaultTemplatePath;
  }

  // テンプレートパスを保存
  static Future<void> setTemplatePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_templatePathKey, path);
  }

  // 出力先パスを取得
  static Future<String> getOutputPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_outputPathKey) ?? '';
  }

  // 出力先パスを保存
  static Future<void> setOutputPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_outputPathKey, path);
  }

  // 従業員名を取得
  static Future<String> getEmployeeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeNameKey) ?? '';
  }

  // 従業員名を保存
  static Future<void> setEmployeeName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeeNameKey, name);
  }

  // デフォルトの出力先ディレクトリを取得
  static Future<String> getDefaultOutputDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'Kinten_Output');
  }

  // デフォルトテンプレートファイルが存在するかチェック
  static Future<bool> isDefaultTemplateAvailable() async {
    try {
      final templatePath = await _defaultTemplatePath;
      final file = File(templatePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // 設定をリセット
  static Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_templatePathKey);
    await prefs.remove(_outputPathKey);
    await prefs.remove(_employeeNameKey);
  }
} 