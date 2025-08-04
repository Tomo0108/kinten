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
            // シンプルなヘッダー
            _buildSimpleHeader(isSmallScreen),

            SizedBox(height: isSmallScreen ? 20 : 28),

            // 入力フォルダ選択セクション（改善版）
            _buildImprovedInputFolderSection(appState, isSmallScreen),

            SizedBox(height: isSmallScreen ? 20 : 28),

            // Excelファイルリストセクション
            if (appState.pdfInputFolder.isNotEmpty) ...[
              _buildExcelFileListSection(appState, isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
            ],

            // ステータス表示セクション
            if (appState.pdfConversionStatus == AppStatus.error || 
                appState.pdfConversionStatus == AppStatus.processing ||
                appState.pdfConversionStatus == AppStatus.success)
              _buildPdfConversionStatusSection(appState, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleHeader(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                  'ExcelファイルをPDFに変換してください',
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

  Widget _buildImprovedInputFolderSection(AppState appState, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションタイトル（FileSelectorデザインに統一）
          Row(
            children: [
              Text(
                '入力フォルダ',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showPdfInfoDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF3498DB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // フォルダ選択エリア（自動転記のFileSelectorデザインを参考）
          NeumorphicContainer(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 選択されたフォルダパス表示
                if (appState.pdfInputFolder.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                      border: Border.all(
                        color: const Color(0xFF3498DB).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3498DB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                          ),
                          child: Icon(
                            Icons.folder,
                            color: const Color(0xFF3498DB),
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: Text(
                            appState.pdfInputFolder,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                ],
                
                // フォルダ選択ボタン（FileSelectorデザインに統一）
                NeumorphicButton(
                  onPressed: () async {
                    final folder = await FileService.pickDirectory();
                    if (folder != null) {
                      setState(() {
                        _inputFolderController.text = folder;
                      });
                      ref.read(appStateProvider.notifier).setPdfInputFolder(folder);
                      // フォルダ内のExcelファイルを取得
                      await ref.read(appStateProvider.notifier).getExcelFiles();
                    }
                  },
                  width: double.infinity,
                  height: 48,
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        color: const Color(0xFF3498DB),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        appState.pdfInputFolder.isEmpty ? 'フォルダを選択' : '変更',
                        style: const TextStyle(
                          color: Color(0xFF3498DB),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          // セクションタイトル（FileSelectorデザインに統一）
          Row(
            children: [
              Text(
                'Excelファイル一覧',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showExcelListInfoDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF27AE60),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${appState.excelFiles.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // ファイルリスト
          if (appState.excelFiles.isNotEmpty) ...[
            Container(
              constraints: BoxConstraints(
                maxHeight: isSmallScreen ? 200 : 250,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                border: Border.all(
                  color: const Color(0xFFBDC3C7),
                  width: 1,
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appState.excelFiles.length,
                itemBuilder: (context, index) {
                  final file = appState.excelFiles[index];
                  final fileName = file['name'] as String? ?? 'Unknown';
                  final filePath = file['path'] as String? ?? '';
                  final fileSize = file['size'] as int? ?? 0;
                  final isSelected = appState.selectedFiles.contains(filePath);

                  return Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFFE8F5E8) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                      border: isSelected 
                          ? Border.all(
                              color: const Color(0xFF27AE60),
                              width: 2,
                            )
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 12,
                        vertical: isSmallScreen ? 4 : 6,
                      ),
                      leading: Icon(
                        Icons.table_chart,
                        color: isSelected 
                            ? const Color(0xFF27AE60)
                            : const Color(0xFF95A5A6),
                        size: isSmallScreen ? 20 : 24,
                      ),
                      title: Text(
                        fileName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: isSelected 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                          color: isSelected 
                              ? const Color(0xFF27AE60)
                              : const Color(0xFF2C3E50),
                        ),
                      ),
                      subtitle: Text(
                        _formatFileSize(fileSize),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: const Color(0xFF95A5A6),
                        ),
                      ),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: const Color(0xFF27AE60),
                              size: isSmallScreen ? 20 : 24,
                            )
                          : null,
                      onTap: () {
                        ref.read(appStateProvider.notifier).toggleFileSelection(filePath);
                      },
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // 選択操作ボタン
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: appState.excelFiles.isNotEmpty
                        ? () {
                            ref.read(appStateProvider.notifier).selectAllExcelFiles();
                          }
                        : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 8 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: appState.excelFiles.isNotEmpty
                            ? const Color(0xFF3498DB)
                            : const Color(0xFFBDC3C7),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.select_all,
                            color: Colors.white,
                            size: isSmallScreen ? 16 : 18,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Text(
                            '全選択',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: NeumorphicButton(
                    onPressed: appState.selectedFiles.isNotEmpty
                        ? () {
                            ref.read(appStateProvider.notifier).deselectAllExcelFiles();
                          }
                        : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 8 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: appState.selectedFiles.isNotEmpty
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFFBDC3C7),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.clear_all,
                            color: Colors.white,
                            size: isSmallScreen ? 16 : 18,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Text(
                            '全解除',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                border: Border.all(
                  color: const Color(0xFFBDC3C7),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF95A5A6),
                    size: isSmallScreen ? 18 : 20,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 10),
                  Expanded(
                    child: Text(
                      'フォルダ内にExcelファイルが見つかりませんでした',
                      style: TextStyle(
                        color: const Color(0xFF95A5A6),
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPdfConversionStatusSection(AppState appState, bool isSmallScreen) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (appState.pdfConversionStatus) {
      case AppStatus.processing:
        statusColor = const Color(0xFFF39C12);
        statusIcon = Icons.hourglass_empty;
        statusText = appState.pdfConversionStatusMessage;
        break;
      case AppStatus.success:
        statusColor = const Color(0xFF27AE60);
        statusIcon = Icons.check_circle;
        statusText = appState.pdfConversionStatusMessage;
        break;
      case AppStatus.error:
        statusColor = const Color(0xFFE74C3C);
        statusIcon = Icons.error;
        statusText = appState.pdfConversionErrorMessage ?? 'エラーが発生しました';
        break;
      default:
        statusColor = const Color(0xFF95A5A6);
        statusIcon = Icons.info;
        statusText = appState.pdfConversionStatusMessage;
    }

    return Container(
      margin: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
          Icon(
            statusIcon,
            color: statusColor,
            size: isSmallScreen ? 20 : 24,
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPdfInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'PDF変換機能について',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: const Text(
          'ExcelファイルをPDFに変換する機能です。\n\n'
          '1. 入力フォルダを選択してください\n'
          '2. フォルダ内のExcelファイルが一覧表示されます\n'
          '3. 変換ボタンを押すとPDFファイルが生成されます\n\n'
          '対応形式：Excel (.xlsx, .xls)\n'
          '出力形式：PDF',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF34495E),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF3498DB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExcelListInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Excelファイル一覧について',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: const Text(
          '選択されたフォルダ内のExcelファイルが一覧表示されます。\n\n'
          '対応形式：.xlsx, .xls\n'
          'ファイルが見つからない場合は、別のフォルダを選択してください。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF34495E),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF27AE60),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes / k).floor();
    return '${(bytes / k).toStringAsFixed(1)} ${sizes[i]}';
  }
} 