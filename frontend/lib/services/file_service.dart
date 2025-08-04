import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class FileService {
  // フォルダを開く
  static Future<bool> openFolder(String folderPath) async {
    print('=== FileService.openFolder 開始 ===');
    print('フォルダパス: $folderPath');
    
    try {
      final directory = Directory(folderPath);
      if (!await directory.exists()) {
        print('フォルダが存在しません: $folderPath');
        return false;
      }

      print('フォルダが存在します: $folderPath');

      // プラットフォーム別のフォルダオープン処理
      if (Platform.isWindows) {
        return await _openFolderWindows(folderPath);
      } else if (Platform.isMacOS) {
        return await _openFolderMacOS(folderPath);
      } else if (Platform.isLinux) {
        return await _openFolderLinux(folderPath);
      } else {
        // その他のプラットフォームではurl_launcherを使用
        return await _openFolderGeneric(folderPath);
      }
    } catch (e) {
      print('フォルダを開くエラー: $e');
      return false;
    } finally {
      print('=== FileService.openFolder 完了 ===');
    }
  }

  // Windows用フォルダオープン
  static Future<bool> _openFolderWindows(String folderPath) async {
    print('Windows環境でexplorer.exeを使用');
    
    // 方法1: explorer.exe（推奨）
    try {
      print('explorer.exe実行中...');
      print('実行コマンド: explorer.exe $folderPath');
      
      // パスの正規化（WindowsではBackslashを使用）
      final normalizedPath = path.normalize(folderPath).replaceAll('/', '\\');
      print('正規化されたパス: $normalizedPath');
      
      final result = await Process.run('explorer.exe', [normalizedPath]);
      print('Explorer result: ${result.exitCode}');
      print('Explorer stdout: ${result.stdout}');
      print('Explorer stderr: ${result.stderr}');
      
      // explorer.exeは通常exit code 1を返すが、正常に動作する
      print('Explorer実行完了（exit code: ${result.exitCode}）');
      return true; // explorer.exeは常に成功とみなす
    } catch (e) {
      print('Explorer実行エラー: $e');
      // フォールバックとしてurl_launcherを使用
      return await _openFolderGeneric(folderPath);
    }
  }

  // macOS用フォルダオープン
  static Future<bool> _openFolderMacOS(String folderPath) async {
    print('macOS環境でopenコマンドを使用');
    
    try {
      print('open実行中...');
      print('実行コマンド: open $folderPath');
      
      final result = await Process.run('open', [folderPath]);
      print('Open result: ${result.exitCode}');
      print('Open stdout: ${result.stdout}');
      print('Open stderr: ${result.stderr}');
      
      if (result.exitCode == 0) {
        print('Open実行完了');
        return true;
      } else {
        print('Openコマンドが失敗: ${result.exitCode}');
        return await _openFolderGeneric(folderPath);
      }
    } catch (e) {
      print('Open実行エラー: $e');
      // フォールバックとしてurl_launcherを使用
      return await _openFolderGeneric(folderPath);
    }
  }

  // Linux用フォルダオープン
  static Future<bool> _openFolderLinux(String folderPath) async {
    print('Linux環境でxdg-openコマンドを使用');
    
    try {
      print('xdg-open実行中...');
      print('実行コマンド: xdg-open $folderPath');
      
      final result = await Process.run('xdg-open', [folderPath]);
      print('xdg-open result: ${result.exitCode}');
      print('xdg-open stdout: ${result.stdout}');
      print('xdg-open stderr: ${result.stderr}');
      
      if (result.exitCode == 0) {
        print('xdg-open実行完了');
        return true;
      } else {
        print('xdg-openコマンドが失敗: ${result.exitCode}');
        return await _openFolderGeneric(folderPath);
      }
    } catch (e) {
      print('xdg-open実行エラー: $e');
      // フォールバックとしてurl_launcherを使用
      return await _openFolderGeneric(folderPath);
    }
  }

  // 汎用フォルダオープン（url_launcher使用）
  static Future<bool> _openFolderGeneric(String folderPath) async {
    print('url_launcherフォールバック実行中...');
    try {
      final uri = Uri.file(folderPath);
      if (await canLaunchUrl(uri)) {
        final launchResult = await launchUrl(uri);
        print('url_launcher結果: $launchResult');
        return launchResult;
      }
      print('url_launcherも失敗');
      return false;
    } catch (e) {
      print('url_launcherエラー: $e');
      return false;
    }
  }

  // ファイルが存在するかチェック
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // ディレクトリが存在するかチェック
  static Future<bool> directoryExists(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      return await directory.exists();
    } catch (e) {
      return false;
    }
  }

  // ファイルサイズを取得
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ファイル名を取得
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  // ディレクトリ名を取得
  static String getDirectoryName(String dirPath) {
    return path.basename(dirPath);
  }

  // ファイルの拡張子を取得
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  // ファイルがCSVかチェック
  static bool isCsvFile(String filePath) {
    return getFileExtension(filePath) == '.csv';
  }

  // ファイルがExcelかチェック
  static bool isExcelFile(String filePath) {
    final ext = getFileExtension(filePath);
    return ext == '.xlsx' || ext == '.xls';
  }

  // 出力ディレクトリを作成
  static Future<bool> createOutputDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return true;
    } catch (e) {
      print('ディレクトリ作成エラー: $e');
      return false;
    }
  }

  // ファイルの最終更新日時を取得
  static Future<DateTime?> getFileLastModified(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.modified;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // フォルダを選択
  static Future<String?> pickDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      return selectedDirectory;
    } catch (e) {
      print('フォルダ選択エラー: $e');
      return null;
    }
  }
} 