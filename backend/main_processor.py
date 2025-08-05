"""
メイン処理ロジック
CSVとExcel処理を統合する
"""

import os
from typing import Dict, Any
from csv_processor import CSVProcessor
from excel_processor import ExcelProcessor
from pdf_converter import PDFConverter


class KintenProcessor:
    """Kintenメイン処理クラス"""
    
    def __init__(self):
        self.csv_processor = CSVProcessor()
        self.excel_processor = ExcelProcessor()
        self.pdf_converter = PDFConverter()
    
    def process_files(self, csv_path: str, template_path: str, base_output_dir: str, employee_name: str) -> Dict[str, Any]:
        """
        メイン処理：CSV読み込み → Excel転記 → 保存
        
        Args:
            csv_path: CSVファイルパス
            template_path: テンプレートExcelパス
            base_output_dir: 基本出力ディレクトリパス
            employee_name: 従業員名（GUIから取得）
            
        Returns:
            処理結果辞書
        """
        try:
            # 1. CSVファイル読み込み
            # 従業員名を設定
            self.csv_processor.set_employee_name(employee_name)
            
            csv_result = self.csv_processor.load_csv(csv_path)
            if not csv_result['success']:
                return {
                    'success': False,
                    'error': f"CSV読み込みエラー: {csv_result['error']}"
                }
            
            # 2. 出力先フォルダとファイル名を生成
            year_month = csv_result['year_month']
            
            # 出力先フォルダを作成（例：2025_07）
            output_folder = os.path.join(base_output_dir, f"{year_month[:4]}_{year_month[4:]}")
            output_folder = os.path.abspath(output_folder)  # 絶対パスに変換
            print(f"Generated output folder: {output_folder}")
            os.makedirs(output_folder, exist_ok=True)
            
            # 出力ファイル名を生成（例：勤怠表_202501_サンプル.xlsx）
            output_filename = f"勤怠表_{year_month}_{employee_name}.xlsx"
            output_path = os.path.join(output_folder, output_filename)
            
            # 3. テンプレートExcel読み込み
            excel_result = self.excel_processor.load_template(template_path)
            if not excel_result['success']:
                return {
                    'success': False,
                    'error': f"Excel読み込みエラー: {excel_result['error']}"
                }
            
            # 4. シート名変更（氏名を含む）
            if not self.excel_processor.update_sheet_name(year_month, employee_name):
                return {
                    'success': False,
                    'error': "シート名変更エラー"
                }
            
            # 5. 従業員情報書き込み
            year = year_month[:4]
            month = year_month[4:]
            
            if not self.excel_processor.write_employee_info(employee_name, year, month):
                return {
                    'success': False,
                    'error': "従業員情報書き込みエラー"
                }
            
            # 6. 勤怠データ転記
            df = self.csv_processor.get_processed_data()
            if not self.excel_processor.write_attendance_data(df, employee_name):
                return {
                    'success': False,
                    'error': "勤怠データ転記エラー"
                }
            
            # 7. ファイル保存
            save_result = self.excel_processor.save_workbook(output_path)
            if not save_result['success']:
                return {
                    'success': False,
                    'error': f"ファイル保存エラー: {save_result['error']}"
                }
            
            return {
                'success': True,
                'employee_name': employee_name,
                'year_month': year_month,
                'output_path': output_path,
                'output_folder': output_folder,
                'row_count': csv_result['row_count']
            }
            
        except Exception as e:
            import traceback
            error_details = traceback.format_exc()
            print(f"Detailed error: {error_details}")
            return {
                'success': False,
                'error': f"処理エラー: {str(e)}",
                'details': error_details
            }
    
    def validate_inputs(self, csv_path: str, template_path: str, output_dir: str) -> Dict[str, Any]:
        """
        入力ファイルの検証
        
        Args:
            csv_path: CSVファイルパス
            template_path: テンプレートExcelパス
            output_dir: 出力ディレクトリパス
            
        Returns:
            検証結果辞書
        """
        errors = []
        
        # CSVファイル存在チェック
        if not os.path.exists(csv_path):
            errors.append("CSVファイルが見つかりません")
        elif not csv_path.lower().endswith('.csv'):
            errors.append("CSVファイルの拡張子が正しくありません")
        
        # テンプレートファイル存在チェック
        if not os.path.exists(template_path):
            errors.append("テンプレートExcelファイルが見つかりません")
        elif not template_path.lower().endswith(('.xlsx', '.xls')):
            errors.append("テンプレートファイルの拡張子が正しくありません")
        
        # 出力ディレクトリ存在チェック
        if not os.path.exists(output_dir):
            errors.append("出力ディレクトリが見つかりません")
        elif not os.path.isdir(output_dir):
            errors.append("出力パスがディレクトリではありません")
        
        return {
            'valid': len(errors) == 0,
            'errors': errors
        }
    
    def get_excel_files(self, folder_path: str) -> Dict[str, Any]:
        """
        指定フォルダ内のExcelファイルを取得
        
        Args:
            folder_path: フォルダパス
            
        Returns:
            結果辞書
        """
        return self.pdf_converter.get_excel_files(folder_path)
    
    def create_pdf_output_folder(self, base_output_dir: str) -> Dict[str, Any]:
        """
        PDF出力フォルダを作成（日付フォルダ）
        
        Args:
            base_output_dir: 基本出力ディレクトリ
            
        Returns:
            結果辞書
        """
        return self.pdf_converter.create_output_folder(base_output_dir)
    
    def convert_excel_to_pdf(self, excel_files: list, output_folder: str) -> Dict[str, Any]:
        """
        ExcelファイルをPDFに変換
        
        Args:
            excel_files: 変換するExcelファイルのパスリスト
            output_folder: 出力フォルダパス
            
        Returns:
            結果辞書
        """
        try:
            # 現在の日付から作業月を取得（YYYYMM形式）
            from datetime import datetime
            current_date = datetime.now()
            work_month = current_date.strftime("%Y%m")
            
            # 作業月フォルダを作成（例：202507）
            work_month_folder = os.path.join(output_folder, work_month)
            os.makedirs(work_month_folder, exist_ok=True)
            
            # PDF変換を実行（作業月フォルダに出力）
            result = self.pdf_converter.convert_to_pdf(excel_files, work_month_folder)
            
            # 変換されたファイル数を追加
            if result['success']:
                result['converted_count'] = len(excel_files)
                result['output_folder'] = work_month_folder
            
            return result
            
        except Exception as e:
            import traceback
            error_details = traceback.format_exc()
            print(f"convert_excel_to_pdf error: {error_details}")
            return {
                'success': False,
                'error': f"PDF変換エラー: {str(e)}",
                'details': error_details
            }
    
    def convert_folder_to_pdf(self, input_folder: str, output_folder: str) -> Dict[str, Any]:
        """
        フォルダ内のすべてのExcelファイルをPDFに変換
        
        Args:
            input_folder: 入力フォルダパス（Excelファイルが含まれる）
            output_folder: 出力フォルダパス
            
        Returns:
            結果辞書
        """
        try:
            # フォルダ内のExcelファイルを取得
            excel_files_result = self.get_excel_files(input_folder)
            if not excel_files_result['success']:
                return excel_files_result
            
            excel_files = excel_files_result['files']
            if not excel_files:
                return {
                    'success': False,
                    'error': 'フォルダ内にExcelファイルが見つかりませんでした'
                }
            
            # ファイルパスのリストを作成
            file_paths = [file['path'] for file in excel_files]
            
            # PDF変換を実行
            result = self.pdf_converter.convert_to_pdf(file_paths, output_folder)
            
            # 変換されたファイル数を追加
            if result['success']:
                result['converted_count'] = len(file_paths)
                result['output_folder'] = output_folder
            
            return result
            
        except Exception as e:
            import traceback
            error_details = traceback.format_exc()
            print(f"convert_folder_to_pdf error: {error_details}")
            return {
                'success': False,
                'error': f"フォルダ変換エラー: {str(e)}",
                'details': error_details
            }
    
    def open_folder(self, folder_path: str) -> Dict[str, Any]:
        """
        フォルダを開く
        
        Args:
            folder_path: 開くフォルダのパス
            
        Returns:
            結果辞書
        """
        return self.pdf_converter.open_folder(folder_path) 