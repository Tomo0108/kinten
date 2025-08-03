import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../widgets/file_selector.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/neumorphic_progress_indicator.dart';
import '../widgets/neumorphic_text_field.dart';

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
    
    // 保存された氏名をコントローラーに設定
    if (_employeeNameController.text.isEmpty && appState.employeeName.isNotEmpty) {
      _employeeNameController.text = appState.employeeName;
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: appState.isLoading
              ? _buildLoadingScreen()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダー
                    _buildHeader(),
                    const SizedBox(height: 16),
                    
                    // タブ
                    _buildTabBar(),
                    const SizedBox(height: 16),
                    
                    // タブコンテンツ
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAutoTransferTab(context, ref),
                          _buildPdfConversionTab(),
                        ],
                      ),
                    ),
                    
                    // 実行ボタン
                    _buildExecuteButton(context, ref),
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
  
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3498DB),
              Color(0xFF2980B9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3498DB).withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 25,
              offset: const Offset(-8, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.schedule,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 24),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kinten',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '勤怠管理アプリ',
                    style: TextStyle(
                      fontSize: 14,
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3498DB).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF7F8C8D),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
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
      ),
    );
  }
  
  Widget _buildAutoTransferTab(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // セクションヘッダー
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3498DB).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '基本情報',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            '従業員情報とファイルを設定してください',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
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
              
              const SizedBox(height: 32),
              
              // ファイル選択セクション
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF27AE60), Color(0xFF229954)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF27AE60).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.folder_open,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ファイル設定',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            'CSVファイルとテンプレートを選択してください',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
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
              
              const SizedBox(height: 24),
              
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
             
              const SizedBox(height: 40),
              
              // ステータス表示（エラー時のみ表示）
              if (ref.watch(appStateProvider).status == AppStatus.error)
                _buildStatusSection(ref),
              

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfConversionTab() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Color(0xFF3498DB),
            ),
            SizedBox(height: 24),
            Text(
              'PDF変換機能',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'この機能は現在開発中です。\n近日公開予定です。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusSection(WidgetRef ref) {
    final status = ref.watch(appStateProvider).status;
    final message = ref.watch(appStateProvider).statusMessage;
    
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
  

  
  Widget _buildExecuteButton(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final isReady = appState.csvPath.isNotEmpty && 
                   appState.templatePath.isNotEmpty &&
                   appState.employeeName.isNotEmpty;
    
    // デバッグログ
    print('Button state: csvPath=${appState.csvPath.isNotEmpty}, templatePath=${appState.templatePath.isNotEmpty}, employeeName=${appState.employeeName.isNotEmpty}');
    print('Template path: ${appState.templatePath}');
    print('Is ready: $isReady');
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
                         gradient: isReady && appState.status != AppStatus.processing
                 ? appState.status == AppStatus.success
                     ? const LinearGradient(
                         colors: [Color(0xFF27AE60), Color(0xFF229954)],
                       )
                     : const LinearGradient(
                         colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                       )
                 : const LinearGradient(
                     colors: [Color(0xFFBDC3C7), Color(0xFF95A5A6)],
                   ),
            borderRadius: BorderRadius.circular(20),
                         boxShadow: isReady && appState.status != AppStatus.processing
                 ? appState.status == AppStatus.success
                     ? [
                         BoxShadow(
                           color: const Color(0xFF27AE60).withOpacity(0.4),
                           blurRadius: 15,
                           offset: const Offset(0, 8),
                         ),
                         BoxShadow(
                           color: Colors.white.withOpacity(0.9),
                           blurRadius: 15,
                           offset: const Offset(-6, -6),
                         ),
                       ]
                     : [
                         BoxShadow(
                           color: const Color(0xFF3498DB).withOpacity(0.4),
                           blurRadius: 15,
                           offset: const Offset(0, 8),
                         ),
                         BoxShadow(
                           color: Colors.white.withOpacity(0.9),
                           blurRadius: 15,
                           offset: const Offset(-6, -6),
                         ),
                       ]
                 : [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.1),
                       blurRadius: 8,
                       offset: const Offset(0, 4),
                     ),
                   ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isReady && appState.status != AppStatus.processing
                  ? () {
                      print('=== ボタンクリックイベント開始 ===');
                      print('isReady: $isReady');
                      print('appState.status: ${appState.status}');
                      ref.read(appStateProvider.notifier).processFiles();
                      print('=== ボタンクリックイベント完了 ===');
                    }
                  : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 240,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                                         Icon(
                       appState.status == AppStatus.processing 
                           ? Icons.hourglass_empty 
                           : appState.status == AppStatus.success
                               ? Icons.check_circle
                               : Icons.play_arrow,
                       color: Colors.white,
                       size: 28,
                     ),
                    const SizedBox(width: 16),
                                         Text(
                       appState.status == AppStatus.processing 
                           ? '処理中...' 
                           : appState.status == AppStatus.success
                               ? '変換完了'
                               : '変換して保存',
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 20,
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
      ),
    );
  }
} 