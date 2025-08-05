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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  void _loadSettings() {
    // 設定の読み込み（必要に応じて実装）
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

            // Excelファイル選択セクション
            _buildFileSelectionSection(appState, isSmallScreen),

            SizedBox(height: isSmallScreen ? 20 : 28),

            // 選択されたファイルリスト
            if (appState.selectedExcelFiles.isNotEmpty) ...[
              _buildSelectedFilesSection(appState, isSmallScreen),
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
                  'ExcelファイルをPDFに変換',
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

  Widget _buildFileSelectionSection(AppState appState, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションタイトル
          Row(
            children: [
              Text(
                'Excelファイル選択',
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

          // ファイル選択エリア
          NeumorphicContainer(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 選択されたファイル数表示
                if (appState.selectedExcelFiles.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                      border: Border.all(
                        color: const Color(0xFF27AE60).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27AE60).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                          ),
                          child: Icon(
                            Icons.table_chart,
                            color: const Color(0xFF27AE60),
                            size: isSmallScreen ? 20 : 22,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 16 : 20),
                        Expanded(
                          child: Text(
                            '${appState.selectedExcelFiles.length}個のファイルが選択されています',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                ],
                
                // ファイル選択ボタン
                NeumorphicButton(
                  onPressed: () async {
                    final files = await FileService.pickExcelFiles();
                    if (files != null && files.isNotEmpty) {
                      // 既存のファイルに追加
                      ref.read(appStateProvider.notifier).addExcelFiles(files);
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
                        Icons.file_upload,
                        color: const Color(0xFF3498DB),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                                             Text(
                         appState.selectedExcelFiles.isEmpty ? 'Excelファイルを選択（複数可）' : '追加選択',
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

  Widget _buildSelectedFilesSection(AppState appState, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションタイトル
          Row(
            children: [
              Text(
                '選択されたファイル',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
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
                  '${appState.selectedExcelFiles.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // ファイルリスト（複数ファイル表示用デザイン）
          Container(
            constraints: BoxConstraints(
              maxHeight: isSmallScreen ? 300 : 350,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              border: Border.all(
                color: const Color(0xFFBDC3C7),
                width: 1,
              ),
            ),
            child: appState.selectedExcelFiles.isEmpty
                ? Container(
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open,
                            color: const Color(0xFFBDC3C7),
                            size: isSmallScreen ? 48 : 56,
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          Text(
                            'Excelファイルを選択してください',
                            style: TextStyle(
                              color: const Color(0xFF95A5A6),
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    itemCount: appState.selectedExcelFiles.length,
                    itemBuilder: (context, index) {
                      final filePath = appState.selectedExcelFiles[index];
                      final fileName = filePath.split(RegExp(r'[/\\]')).last;

                      return Container(
                        margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                          border: Border.all(
                            color: const Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 8 : 10,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                            ),
                            child: Icon(
                              Icons.table_chart,
                              color: const Color(0xFF27AE60),
                              size: isSmallScreen ? 18 : 20,
                            ),
                          ),
                          title: Text(
                            fileName,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: const Color(0xFFE74C3C),
                              size: isSmallScreen ? 20 : 24,
                            ),
                            onPressed: () {
                              ref.read(appStateProvider.notifier).removeExcelFile(filePath);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

                     // リセットボタン
           if (appState.selectedExcelFiles.isNotEmpty)
             Container(
               width: double.infinity,
               height: isSmallScreen ? 44 : 48,
               decoration: BoxDecoration(
                 color: const Color(0xFF95A5A6),
                 borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                 boxShadow: [
                   BoxShadow(
                     color: const Color(0xFF95A5A6).withOpacity(0.3),
                     blurRadius: isSmallScreen ? 8 : 10,
                     offset: Offset(0, isSmallScreen ? 4 : 5),
                   ),
                 ],
               ),
               child: Material(
                 color: Colors.transparent,
                 child: InkWell(
                   onTap: () {
                     ref.read(appStateProvider.notifier).clearSelectedExcelFiles();
                   },
                   borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                   child: Container(
                     padding: EdgeInsets.symmetric(
                       horizontal: isSmallScreen ? 16 : 20,
                       vertical: isSmallScreen ? 10 : 12,
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(
                           Icons.refresh,
                           color: Colors.white,
                           size: isSmallScreen ? 18 : 20,
                         ),
                         SizedBox(width: isSmallScreen ? 8 : 10),
                         Text(
                           'リセット',
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: isSmallScreen ? 15 : 17,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
             ),
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
           '1. Excelファイルを選択してください（複数選択可）\n'
           '   - Ctrl+クリック：個別ファイル選択\n'
           '   - Shift+クリック：範囲選択\n'
           '   - Ctrl+A：全選択\n'
           '2. 変換ボタンを押すとPDFファイルが生成されます\n'
           '3. 変換されたPDFファイルは作業月フォルダに保存されます\n\n'
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
} 