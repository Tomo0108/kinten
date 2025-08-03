#!/usr/bin/env python3
"""
Flutterアプリ統合テスト
Flutterアプリから呼び出されるPythonコードをシミュレート
"""

import sys
import os
from typing import TYPE_CHECKING, Optional

# 型チェック時のみインポート（Pylanceエラー回避）
if TYPE_CHECKING:
    from main_processor import KintenProcessor

def test_flutter_integration():
    """Flutterアプリの統合テスト"""
    
    print("=== Flutterアプリ統合テスト ===")
    print(f"Python version: {sys.version}")
    print(f"Current working directory: {os.getcwd()}")
    
    # プロジェクトルートを取得（Flutterアプリと同じロジック）
    current_dir = os.getcwd()
    project_root = None
    
    if 'frontend\\build\\windows\\x64\\runner\\Release' in current_dir:
        # Releaseディレクトリから4階層上に移動してプロジェクトルートを取得
        release_dir = current_dir
        runner_dir = os.path.dirname(release_dir)
        x64_dir = os.path.dirname(runner_dir)
        windows_dir = os.path.dirname(x64_dir)
        build_dir = os.path.dirname(windows_dir)
        frontend_dir = os.path.dirname(build_dir)
        project_root = os.path.dirname(frontend_dir)
        print(f"Project root (from Release): {project_root}")
    elif current_dir.endswith('frontend') or current_dir.endswith('frontend\\'):
        project_root = os.path.dirname(current_dir)
        print(f"Project root (from frontend): {project_root}")
    else:
        project_root = current_dir
        print(f"Project root (current): {project_root}")
    
    # テスト用パラメータ
    csv_path = os.path.join(project_root, 'input', '勤怠詳細_小島　知将_2025_07.csv')
    template_path = os.path.join(project_root, 'templates', '勤怠表雛形_2025年版.xlsx')
    output_path = os.path.join(project_root, 'output')
    employee_name = '小島　知将'
    
    print(f"\nテストパラメータ:")
    print(f"CSV path: {csv_path}")
    print(f"Template path: {template_path}")
    print(f"Output path: {output_path}")
    print(f"Employee name: {employee_name}")
    
    # ファイル存在チェック
    print(f"\nファイル存在チェック:")
    print(f"CSV exists: {os.path.exists(csv_path)}")
    print(f"Template exists: {os.path.exists(template_path)}")
    print(f"Output exists: {os.path.exists(output_path)}")
    
    # バックエンドディレクトリの存在チェック
    backend_path = os.path.join(project_root, 'backend')
    print(f"Backend path: {backend_path}")
    print(f"Backend exists: {os.path.exists(backend_path)}")
    
    # バックエンドのインポートテスト
    try:
        sys.path.insert(0, backend_path)
        print(f"Added {backend_path} to sys.path")
        
        # バックエンドディレクトリの内容を確認
        if os.path.exists(backend_path):
            print(f"Backend directory contents:")
            for file in os.listdir(backend_path):
                print(f"  - {file}")
        
        from main_processor import KintenProcessor
        print("✅ Successfully imported KintenProcessor")
        
        # 処理実行
        processor: KintenProcessor = KintenProcessor()
        result = processor.process_files(
            csv_path,
            template_path,
            output_path,
            employee_name
        )
        
        if result["success"]:
            print(f"✅ 処理成功！")
            print(f"出力フォルダ: {result['output_folder']}")
            print(f"SUCCESS:{result['output_folder']}")
            return 0
        else:
            print(f"❌ 処理失敗: {result['error']}")
            print(f"ERROR:{result['error']}")
            return 1
            
    except Exception as e:
        print(f"❌ エラーが発生しました: {str(e)}")
        import traceback
        traceback.print_exc()
        print(f"ERROR:Exception occurred: {str(e)}")
        return 1

if __name__ == "__main__":
    exit_code = test_flutter_integration()
    sys.exit(exit_code) 