#!/usr/bin/env python3
"""
Flutterアプリから呼び出されるPythonコードのテスト
実際のFlutterアプリと同じ形式でPythonコードを実行してテスト
"""

import sys
import os
import tempfile
import subprocess

def test_flutter_python_integration():
    """FlutterアプリのPython統合テスト"""
    
    print("=== FlutterアプリPython統合テスト ===")
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
    
    # Flutterアプリと同じPythonコードを生成
    python_code = f'''
import sys
import os
print(f"Python version: {{sys.version}}")
print(f"Current working directory: {{os.getcwd()}}")
print(f"Project root: {r"$project_root"}")

# ファイル存在チェック
csv_path = r"{csv_path}"
template_path = r"{template_path}"
output_path = r"{output_path}"

print(f"CSV path: {{csv_path}}")
print(f"CSV exists: {{os.path.exists(csv_path)}}")
print(f"Template path: {{template_path}}")
print(f"Template exists: {{os.path.exists(template_path)}}")
print(f"Output path: {{output_path}}")
print(f"Output exists: {{os.path.exists(output_path)}}")

# バックエンドディレクトリの存在チェック
backend_path = os.path.join(r"{project_root}", "backend")
print(f"Backend path: {{backend_path}}")
print(f"Backend exists: {{os.path.exists(backend_path)}}")

sys.path.append(backend_path)

try:
    from main_processor import KintenProcessor
    print("Successfully imported KintenProcessor")
    
    processor = KintenProcessor()
    result = processor.process_files(
        csv_path,
        template_path,
        output_path,
        r"{employee_name}"
    )
    
    if result["success"]:
        print(f"SUCCESS:{{result['output_folder']}}")
        exit(0)
    else:
        print(f"ERROR:{{result['error']}}")
        exit(1)
        
except Exception as e:
    print(f"ERROR:Exception occurred: {{str(e)}}")
    import traceback
    traceback.print_exc()
    exit(1)
'''
    
    # 一時ファイルにPythonコードを保存
    with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False, encoding='utf-8') as temp_file:
        temp_file.write(python_code)
        temp_file_path = temp_file.name
    
    print(f"\nPython script saved to: {temp_file_path}")
    print(f"Python code length: {len(python_code)}")
    
    try:
        # Pythonスクリプトを実行
        print(f"\nExecuting Python script...")
        result = subprocess.run(
            [sys.executable, temp_file_path],
            cwd=project_root,
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='replace'
        )
        
        print(f"Exit code: {result.returncode}")
        print(f"Stdout: {result.stdout}")
        print(f"Stderr: {result.stderr}")
        
        if result.returncode == 0:
            # 成功時の処理
            output = result.stdout.strip() if result.stdout else ""
            if output.startswith('SUCCESS:'):
                output_folder = output[8:]  # 'SUCCESS:' を除去
                print(f"✅ 処理成功！")
                print(f"出力フォルダ: {output_folder}")
                return 0
            else:
                print(f"✅ 処理成功（出力フォルダ情報なし）")
                return 0
        else:
            # エラー時の処理
            output = result.stdout.strip() if result.stdout else ""
            stderr = result.stderr.strip() if result.stderr else ""
            
            error_message = '処理に失敗しました'
            if output.startswith('ERROR:'):
                error_message = output[6:]  # 'ERROR:' を除去
            elif stderr:
                error_message = stderr
            
            print(f"❌ 処理失敗: {error_message}")
            return 1
            
    except Exception as e:
        print(f"❌ スクリプト実行エラー: {str(e)}")
        return 1
    finally:
        # 一時ファイルを削除
        try:
            os.unlink(temp_file_path)
            print(f"Temporary file deleted: {temp_file_path}")
        except Exception as e:
            print(f"Failed to delete temporary file: {e}")

if __name__ == "__main__":
    exit_code = test_flutter_python_integration()
    sys.exit(exit_code) 