import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../services/file_service.dart';
import 'neumorphic_container.dart';
import 'neumorphic_button.dart';

class PdfConversionWidget extends ConsumerStatefulWidget {
  final bool isSmallScreen;

  const PdfConversionWidget({
    super.key,
    required this.isSmallScreen,
  });

  @override
  ConsumerState<PdfConversionWidget> createState() => _PdfConversionWidgetState();
}

class _PdfConversionWidgetState extends ConsumerState<PdfConversionWidget> {
  final TextEditingController _inputFolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  void _loadSettings() {
    final appState = ref.read(appStateProvider);
    if (appState.pdfInputFolder.isNotEmpty) {
      _inputFolderController.text = appState.pdfInputFolder;
    }
  }

  @override
  void dispose() {
    _inputFolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final isSmallScreen = widget.isSmallScreen;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
      child: NeumorphicContainer(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 改善されたセクションヘッダー
            _buildEnhancedHeader(isSmallScreen),

            SizedBox(height: isSmallScreen ? 20 : 28),

            // 入力フォルダ選択セクション
            _buildInputFolderSection(appState, isSmallScreen),

            SizedBox(height: isSmallScreen ? 20 : 28),

            // Excelファイルリストセクション
            if (appState.pdfInputFolder.isNotEmpty) ...[
              _buildExcelFileListSection(appState, isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
            ],

            // ステータス表示セクション
            if (appState.pdfConversionStatus == AppStatus.error || appState.pdfConversionStatus == AppStatus.processing)
              _buildPdfConversionStatusSection(appState, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
              size: isSmallScreen ? 18 : 22,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PDF変換',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  'ExcelファイルをPDFに変換して管理しやすくします',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: const Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFolderSection(AppState appState, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          Container(
            margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                  ),
                  child: Icon(
                    Icons.folder_open,
                    color: Colors.white,
                    size: isSmallScreen ? 18 : 22,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ファイル設定',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'Excelファイルが含まれるフォルダを選択してください',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: const Color(0xFF7F8C8D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // フォルダ選択
          _buildFolderSelector(
            label: '入力フォルダ',
            hint: 'Excelファイルが含まれるフォルダを選択してください',
            controller: _inputFolderController,
            onFolderSelected: (path) {
              ref.read(appStateProvider.notifier).setPdfInputFolder(path);
              _inputFolderController.text = path;
              // フォルダ選択後にExcelファイルを取得
              Future.delayed(const Duration(milliseconds: 100), () {
                ref.read(appStateProvider.notifier).getExcelFiles();
              });
            },
            onRefresh: () {
              if (appState.pdfInputFolder.isNotEmpty) {
                ref.read(appStateProvider.notifier).getExcelFiles();
              }
            },
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }



  Widget _buildExcelFileListSection(AppState appState, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          Container(
            margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF27AE60), Color(0xFF229954)],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                  ),
                  child: Icon(
                    Icons.description,
                    color: Colors.white,
                    size: isSmallScreen ? 18 : 22,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ファイル一覧',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        '変換対象のExcelファイルを選択してください',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: const Color(0xFF7F8C8D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (appState.excelFiles.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        if (appState.selectAllFiles) {
                          ref.read(appStateProvider.notifier).deselectAllExcelFiles();
                        } else {
                          ref.read(appStateProvider.notifier).selectAllExcelFiles();
                        }
                      },
                      icon: Icon(
                        appState.selectAllFiles ? Icons.check_box_outline_blank : Icons.check_box,
                        size: isSmallScreen ? 16 : 18,
                        color: const Color(0xFF27AE60),
                      ),
                      label: Text(
                        appState.selectAllFiles ? 'すべて解除' : 'すべて選択',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: const Color(0xFF27AE60),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // ファイルリスト
          _buildEnhancedExcelFileList(appState, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildEnhancedExcelFileList(AppState appState, bool isSmallScreen) {
    if (appState.excelFiles.isEmpty) {
      return Container(
        height: isSmallScreen ? 200 : 250,
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: isSmallScreen ? 48 : 56,
                color: const Color(0xFFBDC3C7),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Excelファイルが見つかりません',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: const Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                'フォルダ内に.xlsxまたは.xlsファイルがあることを確認してください',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: const Color(0xFFBDC3C7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: isSmallScreen ? 250 : 350,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 8 : 12,
        ),
        itemCount: appState.excelFiles.length,
        itemBuilder: (context, index) {
          final file = appState.excelFiles[index];
          final filePath = file['path'] as String;
          final fileName = file['name'] as String;
          final fileSize = file['size'] as int;
          final isSelected = appState.selectedFiles.contains(filePath);

          return Container(
            margin: EdgeInsets.only(bottom: isSmallScreen ? 4 : 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3498DB).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF3498DB) : const Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              dense: isSmallScreen,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              leading: Container(
                width: isSmallScreen ? 32 : 36,
                height: isSmallScreen ? 32 : 36,
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3498DB) : const Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.description,
                  size: isSmallScreen ? 18 : 20,
                  color: isSelected ? Colors.white : const Color(0xFF27AE60),
                ),
              ),
              title: Text(
                fileName,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF3498DB) : const Color(0xFF2C3E50),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${(fileSize / 1024).toStringAsFixed(1)} KB',
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 13,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  ref.read(appStateProvider.notifier).toggleFileSelection(filePath);
                },
                activeColor: const Color(0xFF3498DB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPdfConversionStatusSection(AppState appState, bool isSmallScreen) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (appState.pdfConversionStatus) {
      case AppStatus.processing:
        statusColor = const Color(0xFFFF8C00);
        statusIcon = Icons.hourglass_empty;
        statusText = '処理中...';
        break;
      case AppStatus.error:
        statusColor = const Color(0xFFF44336);
        statusIcon = Icons.error;
        statusText = 'エラー';
        break;
      case AppStatus.success:
        statusColor = const Color(0xFF27AE60);
        statusIcon = Icons.check_circle;
        statusText = '完了';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: isSmallScreen ? 20 : 24),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (appState.pdfConversionStatusMessage.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    appState.pdfConversionStatusMessage,
                    style: TextStyle(
                      color: statusColor.withOpacity(0.8),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (appState.pdfConversionErrorMessage != null && appState.pdfConversionErrorMessage!.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    appState.pdfConversionErrorMessage!,
                    style: TextStyle(
                      color: statusColor.withOpacity(0.6),
                      fontSize: isSmallScreen ? 10 : 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (appState.pdfConversionStatus == AppStatus.processing) ...[
            SizedBox(
              width: isSmallScreen ? 20 : 24,
              height: isSmallScreen ? 20 : 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFolderSelector({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onFolderSelected,
    required Function()? onRefresh,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 12 : 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.text.isEmpty ? hint : controller.text,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 15,
                    color: controller.text.isEmpty 
                        ? const Color(0xFFBDC3C7) 
                        : const Color(0xFF2C3E50),
                    fontWeight: controller.text.isEmpty 
                        ? FontWeight.normal 
                        : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                child: NeumorphicButton(
                  onPressed: () async {
                    try {
                      final path = await FileService.pickDirectory();
                      if (path != null) {
                        onFolderSelected(path);
                      } else {
                        // フォルダ選択がキャンセルされた場合
                        print('フォルダ選択がキャンセルされました');
                      }
                    } catch (e) {
                      print('フォルダ選択エラー: $e');
                      // エラーメッセージを表示
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('フォルダ選択中にエラーが発生しました: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.folder_open,
                    size: isSmallScreen ? 20 : 24,
                    color: Colors.white,
                  ),
                ),
              ),
              if (onRefresh != null) ...[
                Container(
                  margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                  child: NeumorphicButton(
                    onPressed: onRefresh,
                    child: Icon(
                      Icons.refresh,
                      size: isSmallScreen ? 20 : 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }


} 