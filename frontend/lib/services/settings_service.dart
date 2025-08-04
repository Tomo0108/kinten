import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SettingsService {
  static const String _templatePathKey = 'template_path';
  static const String _outputPathKey = 'output_path';
  static const String _employeeNameKey = 'employee_name';
  static const String _pdfOutputFolderKey = 'pdf_output_folder';
  static const String _defaultTemplatePath = 'templates/勤怠表雛形_2025年版.xlsx';

  // テンプレートパスを取得（デフォルト値または保存された値）
  static Future<String> getTemplatePath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_templatePathKey);
    
    if (savedPath != null && savedPath.isNotEmpty) {
      return savedPath;
    }
    
    // デフォルトパスを使用する場合は絶対パスに変換
    final projectRoot = await getProjectRoot();
    return '$projectRoot/$_defaultTemplatePath';
  }

  // テンプレートパスを保存
  static Future<void> setTemplatePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_templatePathKey, path);
  }

  // 出力先パスを取得
  static Future<String> getOutputPath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_outputPathKey);
    
    if (savedPath != null && savedPath.isNotEmpty) {
      return savedPath;
    }
    
    // デフォルトの出力先を使用
    final projectRoot = await getProjectRoot();
    return '$projectRoot/output';
  }

  // 出力先パスを保存
  static Future<void> setOutputPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_outputPathKey, path);
  }

  // デフォルトの出力先ディレクトリを取得
  static Future<String> getDefaultOutputDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/Kinten_Output';
  }

  // プロジェクトルートの絶対パスを取得
  static Future<String> getProjectRoot() async {
    final currentDir = Directory.current.path;
    print('Current directory: $currentDir'); // デバッグログ
    
    // Flutterアプリがビルドされて実行される場合のパス処理
    if (currentDir.contains('frontend\\build\\windows\\x64\\runner\\Release')) {
      // Releaseディレクトリから4階層上に移動してプロジェクトルートを取得
      final releaseDir = Directory(currentDir);
      final runnerDir = releaseDir.parent;
      final x64Dir = runnerDir.parent;
      final windowsDir = x64Dir.parent;
      final buildDir = windowsDir.parent;
      final frontendDir = buildDir.parent;
      final projectRoot = frontendDir.parent;
      print('Project root (from Release): ${projectRoot.path}'); // デバッグログ
      return projectRoot.path;
    }
    
    // 開発時のパス処理
    if (currentDir.endsWith('frontend') || currentDir.endsWith('frontend\\')) {
      final projectRoot = Directory(currentDir).parent.path;
      print('Project root (from frontend): $projectRoot'); // デバッグログ
      return projectRoot;
    }
    
    print('Project root (current): $currentDir'); // デバッグログ
    return currentDir;
  }

  // デフォルトテンプレートファイルが存在するかチェック
  static Future<bool> isDefaultTemplateAvailable() async {
    try {
      final projectRoot = await getProjectRoot();
      final templatePath = '$projectRoot/$_defaultTemplatePath';
      final file = File(templatePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
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

  // PDF出力フォルダを取得
  static Future<String> getPdfOutputFolder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_pdfOutputFolderKey);
    
    if (savedPath != null && savedPath.isNotEmpty) {
      return savedPath;
    }
    
    // デフォルトの出力先を使用
    final projectRoot = await getProjectRoot();
    return '$projectRoot/output';
  }

  // PDF出力フォルダを保存
  static Future<void> setPdfOutputFolder(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pdfOutputFolderKey, path);
  }

  // 設定をリセット
  static Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_templatePathKey);
    await prefs.remove(_outputPathKey);
    await prefs.remove(_employeeNameKey);
    await prefs.remove(_pdfOutputFolderKey);
  }
} 