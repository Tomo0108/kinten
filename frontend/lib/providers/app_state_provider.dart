import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../services/settings_service.dart';
import '../services/file_service.dart';

enum AppStatus {
  idle,
  processing,
  success,
  error,
}

class AppState {
  final String csvPath;
  final String templatePath;
  final String outputPath;
  final String employeeName;
  final AppStatus status;
  final String statusMessage;
  final String? errorMessage;
  final bool isLoading;

  AppState({
    this.csvPath = '',
    this.templatePath = '',
    this.outputPath = '',
    this.employeeName = '',
    this.status = AppStatus.idle,
    this.statusMessage = '',
    this.errorMessage,
    this.isLoading = false,
  });

  AppState copyWith({
    String? csvPath,
    String? templatePath,
    String? outputPath,
    String? employeeName,
    AppStatus? status,
    String? statusMessage,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AppState(
      csvPath: csvPath ?? this.csvPath,
      templatePath: templatePath ?? this.templatePath,
      outputPath: outputPath ?? this.outputPath,
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState()) {
    _loadSettings();
  }

  // 設定を読み込み
  Future<void> _loadSettings() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final templatePath = await SettingsService.getTemplatePath();
      final outputPath = await SettingsService.getOutputPath();
      final employeeName = await SettingsService.getEmployeeName();
      
      state = state.copyWith(
        templatePath: templatePath,
        outputPath: outputPath,
        employeeName: employeeName,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('設定読み込みエラー: $e');
    }
  }

  void setCsvPath(String path) {
    state = state.copyWith(csvPath: path);
  }

  Future<void> setEmployeeName(String name) async {
    state = state.copyWith(employeeName: name);
    // 設定を永続化
    await SettingsService.setEmployeeName(name);
  }

  Future<void> setTemplatePath(String path) async {
    state = state.copyWith(templatePath: path);
    // 設定を永続化
    await SettingsService.setTemplatePath(path);
  }

  Future<void> setOutputPath(String path) async {
    state = state.copyWith(outputPath: path);
    // 設定を永続化
    await SettingsService.setOutputPath(path);
  }

  void setStatus(AppStatus status, String message) {
    state = state.copyWith(
      status: status,
      statusMessage: message,
    );
  }

  void setError(String errorMessage) {
    state = state.copyWith(
      status: AppStatus.error,
      statusMessage: 'エラーが発生しました',
      errorMessage: errorMessage,
    );
  }

  void resetStatus() {
    state = state.copyWith(
      status: AppStatus.idle,
      statusMessage: '',
      errorMessage: null,
    );
  }

  // 出力フォルダを開く
  Future<void> openOutputFolder() async {
    if (state.outputPath.isNotEmpty) {
      final success = await FileService.openFolder(state.outputPath);
      if (!success) {
        setError('フォルダを開けませんでした: ${state.outputPath}');
      }
    }
  }

  Future<void> processFiles() async {
    try {
      // 処理開始
      setStatus(AppStatus.processing, 'ファイル処理中...');

      // Pythonバックエンドとの連携処理
      final result = await _callPythonBackend();
      
      if (result['success']) {
        // 成功
        setStatus(AppStatus.success, '変換が完了しました！');
        
        // 出力フォルダを自動的に開く
        print('=== フォルダ自動開き処理開始 ===');
        print('Result: $result');
        
        if (result['output_folder'] != null) {
          final outputFolder = result['output_folder'];
          print('Opening output folder: $outputFolder');
          print('Output folder type: ${outputFolder.runtimeType}');
          print('Output folder length: ${outputFolder.length}');
          
          // パスの詳細確認
          final outputDir = Directory(outputFolder);
          print('Directory object created: ${outputDir.path}');
          print('Directory absolute path: ${outputDir.absolute.path}');
          
          if (await outputDir.exists()) {
            print('Output folder exists, attempting to open...');
            print('Using absolute path: ${outputDir.absolute.path}');
            final success = await FileService.openFolder(outputDir.absolute.path);
            if (success) {
              print('Successfully opened output folder: ${outputDir.absolute.path}');
            } else {
              print('Failed to open output folder: ${outputDir.absolute.path}');
            }
          } else {
            print('Output folder does not exist: $outputFolder');
            print('Trying with absolute path: ${outputDir.absolute.path}');
            if (await outputDir.absolute.exists()) {
              print('Absolute path exists, attempting to open...');
              final success = await FileService.openFolder(outputDir.absolute.path);
              if (success) {
                print('Successfully opened output folder with absolute path: ${outputDir.absolute.path}');
              } else {
                print('Failed to open output folder with absolute path: ${outputDir.absolute.path}');
              }
            } else {
              print('Absolute path also does not exist: ${outputDir.absolute.path}');
            }
          }
        } else {
          print('No output folder in result: $result');
        }
        print('=== フォルダ自動開き処理完了 ===');
      } else {
        setError(result['error'] ?? '処理に失敗しました');
      }
      
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<Map<String, dynamic>> _callPythonBackend() async {
    try {
      // プロジェクトルートを取得
      final currentDir = Directory.current.path;
      print('Current directory (Python backend): $currentDir'); // デバッグログ
      
      String projectRoot;
      // Flutterアプリがビルドされて実行される場合のパス処理
      if (currentDir.contains('frontend\\build\\windows\\x64\\runner\\Release')) {
        // Releaseディレクトリから4階層上に移動してプロジェクトルートを取得
        final releaseDir = Directory(currentDir);
        final runnerDir = releaseDir.parent;
        final x64Dir = runnerDir.parent;
        final windowsDir = x64Dir.parent;
        final buildDir = windowsDir.parent;
        final frontendDir = buildDir.parent;
        projectRoot = frontendDir.parent.path;
        print('Project root (from Release - Python): $projectRoot'); // デバッグログ
      } else if (currentDir.endsWith('frontend') || currentDir.endsWith('frontend\\')) {
        projectRoot = Directory(currentDir).parent.path;
        print('Project root (from frontend - Python): $projectRoot'); // デバッグログ
      } else {
        projectRoot = currentDir;
        print('Project root (current - Python): $projectRoot'); // デバッグログ
      }
      
      // ファイル存在チェック
      final csvFile = File(state.csvPath);
      final templateFile = File(state.templatePath);
      
      print('Checking CSV file: ${state.csvPath}');
      print('CSV file exists: ${await csvFile.exists()}');
      print('Checking template file: ${state.templatePath}');
      print('Template file exists: ${await templateFile.exists()}');
      
      if (!await csvFile.exists()) {
        return {
          'success': false,
          'error': 'CSVファイルが見つかりません: ${state.csvPath}',
        };
      }
      
      if (!await templateFile.exists()) {
        return {
          'success': false,
          'error': 'テンプレートファイルが見つかりません: ${state.templatePath}',
        };
      }
      
      // ファイルパスをエスケープ（より安全な方法）
      final csvPath = state.csvPath.replaceAll('\\', '/').replaceAll('"', '\\"');
      final templatePath = state.templatePath.replaceAll('\\', '/').replaceAll('"', '\\"');
      final outputPath = '$projectRoot/output'.replaceAll('\\', '/').replaceAll('"', '\\"');
      final employeeName = state.employeeName.replaceAll('"', '\\"').replaceAll("'", "\\'");
      
      // デバッグログ
      print('Processing files:');
      print('CSV Path: $csvPath');
      print('Template Path: $templatePath');
      print('Output Path: $outputPath');
      print('Employee Name: $employeeName');
      print('Project Root: $projectRoot');
      
      // Pythonスクリプトの実行（プロジェクトルートから実行）
      final pythonCode = '''
import sys
import os
print(f"Python version: {sys.version}")
print(f"Current working directory: {os.getcwd()}")
print(f"Project root: {r"$projectRoot"}")

# ファイル存在チェック
csv_path = r"$csvPath"
template_path = r"$templatePath"
output_path = r"$outputPath"

print(f"CSV path: {csv_path}")
print(f"CSV exists: {os.path.exists(csv_path)}")
if not os.path.exists(csv_path):
    print(f"❌ CSV file not found: {csv_path}")
    exit(1)

print(f"Template path: {template_path}")
print(f"Template exists: {os.path.exists(template_path)}")
if not os.path.exists(template_path):
    print(f"❌ Template file not found: {template_path}")
    exit(1)

print(f"Output path: {output_path}")
print(f"Output exists: {os.path.exists(output_path)}")
if not os.path.exists(output_path):
    print(f"Creating output directory: {output_path}")
    os.makedirs(output_path, exist_ok=True)

# バックエンドディレクトリの存在チェック
backend_path = os.path.join(r"$projectRoot", "backend")
print(f"Backend path: {backend_path}")
print(f"Backend exists: {os.path.exists(backend_path)}")

# バックエンドディレクトリの内容を確認
if os.path.exists(backend_path):
    print(f"Backend directory contents:")
    for file in os.listdir(backend_path):
        print(f"  - {file}")
else:
    print(f"Backend directory does not exist!")

# バックエンドディレクトリをPythonパスに追加
sys.path.insert(0, backend_path)
print(f"Added {backend_path} to sys.path")
print(f"Current sys.path: {sys.path}")

# 必要なパッケージのインポート確認
try:
    import pandas as pd
    print("✅ pandas imported successfully")
except ImportError as e:
    print(f"❌ pandas import error: {e}")
    exit(1)

try:
    import openpyxl
    print("✅ openpyxl imported successfully")
except ImportError as e:
    print(f"❌ openpyxl import error: {e}")
    exit(1)

try:
    from main_processor import KintenProcessor
    print("✅ Successfully imported KintenProcessor")
    
    processor = KintenProcessor()
    print("✅ Successfully created KintenProcessor instance")
    
    print("Starting file processing...")
    result = processor.process_files(
        csv_path,
        template_path,
        output_path,
        r"$employeeName"
    )
    
    print(f"Processing result: {result}")
    
    if result["success"]:
        print(f"✅ Processing completed successfully!")
        print(f"SUCCESS:{result['output_folder']}")
        exit(0)
    else:
        print(f"❌ Processing failed: {result['error']}")
        print(f"ERROR:{result['error']}")
        exit(1)
        
except ImportError as e:
    print(f"ERROR:Import error: {str(e)}")
    print(f"Import error details:")
    import traceback
    traceback.print_exc()
    exit(1)
except Exception as e:
    print(f"ERROR:Exception occurred: {str(e)}")
    import traceback
    traceback.print_exc()
    exit(1)
''';
      
      print('Executing Python command in directory: $projectRoot');
      print('Python code length: ${pythonCode.length}');
      
      // 一時ファイルにPythonコードを保存して実行（より安全な方法）
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/kinten_script_${DateTime.now().millisecondsSinceEpoch}.py');
      
      // デバッグ用：Pythonコードをファイルに保存
      final debugFile = File('${projectRoot}/debug_python_code.py');
      await debugFile.writeAsString(pythonCode);
      print('Debug Python code saved to: ${debugFile.path}');
      
      try {
        await tempFile.writeAsString(pythonCode);
        print('Python script saved to: ${tempFile.path}');
        
        // 仮想環境のPythonを使用（絶対パスで指定）
        final pythonCommand = Platform.isWindows 
            ? '${projectRoot}\\venv\\Scripts\\python.exe'
            : '${projectRoot}/venv/bin/python';
        print('Using Python command: $pythonCommand');
        
        // Python実行時の環境変数を設定
        final env = <String, String>{
          'PYTHONIOENCODING': 'utf-8',
          'PYTHONUTF8': '1',
          'PYTHONPATH': '${projectRoot}\\backend',
        };
        
        final result = await Process.run(pythonCommand, [
          tempFile.path,
        ], workingDirectory: projectRoot, environment: env);
        
        print('Python process completed');
        print('Exit code: ${result.exitCode}');
        print('Stdout: ${result.stdout}');
        print('Stderr: ${result.stderr}');
        
        // 一時ファイルを削除
        await tempFile.delete();
        
        return _handlePythonResult(result);
      } catch (e) {
        print('Process.run error: $e');
        // 一時ファイルを削除（エラー時も）
        try {
          await tempFile.delete();
        } catch (_) {}
        return {
          'success': false,
          'error': 'Pythonプロセスの実行に失敗しました: $e',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
    }
    
    Map<String, dynamic> _handlePythonResult(ProcessResult result) {
      if (result.exitCode == 0) {
        // 成功時の処理
        final output = result.stdout.toString().trim();
        print('Python stdout: $output'); // デバッグログ
        
        // 複数行の出力からSUCCESS:で始まる行を探す
        final lines = output.split('\n');
        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.startsWith('SUCCESS:')) {
            final outputFolder = trimmedLine.substring(8); // 'SUCCESS:' を除去
            print('Found SUCCESS line: $trimmedLine');
            print('Output folder: $outputFolder');
            return {
              'success': true,
              'output_folder': outputFolder,
            };
          }
        }
        
        print('No SUCCESS line found in output');
        return {'success': true};
      } else {
        // エラー時の処理
        final output = result.stdout.toString().trim();
        final stderr = result.stderr.toString().trim();
        print('Python stdout: $output'); // デバッグログ
        print('Python stderr: $stderr'); // デバッグログ
        
        String errorMessage = '処理に失敗しました';
        
        // 複数行の出力からERROR:で始まる行を探す
        final lines = output.split('\n');
        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.startsWith('ERROR:')) {
            errorMessage = trimmedLine.substring(6); // 'ERROR:' を除去
            break;
          }
        }
        
        if (errorMessage == '処理に失敗しました' && stderr.isNotEmpty) {
          errorMessage = stderr;
        }
        
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
); 