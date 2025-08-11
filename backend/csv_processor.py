#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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
            # 文字コード判定のフォールバック
            encodings_to_try = [
                'utf-8',
                'utf-8-sig',
                'cp932',
                'shift_jis',
                'iso-2022-jp',
                'latin-1',
            ]
            last_error: Optional[Exception] = None
            df: Optional[pd.DataFrame] = None
            for enc in encodings_to_try:
                try:
                    df = pd.read_csv(file_path, encoding=enc)
                    # 読めたら採用
                    break
                except Exception as ee:
                    last_error = ee
                    continue
            if df is None:
                raise last_error if last_error is not None else Exception('CSVの読み込みに失敗しました')

            # 列名を正規化（前後空白除去）
            df.columns = [str(c).strip() for c in df.columns]

            # 列名の同義語マッピングを適用
            synonym_mapping = {
                # 時刻系: すべてパイプライン標準の 始業時刻1 / 終業時刻1 に寄せる
                '出勤時刻': '始業時刻1',
                '始業時刻': '始業時刻1',
                '開始時刻': '始業時刻1',
                '開始時間': '始業時刻1',
                '退勤時刻': '終業時刻1',
                '終業時刻': '終業時刻1',
                '終了時刻': '終業時刻1',
                '終了時間': '終業時刻1',
                # メモ系
                '備考': '勤怠メモ',
                'メモ': '勤怠メモ',
            }
            for old_col, new_col in synonym_mapping.items():
                if old_col in df.columns and new_col not in df.columns:
                    df[new_col] = df[old_col]

            # DataFrameを確定
            self.df = df

            # CSVデータから年月を抽出
            self._extract_year_month_from_data()

            # データ検証
            _ = self._validate_csv_structure()

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
                        
                        # YYYY-MM-DD形式の処理
                        if '-' in date_str:
                            parts = date_str.split('-')
                            if len(parts) >= 2:
                                year = parts[0]
                                month = parts[1].zfill(2)  # 1桁の月を2桁に
                                self.year_month = f"{year}{month}"
                                return
                        
                        # YYYY/MM/DD形式の処理
                        elif '/' in date_str:
                            parts = date_str.split('/')
                            if len(parts) >= 2:
                                year = parts[0]
                                month = parts[1].zfill(2)  # 1桁の月を2桁に
                                self.year_month = f"{year}{month}"
                                return

                        # YYYY年MM月DD日 形式の処理
                        elif ('年' in date_str) and ('月' in date_str):
                            try:
                                y_idx = date_str.index('年')
                                m_idx = date_str.index('月')
                                year = date_str[:y_idx]
                                month = date_str[y_idx+1:m_idx].strip().zfill(2)
                                if len(year) == 4 and month.isdigit():
                                    self.year_month = f"{year}{month}"
                                    return
                            except Exception:
                                pass
                
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
            
        # 基本的な列の存在チェック
        basic_required_columns = ['日付']
        
        for col in basic_required_columns:
            if col not in self.df.columns:
                raise ValueError(f"必要な列 '{col}' が見つかりません")
        
        # 時刻関連の列を柔軟にチェック
        time_columns = ['出勤時刻', '退勤時刻', '始業時刻1', '終業時刻1']
        found_time_columns = [col for col in time_columns if col in self.df.columns]
        
        if not found_time_columns:
            raise ValueError("時刻関連の列（出勤時刻/退勤時刻 または 始業時刻1/終業時刻1）が見つかりません")
        
        return True
    
    def get_processed_data(self) -> pd.DataFrame:
        """処理済みデータを取得"""
        if self.df is None:
            raise ValueError("CSVファイルが読み込まれていません")
        
        # 氏名列を追加（GUIから入力された従業員名）
        processed_df = self.df.copy()
        processed_df['氏名'] = self.employee_name
        
        # 列名の統一化
        column_mapping = {
            '出勤時刻': '始業時刻1',
            '退勤時刻': '終業時刻1',
            '勤務時間': '総勤務時間',
            '備考': '勤怠メモ'
        }
        
        # 列名を統一
        for old_col, new_col in column_mapping.items():
            if old_col in processed_df.columns and new_col not in processed_df.columns:
                processed_df[new_col] = processed_df[old_col]
        
        # 必要な列が存在しない場合は空の列を追加
        required_columns = ['勤怠種別', '勤怠メモ']
        for col in required_columns:
            if col not in processed_df.columns:
                processed_df[col] = ''
        
        return processed_df
    
 