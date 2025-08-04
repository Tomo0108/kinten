import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/file_service.dart';
import '../services/settings_service.dart';
import 'package:path/path.dart' as path;

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
  final bool isLoading;
  
  // 自動転記機能用の状態
  final AppStatus autoTransferStatus;
  final String autoTransferStatusMessage;
  final String? autoTransferErrorMessage;
  
  // PDF変換機能用の状態
  final String pdfInputFolder;
  final List<Map<String, dynamic>> excelFiles;
  final List<String> selectedFiles;
  final bool selectAllFiles;
  final AppStatus pdfConversionStatus;
  final String pdfConversionStatusMessage;
  final String? pdfConversionErrorMessage;

  AppState({
    this.csvPath = '',
    this.templatePath = '',
    this.outputPath = '',
    this.employeeName = '',
    this.isLoading = false,
    this.autoTransferStatus = AppStatus.idle,
    this.autoTransferStatusMessage = '',
    this.autoTransferErrorMessage,
    this.pdfInputFolder = '',
    this.excelFiles = const [],
    this.selectedFiles = const [],
    this.selectAllFiles = false,
    this.pdfConversionStatus = AppStatus.idle,
    this.pdfConversionStatusMessage = '',
    this.pdfConversionErrorMessage,
  });

  AppState copyWith({
    String? csvPath,
    String? templatePath,
    String? outputPath,
    String? employeeName,
    bool? isLoading,
    AppStatus? autoTransferStatus,
    String? autoTransferStatusMessage,
    String? autoTransferErrorMessage,
    String? pdfInputFolder,
    List<Map<String, dynamic>>? excelFiles,
    List<String>? selectedFiles,
    bool? selectAllFiles,
    AppStatus? pdfConversionStatus,
    String? pdfConversionStatusMessage,
    String? pdfConversionErrorMessage,
  }) {
    return AppState(
      csvPath: csvPath ?? this.csvPath,
      templatePath: templatePath ?? this.templatePath,
      outputPath: outputPath ?? this.outputPath,
      employeeName: employeeName ?? this.employeeName,
      isLoading: isLoading ?? this.isLoading,
      autoTransferStatus: autoTransferStatus ?? this.autoTransferStatus,
      autoTransferStatusMessage: autoTransferStatusMessage ?? this.autoTransferStatusMessage,
      autoTransferErrorMessage: autoTransferErrorMessage ?? this.autoTransferErrorMessage,
      pdfInputFolder: pdfInputFolder ?? this.pdfInputFolder,
      excelFiles: excelFiles ?? this.excelFiles,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      selectAllFiles: selectAllFiles ?? this.selectAllFiles,
      pdfConversionStatus: pdfConversionStatus ?? this.pdfConversionStatus,
      pdfConversionStatusMessage: pdfConversionStatusMessage ?? this.pdfConversionStatusMessage,
      pdfConversionErrorMessage: pdfConversionErrorMessage ?? this.pdfConversionErrorMessage,
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

  // PDF変換機能用のメソッド
  void setPdfInputFolder(String path) {
    state = state.copyWith(pdfInputFolder: path);
  }



  void setExcelFiles(List<Map<String, dynamic>> files) {
    state = state.copyWith(excelFiles: files);
  }

  void setSelectedFiles(List<String> files) {
    state = state.copyWith(selectedFiles: files);
  }

  void setSelectAllFiles(bool selectAll) {
    state = state.copyWith(selectAllFiles: selectAll);
  }

  void toggleFileSelection(String filePath) {
    final currentSelected = List<String>.from(state.selectedFiles);
    if (currentSelected.contains(filePath)) {
      currentSelected.remove(filePath);
    } else {
      currentSelected.add(filePath);
    }
    state = state.copyWith(selectedFiles: currentSelected);
  }

  void selectAllExcelFiles() {
    final allPaths = state.excelFiles.map((file) => file['path'] as String).toList();
    state = state.copyWith(selectedFiles: allPaths, selectAllFiles: true);
  }

  void deselectAllExcelFiles() {
    state = state.copyWith(selectedFiles: [], selectAllFiles: false);
  }

  // 自動転記機能用のステータス管理
  void setAutoTransferStatus(AppStatus status, String message) {
    state = state.copyWith(
      autoTransferStatus: status,
      autoTransferStatusMessage: message,
    );
  }

  void setAutoTransferError(String errorMessage) {
    state = state.copyWith(
      autoTransferStatus: AppStatus.error,
      autoTransferStatusMessage: 'エラーが発生しました',
      autoTransferErrorMessage: errorMessage,
    );
  }

  void resetAutoTransferStatus() {
    state = state.copyWith(
      autoTransferStatus: AppStatus.idle,
      autoTransferStatusMessage: '',
      autoTransferErrorMessage: null,
    );
  }

  // PDF変換機能用のステータス管理
  void setPdfConversionStatus(AppStatus status, String message) {
    state = state.copyWith(
      pdfConversionStatus: status,
      pdfConversionStatusMessage: message,
    );
  }

  void setPdfConversionError(String errorMessage) {
    state = state.copyWith(
      pdfConversionStatus: AppStatus.error,
      pdfConversionStatusMessage: 'エラーが発生しました',
      pdfConversionErrorMessage: errorMessage,
    );
  }

  void resetPdfConversionStatus() {
    state = state.copyWith(
      pdfConversionStatus: AppStatus.idle,
      pdfConversionStatusMessage: '',
      pdfConversionErrorMessage: null,
    );
  }

  // 後方互換性のためのメソッド（削除予定）
  void setStatus(AppStatus status, String message) {
    setAutoTransferStatus(status, message);
  }

  void setError(String errorMessage) {
    setAutoTransferError(errorMessage);
  }

  void resetStatus() {
    resetAutoTransferStatus();
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
      setAutoTransferStatus(AppStatus.processing, 'ファイル処理中...');

      // Pythonバックエンドとの連携処理
      final result = await _callPythonBackend();
      
      if (result['success']) {
        // 成功
        setAutoTransferStatus(AppStatus.success, '変換が完了しました！');
        
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
        setAutoTransferError(result['error'] ?? '処理に失敗しました');
      }
      
    } catch (e) {
      setAutoTransferError(e.toString());
    }
  }

  // PDF変換処理
  Future<void> processPdfConversion() async {
    try {
      // 処理開始
      setPdfConversionStatus(AppStatus.processing, 'PDF変換中...');

      // Pythonバックエンドとの連携処理
      final result = await _callPdfPythonBackend();
      
      if (result['success']) {
        // 成功
        setPdfConversionStatus(AppStatus.success, 'PDF変換が完了しました！');
        
        // 出力フォルダを自動的に開く
        if (result['output_folder'] != null) {
          final outputFolder = result['output_folder'];
          final success = await FileService.openFolder(outputFolder);
          if (!success) {
            print('Failed to open PDF output folder: $outputFolder');
          }
        }
      } else {
        setPdfConversionError(result['error'] ?? 'PDF変換に失敗しました');
      }
      
    } catch (e) {
      setPdfConversionError(e.toString());
    }
  }

  // Excelファイル取得処理
  Future<void> getExcelFiles() async {
    try {
      if (state.pdfInputFolder.isEmpty) {
        setPdfConversionError('入力フォルダが指定されていません');
        return;
      }

      // フォルダの存在チェックを追加
      final folder = Directory(state.pdfInputFolder);
      if (!await folder.exists()) {
        setPdfConversionError('指定されたフォルダが存在しません: ${state.pdfInputFolder}');
        return;
      }

      setPdfConversionStatus(AppStatus.processing, 'Excelファイルを取得中...');
      
      final result = await _callGetExcelFilesBackend();
      
      print('Excel files result: $result'); // デバッグログ
      
      if (result['success']) {
        final files = List<Map<String, dynamic>>.from(result['files'] ?? []);
        print('Found ${files.length} Excel files'); // デバッグログ
        setExcelFiles(files);
        if (files.isEmpty) {
          setPdfConversionStatus(AppStatus.idle, 'フォルダ内にExcelファイルが見つかりませんでした');
        } else {
          setPdfConversionStatus(AppStatus.idle, '${files.length}個のExcelファイルが見つかりました');
        }
      } else {
        print('Excel files error: ${result['error']}'); // デバッグログ
        setPdfConversionError(result['error'] ?? 'Excelファイルの取得に失敗しました');
      }
      
    } catch (e) {
      print('Excel files exception: $e'); // デバッグログ
      setPdfConversionError('Excelファイルの取得中にエラーが発生しました: $e');
    }
  }

  Future<Map<String, dynamic>> _callPythonBackend() async {
    try {
      // プロジェクトルートを取得
      final projectRoot = _getProjectRoot();
      
      // ファイル存在チェック
      final csvFile = File(state.csvPath);
      final templateFile = File(state.templatePath);
      
      print('=== ファイル存在チェック ===');
      print('CSV Path: ${state.csvPath}');
      print('CSV file exists: ${await csvFile.exists()}');
      print('Template Path: ${state.templatePath}');
      print('Template file exists: ${await templateFile.exists()}');
      print('Employee Name: ${state.employeeName}');
      print('Output Path: ${state.outputPath}');
      print('=== ファイル存在チェック完了 ===');
      
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
      print('=== Pythonバックエンド呼び出し準備 ===');
      print('CSV Path: $csvPath');
      print('Template Path: $templatePath');
      print('Output Path: $outputPath');
      print('Employee Name: $employeeName');
      print('Project Root: $projectRoot');
      print('=== Pythonバックエンド呼び出し準備完了 ===');
      
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
        
        // システムのPythonを使用
        final pythonCommand = 'python';
        print('Using Python command: $pythonCommand');
        
        // Python実行時の環境変数を設定
        final env = <String, String>{
          'PYTHONIOENCODING': 'utf-8',
          'PYTHONUTF8': '1',
          'PYTHONPATH': '${projectRoot}\\backend',
          'PATH': '${Platform.environment['PATH']}',
        };
        
        final result = await Process.run(pythonCommand, [
          tempFile.path,
        ], workingDirectory: projectRoot, environment: env);
        
        print('=== Pythonプロセス実行結果 ===');
        print('Exit code: ${result.exitCode}');
        print('Stdout length: ${result.stdout.toString().length}');
        print('Stdout: ${result.stdout}');
        print('Stderr length: ${result.stderr.toString().length}');
        print('Stderr: ${result.stderr}');
        print('=== Pythonプロセス実行結果完了 ===');
        
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

  // PDF変換用のPythonバックエンド呼び出し
  Future<Map<String, dynamic>> _callPdfPythonBackend() async {
    try {
      // プロジェクトルートを取得
      final projectRoot = _getProjectRoot();
      
      // 出力フォルダを作成
      final outputFolderResult = await _createPdfOutputFolder(projectRoot);
      if (!outputFolderResult['success']) {
        return outputFolderResult;
      }
      
      final outputFolder = outputFolderResult['output_folder'];
      
      // PDF変換を実行
      final pythonCode = '''
import sys
import os
import json

# バックエンドディレクトリをPythonパスに追加
backend_path = os.path.join(r"$projectRoot", "backend")
sys.path.insert(0, backend_path)

try:
    from main_processor import KintenProcessor
    
    processor = KintenProcessor()
    
    excel_files = ${state.selectedFiles}
    output_folder = r"$outputFolder"
    
    result = processor.convert_excel_to_pdf(excel_files, output_folder)
    
    print(json.dumps(result, ensure_ascii=False))
    
except Exception as e:
    print(json.dumps({
        'success': False,
        'error': str(e)
    }, ensure_ascii=False))
''';
      
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/kinten_pdf_script_${DateTime.now().millisecondsSinceEpoch}.py');
      
      try {
        await tempFile.writeAsString(pythonCode);
        
        final pythonCommand = 'python';
        
        final env = <String, String>{
          'PYTHONIOENCODING': 'utf-8',
          'PYTHONUTF8': '1',
          'PYTHONPATH': '${projectRoot}\\backend',
          'PATH': '${Platform.environment['PATH']}',
        };
        
        final result = await Process.run(pythonCommand, [
          tempFile.path,
        ], workingDirectory: projectRoot, environment: env);
        
        await tempFile.delete();
        
        if (result.exitCode == 0) {
          final output = result.stdout.toString().trim();
          final jsonResult = json.decode(output);
          jsonResult['output_folder'] = outputFolder;
          return jsonResult;
        } else {
          return {
            'success': false,
            'error': result.stderr.toString().trim(),
          };
        }
      } catch (e) {
        try {
          await tempFile.delete();
        } catch (_) {}
        return {
          'success': false,
          'error': 'PDF変換プロセスの実行に失敗しました: $e',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Excelファイル取得用のPythonバックエンド呼び出し
  Future<Map<String, dynamic>> _callGetExcelFilesBackend() async {
    try {
      // プロジェクトルートを取得
      final projectRoot = _getProjectRoot();
      
      print('Project root: $projectRoot'); // デバッグログ
      print('PDF input folder: ${state.pdfInputFolder}'); // デバッグログ
      
      final pythonCode = '''
import sys
import os
import json

# 文字コード設定
import locale
print(f"Default encoding: {sys.getdefaultencoding()}")
print(f"File system encoding: {sys.getfilesystemencoding()}")
print(f"Locale encoding: {locale.getpreferredencoding()}")

print(f"Python version: {sys.version}")
print(f"Current working directory: {os.getcwd()}")
print(f"Project root: {r"$projectRoot"}")

# バックエンドディレクトリをPythonパスに追加
backend_path = os.path.join(r"$projectRoot", "backend")
print(f"Backend path: {backend_path}")
print(f"Backend exists: {os.path.exists(backend_path)}")

sys.path.insert(0, backend_path)
print(f"Added {backend_path} to sys.path")
print(f"Current sys.path: {sys.path}")

try:
    from main_processor import KintenProcessor
    print("✅ Successfully imported KintenProcessor")
    
    processor = KintenProcessor()
    print("✅ Successfully created KintenProcessor instance")
    
    folder_path = r"${state.pdfInputFolder}"
    print(f"Folder path: {folder_path}")
    print(f"Folder path type: {type(folder_path)}")
    print(f"Folder path repr: {repr(folder_path)}")
    print(f"Folder exists: {os.path.exists(folder_path)}")
    
    # フォルダの内容を確認
    if os.path.exists(folder_path):
        print(f"Folder contents:")
        for item in os.listdir(folder_path):
            print(f"  - {item}")
    
    result = processor.get_excel_files(folder_path)
    print(f"Result: {result}")
    
    # JSON出力の文字コードテスト
    json_output = json.dumps(result, ensure_ascii=False)
    print(f"JSON output length: {len(json_output)}")
    print(f"JSON output first 100 chars: {json_output[:100]}")
    print(json_output)
    
except Exception as e:
    print(f"❌ Exception occurred: {str(e)}")
    import traceback
    traceback.print_exc()
    error_result = {
        'success': False,
        'error': str(e)
    }
    print(json.dumps(error_result, ensure_ascii=False))
''';
      
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/kinten_excel_script_${DateTime.now().millisecondsSinceEpoch}.py');
      
      try {
        await tempFile.writeAsString(pythonCode);
        
        // Pythonコマンドの決定（本番環境ではシステムPythonを優先）
        String pythonCommand = 'python';
        print('Using system Python: $pythonCommand');
        
        final env = <String, String>{
          'PYTHONIOENCODING': 'utf-8',
          'PYTHONUTF8': '1',
          'PYTHONPATH': '${projectRoot}\\backend',
          'PATH': '${projectRoot}\\venv\\Scripts;${Platform.environment['PATH']}',
        };
        
        final result = await Process.run(pythonCommand, [
          tempFile.path,
        ], workingDirectory: projectRoot, environment: env);
        
        print('Python process result:'); // デバッグログ
        print('Exit code: ${result.exitCode}'); // デバッグログ
        print('Stdout: ${result.stdout}'); // デバッグログ
        print('Stderr: ${result.stderr}'); // デバッグログ
        
        await tempFile.delete();
        
        if (result.exitCode == 0) {
          final output = result.stdout.toString().trim();
          print('Python output: $output'); // デバッグログ
          
          if (output.isEmpty) {
            return {
              'success': false,
              'error': 'Pythonスクリプトが出力を返しませんでした',
            };
          }
          
          try {
            return json.decode(output);
          } catch (e) {
            print('JSON decode error: $e'); // デバッグログ
            return {
              'success': false,
              'error': 'Pythonスクリプトの出力を解析できませんでした: $output',
            };
          }
        } else {
          final stderr = result.stderr.toString().trim();
          final stdout = result.stdout.toString().trim();
          print('Python stderr: $stderr'); // デバッグログ
          print('Python stdout: $stdout'); // デバッグログ
          
          String errorMessage = stderr.isNotEmpty ? stderr : 'Pythonスクリプトがエラーで終了しました';
          
          // stdoutからJSONレスポンスを探す
          if (stdout.isNotEmpty) {
            try {
              final lines = stdout.split('\n');
              for (final line in lines.reversed) {
                if (line.trim().startsWith('{') && line.trim().endsWith('}')) {
                  try {
                    final jsonResponse = json.decode(line.trim());
                    if (jsonResponse['success'] == false) {
                      return jsonResponse;
                    }
                  } catch (e) {
                    // JSON解析に失敗した場合は無視
                  }
                }
              }
            } catch (e) {
              print('JSON extraction error: $e');
            }
          }
          
          // 特定のエラーパターンを検出
          if (stderr.contains('ModuleNotFoundError')) {
            errorMessage = '必要なPythonライブラリがインストールされていません。システムにPythonライブラリをインストールしてください。';
          } else if (stderr.contains('FileNotFoundError')) {
            errorMessage = '指定されたファイルまたはフォルダが見つかりません。';
          } else if (stderr.contains('PermissionError')) {
            errorMessage = 'アクセス権限がありません。フォルダの権限を確認してください。';
          }
          
                  print('Final error message: $errorMessage');
        print('=== _handlePythonResultエラー処理完了 ===');
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
        try {
          await tempFile.delete();
        } catch (_) {}
        return {
          'success': false,
          'error': 'Excelファイル取得プロセスの実行に失敗しました: $e',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // PDF出力フォルダ作成
  Future<Map<String, dynamic>> _createPdfOutputFolder(String projectRoot) async {
    try {
      final pythonCode = '''
import sys
import os
import json

# バックエンドディレクトリをPythonパスに追加
backend_path = os.path.join(r"$projectRoot", "backend")
sys.path.insert(0, backend_path)

try:
    from main_processor import KintenProcessor
    
    processor = KintenProcessor()
    
    base_output_dir = r"$projectRoot/output"
    
    result = processor.create_pdf_output_folder(base_output_dir)
    
    print(json.dumps(result, ensure_ascii=False))
    
except Exception as e:
    print(json.dumps({
        'success': False,
        'error': str(e)
    }, ensure_ascii=False))
''';
      
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/kinten_folder_script_${DateTime.now().millisecondsSinceEpoch}.py');
      
      try {
        await tempFile.writeAsString(pythonCode);
        
        final pythonCommand = 'python';
        
        final env = <String, String>{
          'PYTHONIOENCODING': 'utf-8',
          'PYTHONUTF8': '1',
          'PYTHONPATH': '${projectRoot}\\backend',
        };
        
        final result = await Process.run(pythonCommand, [
          tempFile.path,
        ], workingDirectory: projectRoot, environment: env);
        
        await tempFile.delete();
        
        if (result.exitCode == 0) {
          final output = result.stdout.toString().trim();
          return json.decode(output);
        } else {
          return {
            'success': false,
            'error': result.stderr.toString().trim(),
          };
        }
      } catch (e) {
        try {
          await tempFile.delete();
        } catch (_) {}
        return {
          'success': false,
          'error': '出力フォルダ作成プロセスの実行に失敗しました: $e',
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
      print('=== _handlePythonResult開始 ===');
      print('Exit code: ${result.exitCode}');
      
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
        print('=== _handlePythonResult成功処理完了 ===');
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
        
        print('Final error message: $errorMessage');
        print('=== _handlePythonResultエラー処理完了 ===');
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    }

  // クロスプラットフォーム対応のプロジェクトルート取得
  String _getProjectRoot() {
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
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
); 