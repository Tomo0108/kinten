"""
PDF変換機能
ExcelファイルをPDFに変換する
"""

import os
import glob
from datetime import datetime
from typing import Dict, Any, List, Optional
import win32com.client
import pythoncom


class PDFConverter:
    """PDF変換クラス"""
    
    def __init__(self):
        self.excel_app: Optional[Any] = None
    
    def _initialize_excel(self) -> bool:
        """Excelアプリケーションを初期化"""
        try:
            pythoncom.CoInitialize()
            self.excel_app = win32com.client.Dispatch("Excel.Application")
            self.excel_app.Visible = False
            self.excel_app.DisplayAlerts = False
            return True
        except Exception as e:
            print(f"Excel初期化エラー: {str(e)}")
            return False
    
    def _cleanup_excel(self) -> None:
        """Excelアプリケーションをクリーンアップ"""
        try:
            if self.excel_app:
                self.excel_app.Quit()
                self.excel_app = None
            pythoncom.CoUninitialize()
        except Exception as e:
            print(f"Excelクリーンアップエラー: {str(e)}")
    
    def get_excel_files(self, folder_path: str) -> Dict[str, Any]:
        """
        指定フォルダ内のExcelファイルを取得
        
        Args:
            folder_path: フォルダパス
            
        Returns:
            結果辞書
        """
        try:
            if not os.path.exists(folder_path):
                return {
                    'success': False,
                    'error': f'フォルダが見つかりません: {folder_path}'
                }
            
            # Excelファイルを検索
            excel_patterns = ['*.xlsx', '*.xls']
            excel_files = []
            
            for pattern in excel_patterns:
                files = glob.glob(os.path.join(folder_path, pattern))
                excel_files.extend(files)
            
            # ファイル情報を取得
            file_list = []
            for file_path in excel_files:
                file_name = os.path.basename(file_path)
                file_size = os.path.getsize(file_path)
                file_list.append({
                    'path': file_path,
                    'name': file_name,
                    'size': file_size
                })
            
            return {
                'success': True,
                'files': file_list,
                'count': len(file_list)
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f'ファイル取得エラー: {str(e)}'
            }
    
    def create_output_folder(self, base_output_dir: str) -> Dict[str, Any]:
        """
        出力フォルダを作成（日付フォルダ）
        
        Args:
            base_output_dir: 基本出力ディレクトリ
            
        Returns:
            結果辞書
        """
        try:
            # 現在の日付でフォルダ名を生成（YYYYMM形式）
            current_date = datetime.now()
            folder_name = current_date.strftime("%Y%m")
            
            # 出力フォルダパスを作成
            output_folder = os.path.join(base_output_dir, folder_name)
            
            # フォルダを作成
            os.makedirs(output_folder, exist_ok=True)
            
            return {
                'success': True,
                'output_folder': output_folder,
                'folder_name': folder_name
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f'出力フォルダ作成エラー: {str(e)}'
            }
    
    def convert_to_pdf(self, excel_files: List[str], output_folder: str) -> Dict[str, Any]:
        """
        ExcelファイルをPDFに変換
        
        Args:
            excel_files: 変換するExcelファイルのパスリスト
            output_folder: 出力フォルダパス
            
        Returns:
            結果辞書
        """
        try:
            if not self._initialize_excel():
                return {
                    'success': False,
                    'error': 'Excelアプリケーションの初期化に失敗しました'
                }
            
            converted_files = []
            failed_files = []
            
            for excel_file in excel_files:
                try:
                    # ファイル名からPDF名を生成
                    base_name = os.path.splitext(os.path.basename(excel_file))[0]
                    pdf_name = f"{base_name}.pdf"
                    pdf_path = os.path.join(output_folder, pdf_name)
                    
                    # ワークブックを開く
                    if self.excel_app is None:
                        raise Exception("Excelアプリケーションが初期化されていません")
                    workbook = self.excel_app.Workbooks.Open(excel_file)
                    
                    # PDFとして保存
                    workbook.ExportAsFixedFormat(
                        Type=0,  # PDF
                        Filename=pdf_path,
                        Quality=0,  # 標準品質
                        IncludeDocProperties=True,
                        IgnorePrintAreas=False,
                        OpenAfterPublish=False
                    )
                    
                    # ワークブックを閉じる
                    workbook.Close(SaveChanges=False)
                    
                    converted_files.append({
                        'excel_file': excel_file,
                        'pdf_file': pdf_path,
                        'pdf_name': pdf_name
                    })
                    
                except Exception as e:
                    failed_files.append({
                        'file': excel_file,
                        'error': str(e)
                    })
            
            self._cleanup_excel()
            
            return {
                'success': True,
                'converted_files': converted_files,
                'failed_files': failed_files,
                'total_converted': len(converted_files),
                'total_failed': len(failed_files)
            }
            
        except Exception as e:
            self._cleanup_excel()
            return {
                'success': False,
                'error': f'PDF変換エラー: {str(e)}'
            }
    
    def open_folder(self, folder_path: str) -> Dict[str, Any]:
        """
        フォルダを開く
        
        Args:
            folder_path: 開くフォルダのパス
            
        Returns:
            結果辞書
        """
        try:
            if not os.path.exists(folder_path):
                return {
                    'success': False,
                    'error': f'フォルダが見つかりません: {folder_path}'
                }
            
            # Windowsエクスプローラーでフォルダを開く
            os.startfile(folder_path)
            
            return {
                'success': True,
                'message': f'フォルダを開きました: {folder_path}'
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f'フォルダを開くエラー: {str(e)}'
            } 