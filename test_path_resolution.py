#!/usr/bin/env python3
"""
パス解決ロジックのテストスクリプト
Flutterアプリの実行時のパス処理をシミュレート
"""

import os
import sys

def test_path_resolution():
    """パス解決ロジックのテスト"""
    
    print("=== パス解決ロジックテスト ===")
    
    # 現在のディレクトリを取得
    current_dir = os.getcwd()
    print(f"現在のディレクトリ: {current_dir}")
    
    # Flutterアプリがビルドされて実行される場合のパス処理をシミュレート
    if 'frontend\\build\\windows\\x64\\runner\\Release' in current_dir:
        print("Releaseディレクトリからプロジェクトルートを取得中...")
        
        # Releaseディレクトリから4階層上に移動してプロジェクトルートを取得
        release_dir = current_dir
        runner_dir = os.path.dirname(release_dir)
        x64_dir = os.path.dirname(runner_dir)
        windows_dir = os.path.dirname(x64_dir)
        build_dir = os.path.dirname(windows_dir)
        frontend_dir = os.path.dirname(build_dir)
        project_root = os.path.dirname(frontend_dir)
        
        print(f"Release: {release_dir}")
        print(f"Runner: {runner_dir}")
        print(f"x64: {x64_dir}")
        print(f"Windows: {windows_dir}")
        print(f"Build: {build_dir}")
        print(f"Frontend: {frontend_dir}")
        print(f"Project Root: {project_root}")
        
        # ファイル存在チェック
        csv_path = os.path.join(project_root, 'input', '勤怠詳細_小島　知将_2025_07.csv')
        template_path = os.path.join(project_root, 'templates', '勤怠表雛形_2025年版.xlsx')
        
        print(f"\nCSVファイルパス: {csv_path}")
        print(f"CSVファイル存在: {os.path.exists(csv_path)}")
        
        print(f"テンプレートファイルパス: {template_path}")
        print(f"テンプレートファイル存在: {os.path.exists(template_path)}")
        
        return project_root
        
    elif current_dir.endswith('frontend') or current_dir.endswith('frontend\\'):
        print("Frontendディレクトリからプロジェクトルートを取得中...")
        project_root = os.path.dirname(current_dir)
        print(f"Project Root: {project_root}")
        return project_root
        
    else:
        print("現在のディレクトリをプロジェクトルートとして使用")
        print(f"Project Root: {current_dir}")
        return current_dir

if __name__ == "__main__":
    project_root = test_path_resolution()
    print(f"\n✅ テスト完了！プロジェクトルート: {project_root}") 