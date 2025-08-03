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
        
        # 必要なパラメータを取得
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
        
        # メインプロセッサーを初期化
        processor = KintenProcessor()
        
        # 処理を実行
        result = processor.process_files(
            csv_path=csv_path,
            template_path=template_path,
            base_output_dir=output_dir,
            employee_name=employee_name
        )
        
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