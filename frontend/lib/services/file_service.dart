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

      // Windows環境ではexplorer.exeを使用
      if (Platform.isWindows) {
        print('Windows環境でexplorer.exeを使用');
        
        // 方法1: explorer.exe（推奨）
        try {
          print('explorer.exe実行中...');
          print('実行コマンド: explorer.exe $folderPath');
          
          // パスの正規化
          final normalizedPath = folderPath.replaceAll('/', '\\');
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
        }
        
        // 方法2: explorer.exe with /select（フォールバック）
        try {
          print('explorer.exe with /select実行中...');
          final result = await Process.run('explorer.exe', ['/select,', folderPath]);
          print('Explorer /select result: ${result.exitCode}');
          print('Explorer /select stdout: ${result.stdout}');
          print('Explorer /select stderr: ${result.stderr}');
          
          print('Explorer /select実行完了（exit code: ${result.exitCode}）');
          return true;
        } catch (e) {
          print('Explorer /select実行エラー: $e');
        }
        
        // 方法3: url_launcherフォールバック
        print('url_launcherフォールバック実行中...');
        final uri = Uri.file(folderPath);
        if (await canLaunchUrl(uri)) {
          final launchResult = await launchUrl(uri);
          print('url_launcher結果: $launchResult');
          return launchResult;
        }
        print('url_launcherも失敗');
        return false;
      } else {
        // その他のプラットフォームではurl_launcherを使用
        print('その他のプラットフォームでurl_launcherを使用');
        final uri = Uri.file(folderPath);
        if (await canLaunchUrl(uri)) {
          final launchResult = await launchUrl(uri);
          print('url_launcher結果: $launchResult');
          return launchResult;
        }
        return false;
      }
    } catch (e) {
      print('フォルダを開くエラー: $e');
      return false;
    } finally {
      print('=== FileService.openFolder 完了 ===');
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

  // Excelファイルを選択（複数選択可）
  static Future<List<String>?> pickExcelFiles() async {
    try {
      print('=== Excelファイル選択開始 ===');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: true,
        withData: false,
        withReadStream: false,
        // プレビュー機能を無効化してパフォーマンスを向上
        lockParentWindow: true,
        // ファイル選択ダイアログのタイトル
        dialogTitle: 'Excelファイルを選択（複数選択可）',
      );
      
      print('FilePicker結果: ${result?.files.length ?? 0}個のファイル');
      
      if (result != null && result.files.isNotEmpty) {
        final filePaths = result.files
            .where((file) => file.path != null)
            .map((file) => file.path!)
            .toList();
        
        print('選択されたファイルパス: $filePaths');
        return filePaths;
      }
      
      print('ファイルが選択されませんでした');
      return null;
    } catch (e) {
      print('Excelファイル選択エラー: $e');
      return null;
    } finally {
      print('=== Excelファイル選択完了 ===');
    }
  }
} 