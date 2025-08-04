import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'neumorphic_button.dart';
import 'neumorphic_container.dart';

class FileSelector extends StatelessWidget {
  final String label;
  final String hint;
  final String fileType; // 'csv', 'xlsx', 'folder'
  final Function(String) onFileSelected;
  final String selectedPath;

  const FileSelector({
    super.key,
    required this.label,
    required this.hint,
    required this.fileType,
    required this.onFileSelected,
    required this.selectedPath,
  });

    @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showInfoDialog(context),
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
        
        NeumorphicContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 選択されたファイルパス表示
              if (selectedPath.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                                     decoration: BoxDecoration(
                     color: const Color(0xFF3498DB).withOpacity(0.05),
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(
                       color: const Color(0xFF3498DB).withOpacity(0.1),
                     ),
                   ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                                                 decoration: BoxDecoration(
                           color: const Color(0xFF3498DB).withOpacity(0.1),
                           borderRadius: BorderRadius.circular(6),
                         ),
                                                 child: Icon(
                           _getFileIcon(),
                           color: const Color(0xFF3498DB),
                           size: 18,
                         ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                                                 child: Text(
                           selectedPath,
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
                const SizedBox(height: 16),
              ],
              
              // ファイル選択ボタン
                             NeumorphicButton(
                 onPressed: () => _selectFile(context),
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
                       selectedPath.isEmpty ? 'ファイルを選択' : '変更',
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
    );
  }

  IconData _getFileIcon() {
    switch (fileType) {
      case 'csv':
        return Icons.table_chart;
      case 'xlsx':
        return Icons.table_view;
      case 'folder':
        return Icons.folder;
      default:
        return Icons.file_present;
    }
  }

  Future<void> _selectFile(BuildContext context) async {
    try {
      String? result;
      
      switch (fileType) {
        case 'csv':
          result = await _pickCsvFile();
          break;
        case 'xlsx':
          result = await _pickExcelFile();
          break;
        case 'folder':
          result = await _pickFolder();
          break;
      }
      
      if (result != null) {
        onFileSelected(result);
      }
    } catch (e) {
      _showErrorDialog(context, 'ファイル選択エラー', e.toString());
    }
  }

  Future<String?> _pickCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );
    
    return result?.files.single.path;
  }

  Future<String?> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
    );
    
    return result?.files.single.path;
  }

  Future<String?> _pickFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    return result;
  }

  void _showInfoDialog(BuildContext context) {
    String title = '';
    String content = '';
    
    switch (fileType) {
      case 'csv':
        title = '勤怠CSVファイルについて';
        content = 'freeeからエクスポートした勤怠データのCSVファイルを選択してください。\n\nファイル形式：CSV\n推奨ファイル名：勤怠詳細_氏名_年月.csv';
        break;
      case 'xlsx':
        title = 'Excelテンプレートについて';
        content = '勤怠表のテンプレートファイルを選択してください。\n\nファイル形式：Excel (.xlsx)\nデフォルト：雛形ファイルが自動設定されます';
        break;
      default:
        title = 'ファイル選択について';
        content = '適切なファイル形式のファイルを選択してください。';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
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

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 