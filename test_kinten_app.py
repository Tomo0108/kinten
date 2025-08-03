#!/usr/bin/env python3
"""
Kintenアプリのテストスクリプト
指定されたCSVファイルでテストを実行
"""

import sys
import os
sys.path.append('backend')

from backend.main_processor import KintenProcessor

def test_kinten_app():
    """Kintenアプリのテスト実行"""
    
    # テスト用ファイルパス
    csv_path = 'input/勤怠詳細_小島　知将_2025_07.csv'
    template_path = 'templates/勤怠表雛形_2025年版.xlsx'
    output_dir = 'output'
    employee_name = '小島　知将'
    
    print("=== Kintenアプリ テスト開始 ===")
    print(f"CSVファイル: {csv_path}")
    print(f"テンプレート: {template_path}")
    print(f"出力先: {output_dir}")
    print(f"従業員名: {employee_name}")
    print()
    
    # ファイル存在チェック
    if not os.path.exists(csv_path):
        print(f"❌ CSVファイルが見つかりません: {csv_path}")
        return False
    
    if not os.path.exists(template_path):
        print(f"❌ テンプレートファイルが見つかりません: {template_path}")
        return False
    
    print("✅ ファイル存在チェック完了")
    
    try:
        # KintenProcessorのインスタンス作成
        processor = KintenProcessor()
        
        # ファイル処理実行
        print("🔄 ファイル処理中...")
        result = processor.process_files(csv_path, template_path, output_dir, employee_name)
        
        if result['success']:
            print("✅ 処理成功！")
            print(f"出力ファイル: {result['output_path']}")
            print(f"出力フォルダ: {result['output_folder']}")
            print(f"処理行数: {result['row_count']}")
            return True
        else:
            print(f"❌ 処理失敗: {result['error']}")
            return False
            
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        return False

if __name__ == "__main__":
    success = test_kinten_app()
    if success:
        print("\n🎉 テスト完了！")
    else:
        print("\n💥 テスト失敗！")
        sys.exit(1) 