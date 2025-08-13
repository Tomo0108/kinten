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
from datetime import datetime

# バックエンドモジュールをインポート
# KintenProcessor のインポートを堅牢化
try:
    # 1) 同一ディレクトリ
    from main_processor import KintenProcessor  # type: ignore
except Exception:
    try:
        # 2) パッケージ形式（PyInstallerやパッケージ実行時）
        from backend.main_processor import KintenProcessor  # type: ignore
    except Exception:
        # 3) 明示的に現在ファイルのディレクトリをパスに追加して再試行
        import os, sys
        sys.path.insert(0, os.path.dirname(__file__))
        from main_processor import KintenProcessor  # type: ignore

def _resolve_log_dir(data: dict) -> str:
    try:
        for key in ('output_dir', 'base_output_dir', 'output_folder'):
            v = data.get(key)
            if isinstance(v, str) and v.strip():
                p = os.path.join(v, 'logs')
                os.makedirs(p, exist_ok=True)
                return p
    except Exception:
        pass
    # フォールバック: CWD/output/logs
    p = os.path.join(os.getcwd(), 'output', 'logs')
    try:
        os.makedirs(p, exist_ok=True)
    except Exception:
        pass
    return p


def _write_log(log_dir: str, message: str) -> None:
    try:
        ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        with open(os.path.join(log_dir, 'backend.log'), 'a', encoding='utf-8') as f:
            f.write(f'[{ts}] {message}\n')
    except Exception:
        pass


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
        log_dir = _resolve_log_dir(data)
        _write_log(log_dir, 'backend start')
        _write_log(log_dir, f'cwd={os.getcwd()}')
        _write_log(log_dir, f'python={sys.version}')
        _write_log(log_dir, f'platform={sys.platform}')
        
        # 処理タイプを取得
        process_type = data.get('process_type', 'csv_to_excel')
        _write_log(log_dir, f'process_type={process_type}')
        
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
            _write_log(log_dir, f'csv_to_excel success={result.get("success")} output_dir={output_dir}')
        
        elif process_type == 'get_excel_files':
            # Excelファイル取得処理
            folder_path = data.get('folder_path', '')
            if not folder_path:
                print(json.dumps({"error": "フォルダパスが指定されていません"}))
                return
            
            result = processor.get_excel_files(folder_path)
            _write_log(log_dir, f'get_excel_files success={result.get("success")} folder={folder_path}')
        
        elif process_type == 'create_pdf_output_folder':
            # PDF出力フォルダ作成処理
            base_output_dir = data.get('base_output_dir', '')
            if not base_output_dir:
                print(json.dumps({"error": "出力ディレクトリが指定されていません"}))
                return
            
            result = processor.create_pdf_output_folder(base_output_dir)
            _write_log(log_dir, f'create_pdf_output_folder success={result.get("success")} base={base_output_dir}')
        
        elif process_type == 'convert_to_pdf':
            # PDF変換処理
            excel_files = data.get('excel_files', [])
            output_folder = data.get('output_folder', '')
            
            if not excel_files or not output_folder:
                print(json.dumps({"error": "Excelファイルまたは出力フォルダが指定されていません"}))
                return
            
            result = processor.convert_excel_to_pdf(excel_files, output_folder)
            _write_log(log_dir, f'convert_to_pdf success={result.get("success")} out={output_folder} converted={result.get("total_converted")}')
        
        elif process_type == 'open_folder':
            # フォルダを開く処理
            folder_path = data.get('folder_path', '')
            if not folder_path:
                print(json.dumps({"error": "フォルダパスが指定されていません"}))
                return
            
            result = processor.open_folder(folder_path)
            _write_log(log_dir, f'open_folder success={result.get("success")} folder={folder_path}')
        
        else:
            print(json.dumps({"error": f"不明な処理タイプ: {process_type}"}))
            return
        
        # 結果をJSONで出力
        print(json.dumps(result, ensure_ascii=False))
        _write_log(log_dir, f'completed success={result.get("success")}')
        
    except json.JSONDecodeError as e:
        try:
            _write_log(_resolve_log_dir({}), f'json decode error: {str(e)}')
        except Exception:
            pass
        print(json.dumps({"error": f"JSONパースエラー: {str(e)}"}))
    except Exception as e:
        error_info = {
            "error": f"予期しないエラーが発生しました: {str(e)}",
            "traceback": traceback.format_exc()
        }
        try:
            _write_log(_resolve_log_dir({}), f'exception: {str(e)}')
            _write_log(_resolve_log_dir({}), error_info.get('traceback',''))
        except Exception:
            pass
        print(json.dumps(error_info, ensure_ascii=False))

if __name__ == "__main__":
    main() 