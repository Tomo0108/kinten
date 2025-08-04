#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Kinten Python Backend
Flutterアプリから呼び出されるPythonバックエンド処理
"""

import sys
import os
import json
import traceback
from pathlib import Path

# バックエンドモジュールをインポート
from main_processor import KintenProcessor

def main():
    """メイン処理関数"""
    try:
        # 標準入力からJSONデータを読み取り
        input_data = sys.stdin.read()
        if not input_data.strip():
            print(json.dumps({"error": "入力データが空です"}))
            return
        
        # JSONをパース
        data = json.loads(input_data)
        
        # 処理タイプを取得
        process_type = data.get('process_type', 'csv_to_excel')
        
        # メインプロセッサーを初期化
        processor = KintenProcessor()
        
        if process_type == 'csv_to_excel':
            # CSV to Excel処理
            csv_path = data.get('csv_path', '')
            template_path = data.get('template_path', '')
            output_dir = data.get('output_dir', '')
            employee_name = data.get('employee_name', '')
            
            # パラメータの検証
            if not all([csv_path, template_path, output_dir, employee_name]):
                print(json.dumps({"error": "必要なパラメータが不足しています"}))
                return
            
            # ファイルの存在確認
            if not os.path.exists(csv_path):
                print(json.dumps({"error": f"CSVファイルが見つかりません: {csv_path}"}))
                return
            
            if not os.path.exists(template_path):
                print(json.dumps({"error": f"テンプレートファイルが見つかりません: {template_path}"}))
                return
            
            # 出力ディレクトリの作成
            os.makedirs(output_dir, exist_ok=True)
            
            # 処理を実行
            result = processor.process_files(
                csv_path=csv_path,
                template_path=template_path,
                base_output_dir=output_dir,
                employee_name=employee_name
            )
        
        elif process_type == 'get_excel_files':
            # Excelファイル取得処理
            folder_path = data.get('folder_path', '')
            if not folder_path:
                print(json.dumps({"error": "フォルダパスが指定されていません"}))
                return
            
            result = processor.get_excel_files(folder_path)
        
        elif process_type == 'create_pdf_output_folder':
            # PDF出力フォルダ作成処理
            base_output_dir = data.get('base_output_dir', '')
            if not base_output_dir:
                print(json.dumps({"error": "出力ディレクトリが指定されていません"}))
                return
            
            result = processor.create_pdf_output_folder(base_output_dir)
        
        elif process_type == 'convert_to_pdf':
            # PDF変換処理
            excel_files = data.get('excel_files', [])
            output_folder = data.get('output_folder', '')
            
            if not excel_files or not output_folder:
                print(json.dumps({"error": "Excelファイルまたは出力フォルダが指定されていません"}))
                return
            
            result = processor.convert_excel_to_pdf(excel_files, output_folder)
        
        elif process_type == 'open_folder':
            # フォルダを開く処理
            folder_path = data.get('folder_path', '')
            if not folder_path:
                print(json.dumps({"error": "フォルダパスが指定されていません"}))
                return
            
            result = processor.open_folder(folder_path)
        
        else:
            print(json.dumps({"error": f"不明な処理タイプ: {process_type}"}))
            return
        
        # 結果をJSONで出力
        print(json.dumps(result, ensure_ascii=False))
        
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"JSONパースエラー: {str(e)}"}))
    except Exception as e:
        error_info = {
            "error": f"予期しないエラーが発生しました: {str(e)}",
            "traceback": traceback.format_exc()
        }
        print(json.dumps(error_info, ensure_ascii=False))

if __name__ == "__main__":
    main() 