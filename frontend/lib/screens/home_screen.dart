import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../widgets/file_selector.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/neumorphic_progress_indicator.dart';
import '../widgets/neumorphic_text_field.dart';
import '../widgets/pdf_conversion_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _employeeNameController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _employeeNameController = TextEditingController();
    
    // タブ切り替え時のリスナーを追加
    _tabController.addListener(() {
      // タブが切り替わった時にUIを更新
      if (_tabController.indexIsChanging) {
        print('Tab changing from ${_tabController.previousIndex} to ${_tabController.index}');
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _employeeNameController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 800;
    
    // 保存された氏名をコントローラーに設定
    if (_employeeNameController.text.isEmpty && appState.employeeName.isNotEmpty) {
      _employeeNameController.text = appState.employeeName;
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: appState.isLoading
              ? _buildLoadingScreen()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダー
                    _buildHeader(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    
                    // タブ
                    _buildTabBar(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    
                    // タブコンテンツ
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        key: ValueKey(_tabController.index), // タブ切り替え時に強制的に再構築
                        children: [
                          SingleChildScrollView(
                            child: _buildAutoTransferTab(context, ref, isSmallScreen),
                          ),
                          SingleChildScrollView(
                            child: _buildPdfConversionTab(isSmallScreen),
                          ),
                        ],
                      ),
                    ),
                    
                    // タブに応じた実行ボタン
                    _buildTabSpecificButton(context, ref, isSmallScreen),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NeumorphicProgressIndicator(
              value: null, // 不定のプログレス
              height: 4,
            ),
            const SizedBox(height: 24),
            const Text(
              '設定を読み込み中...',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3498DB),
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.schedule,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kinten',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '勤怠管理アプリ',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF7F8C8D),
          labelStyle: TextStyle(
            fontSize: isSmallScreen ? 11 : 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: isSmallScreen ? 11 : 13,
            fontWeight: FontWeight.w500,
          ),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: '自動転記'),
            Tab(text: 'PDF変換'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAutoTransferTab(BuildContext context, WidgetRef ref, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
      child: NeumorphicContainer(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: SingleChildScrollView(
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
                        Icons.person,
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
                            '基本情報',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            '従業員情報を設定してください',
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
              
              // 氏名入力
              NeumorphicTextField(
                label: '氏名',
                hint: '氏名を入力してください',
                controller: _employeeNameController,
                onChanged: (value) async {
                  await ref.read(appStateProvider.notifier).setEmployeeName(value);
                },
              ),
              
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // ファイル選択セクション
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
                            'CSVファイルとテンプレートを選択してください',
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
              
              // CSVファイル選択
              FileSelector(
                label: '勤怠CSVファイル',
                hint: 'freeeからエクスポートしたCSVファイルを選択',
                fileType: 'csv',
                onFileSelected: (path) {
                  ref.read(appStateProvider.notifier).setCsvPath(path);
                },
                selectedPath: ref.watch(appStateProvider).csvPath,
              ),
              
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Excelテンプレート選択
              FileSelector(
                label: 'Excelテンプレート',
                hint: '勤怠表テンプレートを選択（デフォルト: 雛形ファイル）',
                fileType: 'xlsx',
                onFileSelected: (path) async {
                  await ref.read(appStateProvider.notifier).setTemplatePath(path);
                },
                selectedPath: ref.watch(appStateProvider).templatePath,
              ),
             
              SizedBox(height: isSmallScreen ? 24 : 32),
              
              // ステータス表示（エラー時のみ表示）
              if (ref.watch(appStateProvider).autoTransferStatus == AppStatus.error)
                _buildAutoTransferStatusSection(ref),
              

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfConversionTab(bool isSmallScreen) {
    return PdfConversionWidget(isSmallScreen: isSmallScreen);
  }
  
  Widget _buildAutoTransferStatusSection(WidgetRef ref) {
    final status = ref.watch(appStateProvider).autoTransferStatus;
    final message = ref.watch(appStateProvider).autoTransferStatusMessage;
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case AppStatus.processing:
        statusColor = const Color(0xFFFF8C00);
        statusIcon = Icons.hourglass_empty;
        break;
      case AppStatus.success:
        statusColor = const Color(0xFF27AE60);
        statusIcon = Icons.check_circle;
        break;
      case AppStatus.error:
        statusColor = const Color(0xFFF44336);
        statusIcon = Icons.error;
        break;
      default:
        statusColor = const Color(0xFF888888);
        statusIcon = Icons.info;
    }
    
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // 処理中の場合、プログレスバーを表示
          if (status == AppStatus.processing) ...[
            const SizedBox(height: 16),
            const NeumorphicProgressIndicator(
              value: null, // 不定のプログレス
              color: Color(0xFFFF8C00),
            ),
          ],
        ],
      ),
    );
  }
  

  
  Widget _buildTabSpecificButton(BuildContext context, WidgetRef ref, bool isSmallScreen) {
    final currentTabIndex = _tabController.index;
    
    // デバッグログ
    print('Building tab specific button for index: $currentTabIndex');
    
    // タブに応じて専用のボタンを表示
    switch (currentTabIndex) {
      case 0:
        print('Building auto transfer button');
        return _buildAutoTransferButton(context, ref, isSmallScreen);
      case 1:
        print('Building PDF conversion button');
        return _buildPdfConversionButton(context, ref, isSmallScreen);
      default:
        print('Building empty button for unknown tab');
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildAutoTransferButton(BuildContext context, WidgetRef ref, bool isSmallScreen) {
    final appState = ref.watch(appStateProvider);
    final isReady = appState.csvPath.isNotEmpty && 
                   appState.templatePath.isNotEmpty &&
                   appState.employeeName.isNotEmpty;
    
    String buttonText = appState.autoTransferStatus == AppStatus.processing 
        ? '処理中...' 
        : appState.autoTransferStatus == AppStatus.success
            ? '変換完了'
            : '自動転記を実行';
    IconData buttonIcon = appState.autoTransferStatus == AppStatus.processing 
        ? Icons.hourglass_empty 
        : appState.autoTransferStatus == AppStatus.success
            ? Icons.check_circle
            : Icons.play_arrow;
    VoidCallback? onPressed = isReady && appState.autoTransferStatus != AppStatus.processing
        ? () {
            print('=== 自動転記ボタンクリックイベント開始 ===');
            ref.read(appStateProvider.notifier).processFiles();
            print('=== 自動転記ボタンクリックイベント完了 ===');
          }
        : null;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: isReady && appState.autoTransferStatus != AppStatus.processing
                ? appState.autoTransferStatus == AppStatus.success
                    ? const LinearGradient(
                        colors: [Color(0xFF27AE60), Color(0xFF229954)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                      )
                : const LinearGradient(
                    colors: [Color(0xFFBDC3C7), Color(0xFF95A5A6)],
                  ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            boxShadow: isReady && appState.autoTransferStatus != AppStatus.processing
                ? appState.autoTransferStatus == AppStatus.success
                    ? [
                        BoxShadow(
                          color: const Color(0xFF27AE60).withOpacity(0.4),
                          blurRadius: isSmallScreen ? 12 : 15,
                          offset: Offset(0, isSmallScreen ? 6 : 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: isSmallScreen ? 12 : 15,
                          offset: Offset(isSmallScreen ? -4 : -6, isSmallScreen ? -4 : -6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withOpacity(0.4),
                          blurRadius: isSmallScreen ? 12 : 15,
                          offset: Offset(0, isSmallScreen ? 6 : 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: isSmallScreen ? 12 : 15,
                          offset: Offset(isSmallScreen ? -4 : -6, isSmallScreen ? -4 : -6),
                        ),
                      ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: isSmallScreen ? 6 : 8,
                      offset: Offset(0, isSmallScreen ? 2 : 4),
                    ),
                  ],
          ),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: isSmallScreen ? 200 : 240,
              height: isSmallScreen ? 56 : 64,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24 : 32, 
                vertical: isSmallScreen ? 12 : 16
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    buttonIcon,
                    color: Colors.white,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPdfConversionButton(BuildContext context, WidgetRef ref, bool isSmallScreen) {
    final appState = ref.watch(appStateProvider);
    final isReady = appState.selectedFiles.isNotEmpty;
    
    String buttonText = appState.pdfConversionStatus == AppStatus.processing 
        ? '変換中...' 
        : appState.pdfConversionStatus == AppStatus.success
            ? '変換完了'
            : 'PDFに変換';
    IconData buttonIcon = appState.pdfConversionStatus == AppStatus.processing 
        ? Icons.hourglass_empty 
        : appState.pdfConversionStatus == AppStatus.success
            ? Icons.check_circle
            : Icons.picture_as_pdf;
    VoidCallback? onPressed = isReady && appState.pdfConversionStatus != AppStatus.processing
        ? () {
            print('=== PDF変換ボタンクリックイベント開始 ===');
            ref.read(appStateProvider.notifier).processPdfConversion();
            print('=== PDF変換ボタンクリックイベント完了 ===');
          }
        : null;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: isReady && appState.pdfConversionStatus != AppStatus.processing
                ? appState.pdfConversionStatus == AppStatus.success
                    ? const LinearGradient(
                        colors: [Color(0xFF27AE60), Color(0xFF229954)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                      )
                : const LinearGradient(
                    colors: [Color(0xFFBDC3C7), Color(0xFF95A5A6)],
                  ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            boxShadow: isReady && appState.pdfConversionStatus != AppStatus.processing
                ? appState.pdfConversionStatus == AppStatus.success
                    ? [
                        BoxShadow(
                          color: const Color(0xFF27AE60).withOpacity(0.4),
                          blurRadius: isSmallScreen ? 12 : 15,
                          offset: Offset(0, isSmallScreen ? 6 : 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: isSmallScreen ? 12 : 15,
                          offset: Offset(isSmallScreen ? -4 : -6, isSmallScreen ? -4 : -6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFFE74C3C).withOpacity(0.4),
                          blurRadius: isSmallScreen ? 12 : 15,
                          offset: Offset(0, isSmallScreen ? 6 : 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: isSmallScreen ? 12 : 15,
                          offset: Offset(isSmallScreen ? -4 : -6, isSmallScreen ? -4 : -6),
                        ),
                      ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: isSmallScreen ? 6 : 8,
                      offset: Offset(0, isSmallScreen ? 2 : 4),
                    ),
                  ],
          ),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: isSmallScreen ? 200 : 240,
              height: isSmallScreen ? 56 : 64,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24 : 32, 
                vertical: isSmallScreen ? 12 : 16
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    buttonIcon,
                    color: Colors.white,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 