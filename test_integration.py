"""
Kintenアプリの統合テスト
Flutterアプリとバックエンドの連携をテスト
"""

import sys
import os
import shutil
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend'))

from backend.main_processor import KintenProcessor

def test_integration():
    """統合テスト"""
    
    print("=== Kinten 統合テスト ===")
    
    # テストファイルパス
    csv_path = "assets/勤怠詳細_サンプル _2024_10.csv"
    template_path = "assets/勤怠表雛形_2025年版.xlsx"
    output_path = "output/test_integration.xlsx"
    
    print(f"CSVファイル: {csv_path}")
    print(f"テンプレート: {template_path}")
    print(f"出力先: {output_path}")
    print()
    
    # プロセッサー作成
    processor = KintenProcessor()
    
    # 1. 入力ファイル検証テスト
    print("1. 入力ファイル検証テスト...")
    validation = processor.validate_inputs(csv_path, template_path, "output")
    if validation['valid']:
        print("✅ 入力ファイル検証成功")
    else:
        print("❌ 入力ファイル検証失敗:")
        for error in validation['errors']:
            print(f"   - {error}")
        return False
    
    # 2. メイン処理テスト
    print("\n2. メイン処理テスト...")
    result = processor.process_files(csv_path, template_path, output_path)
    
    if result['success']:
        print("✅ 処理成功!")
        print(f"   従業員名: {result['employee_name']}")
        print(f"   年月: {result['year_month']}")
        print(f"   処理行数: {result['row_count']}")
        print(f"   出力ファイル: {result['output_path']}")
    else:
        print("❌ 処理失敗:")
        print(f"   エラー: {result['error']}")
        return False
    
    # 3. 出力ファイル検証テスト
    print("\n3. 出力ファイル検証テスト...")
    if os.path.exists(output_path):
        file_size = os.path.getsize(output_path)
        print(f"✅ 出力ファイル生成成功 (サイズ: {file_size} bytes)")
    else:
        print("❌ 出力ファイルが生成されませんでした")
        return False
    
    # 4. エラーハンドリングテスト
    print("\n4. エラーハンドリングテスト...")
    
    # 存在しないファイルでのテスト
    invalid_result = processor.process_files(
        "存在しないファイル.csv",
        template_path,
        output_path
    )
    
    if not invalid_result['success']:
        print("✅ エラーハンドリング正常")
    else:
        print("❌ エラーハンドリング異常")
        return False
    
    print("\n=== 統合テスト完了 ===")
    print("✅ すべてのテストが成功しました！")
    
    return True

def test_app_components():
    """アプリコンポーネントのテスト"""
    
    print("\n=== アプリコンポーネントテスト ===")
    
    # 1. バックエンドコンポーネントテスト
    print("1. バックエンドコンポーネントテスト...")
    
    try:
        from backend.csv_processor import CSVProcessor
        from backend.excel_processor import ExcelProcessor
        from backend.main_processor import KintenProcessor
        
        csv_processor = CSVProcessor()
        excel_processor = ExcelProcessor()
        main_processor = KintenProcessor()
        
        print("✅ バックエンドコンポーネント読み込み成功")
        
    except ImportError as e:
        print(f"❌ バックエンドコンポーネント読み込み失敗: {e}")
        return False
    
    # 2. ファイル構造テスト
    print("\n2. ファイル構造テスト...")
    
    required_files = [
        "backend/__init__.py",
        "backend/csv_processor.py",
        "backend/excel_processor.py",
        "backend/main_processor.py",
        "frontend/lib/main.dart",
        "frontend/lib/screens/home_screen.dart",
        "frontend/lib/widgets/neumorphic_button.dart",
        "frontend/lib/widgets/file_selector.dart",
        "frontend/lib/providers/app_state_provider.dart"
    ]
    
    missing_files = []
    for file_path in required_files:
        if not os.path.exists(file_path):
            missing_files.append(file_path)
    
    if missing_files:
        print("❌ 以下のファイルが見つかりません:")
        for file_path in missing_files:
            print(f"   - {file_path}")
        return False
    else:
        print("✅ ファイル構造正常")
    
    # 3. 依存関係テスト
    print("\n3. 依存関係テスト...")
    
    try:
        import pandas as pd
        import openpyxl
        print("✅ Python依存関係正常")
    except ImportError as e:
        print(f"❌ Python依存関係エラー: {e}")
        return False
    
    print("\n=== アプリコンポーネントテスト完了 ===")
    print("✅ すべてのコンポーネントが正常です！")
    
    return True

if __name__ == "__main__":
    # 統合テスト実行
    integration_success = test_integration()
    
    # コンポーネントテスト実行
    component_success = test_app_components()
    
    # 結果サマリー
    print("\n" + "="*50)
    print("テスト結果サマリー")
    print("="*50)
    
    if integration_success and component_success:
        print("🎉 すべてのテストが成功しました！")
        print("アプリは正常に動作します。")
    else:
        print("⚠️  一部のテストが失敗しました。")
        if not integration_success:
            print("- 統合テストに問題があります")
        if not component_success:
            print("- コンポーネントテストに問題があります")
    
    print("="*50) 