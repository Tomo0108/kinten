import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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
    return path.join(projectRoot, _defaultTemplatePath);
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
    return path.join(projectRoot, 'output');
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
    print('Current directory: $currentDir');
    
    // ビルドディレクトリのパターンを定義（プラットフォームに依存しない）
    final buildPatterns = [
      // Windows
      path.join('frontend', 'build', 'windows', 'x64', 'runner', 'Release'),
      // macOS
      path.join('frontend', 'build', 'macos', 'Build', 'Products', 'Release'),
      // Linux
      path.join('frontend', 'build', 'linux', 'x64', 'release', 'bundle'),
    ];
    
    // 現在のディレクトリがビルドディレクトリ配下かチェック
    for (final pattern in buildPatterns) {
      if (currentDir.contains(pattern)) {
        // ビルドディレクトリから適切な階層数だけ上に移動
        var projectDir = Directory(currentDir);
        
        // 'Release', 'bundle' から 'frontend' まで遡る
        while (projectDir.path != projectDir.parent.path) {
          if (path.basename(projectDir.path) == 'frontend') {
            final projectRoot = projectDir.parent.path;
            print('Project root (from build directory): $projectRoot');
            return projectRoot;
          }
          projectDir = projectDir.parent;
        }
        break;
      }
    }
    
    // frontendディレクトリで実行されている場合
    if (path.basename(currentDir) == 'frontend') {
      final projectRoot = Directory(currentDir).parent.path;
      print('Project root (from frontend): $projectRoot');
      return projectRoot;
    }
    
    // その他の場合は現在のディレクトリを使用
    print('Project root (current): $currentDir');
    return currentDir;
  }

  // デフォルトテンプレートファイルが存在するかチェック
  static Future<bool> isDefaultTemplateAvailable() async {
    try {
      final projectRoot = await getProjectRoot();
      final templatePath = path.join(projectRoot, _defaultTemplatePath);
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
    return path.join(projectRoot, 'output');
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