"""
CSV処理機能
freee勤怠CSVを読み込み、整形する
"""

import pandas as pd
import re
import os
from typing import Dict, Any, Optional


class CSVProcessor:
    """freee勤怠CSV処理クラス"""
    
    def __init__(self):
        self.df: Optional[pd.DataFrame] = None
        self.employee_name: str = ""
        self.year_month: str = ""
    
    def set_employee_name(self, name: str):
        """GUIから入力された従業員名を設定"""
        self.employee_name = name
    
    def load_csv(self, file_path: str) -> Dict[str, Any]:
        """
        CSVファイルを読み込み、基本情報を抽出
        
        Args:
            file_path: CSVファイルパス
            
        Returns:
            処理結果辞書
        """
        try:
            # CSVファイル読み込み
            self.df = pd.read_csv(file_path, encoding='utf-8')
            
            # CSVデータから年月を抽出
            self._extract_year_month_from_data()
            
            # データ検証
            validation_result = self._validate_csv_structure()
            
            return {
                'success': True,
                'employee_name': self.employee_name,
                'year_month': self.year_month,
                'row_count': len(self.df),
                'columns': list(self.df.columns)
            }
            
        except Exception as e:
            import traceback
            error_details = traceback.format_exc()
            print(f"CSV processing error: {error_details}")
            return {
                'success': False,
                'error': f"CSV読み込みエラー: {str(e)}",
                'details': error_details
            }
    
    def _extract_info_from_filename(self, filename: str):
        """ファイル名から従業員名を抽出（年月はCSVデータから取得）"""
        # ファイル名形式: 勤怠詳細_山田太郎_2025_07.csv
        pattern = r'勤怠詳細_(.+?)_(\d{4})_(\d{2})\.csv'
        match = re.match(pattern, filename)
        
        if match:
            self.employee_name = match.group(1)
        else:
            # パターンに一致しない場合は、ファイル名から推測
            parts = filename.replace('.csv', '').split('_')
            if len(parts) >= 2:
                self.employee_name = parts[1] if len(parts) > 1 else "不明"
            else:
                self.employee_name = "不明"
    
    def _extract_year_month_from_data(self):
        """CSVデータの日付から年月を抽出"""
        try:
            if self.df is not None and '日付' in self.df.columns:
                # 最初の有効な日付を取得
                for date_str in self.df['日付']:
                    if pd.notna(date_str) and str(date_str).strip() != '':
                        date_str = str(date_str).strip()
                        if '/' in date_str:
                            parts = date_str.split('/')
                            if len(parts) >= 2:
                                year = parts[0]
                                month = parts[1].zfill(2)  # 1桁の月を2桁に
                                self.year_month = f"{year}{month}"
                                return
                
                # 日付が見つからない場合はデフォルト
                self.year_month = "202501"
            else:
                self.year_month = "202501"
        except Exception as e:
            print(f"年月抽出エラー: {e}")
            self.year_month = "202501"
    
    def _validate_csv_structure(self) -> bool:
        """CSV構造の検証"""
        if self.df is None:
            raise ValueError("CSVデータが読み込まれていません")
            
        required_columns = ['日付', '始業時刻1', '終業時刻1', '勤怠種別', '総勤務時間']
        
        for col in required_columns:
            if col not in self.df.columns:
                raise ValueError(f"必要な列 '{col}' が見つかりません")
        
        return True
    
    def get_processed_data(self) -> pd.DataFrame:
        """処理済みデータを取得"""
        if self.df is None:
            raise ValueError("CSVファイルが読み込まれていません")
        
        # 氏名列を追加（GUIから入力された従業員名）
        processed_df = self.df.copy()
        processed_df['氏名'] = self.employee_name
        
        # 勤怠メモ列が存在しない場合は空の列を追加
        if '勤怠メモ' not in processed_df.columns:
            processed_df['勤怠メモ'] = ''
        
        return processed_df
    
 