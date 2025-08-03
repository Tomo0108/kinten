#!/usr/bin/env python3
"""
Flutterアプリのデバッグ用スクリプト
Flutterアプリから呼び出される際の詳細なログを出力
"""

import sys
import os
import traceback
import json
from datetime import datetime

def debug_flutter_app():
    """Flutterアプリのデバッグ情報を出力"""
    
    # ログファイルに詳細情報を記録
    log_file = "flutter_app_debug.log"
    
    with open(log_file, "w", encoding="utf-8") as f:
        f.write(f"=== Flutterアプリデバッグログ ===\n")
        f.write(f"Timestamp: {datetime.now()}\n")
        f.write(f"Python version: {sys.version}\n")
        f.write(f"Current working directory: {os.getcwd()}\n")
        f.write(f"Python executable: {sys.executable}\n")
        f.write(f"Platform: {sys.platform}\n")
        f.write(f"Environment variables:\n")
        
        for key, value in os.environ.items():
            if 'PYTHON' in key.upper() or 'PATH' in key.upper():
                f.write(f"  {key}: {value}\n")
        
        f.write(f"\nCommand line arguments:\n")
        for i, arg in enumerate(sys.argv):
            f.write(f"  {i}: {arg}\n")
        
        f.write(f"\nCurrent directory contents:\n")
        try:
            for item in os.listdir('.'):
                f.write(f"  {item}\n")
        except Exception as e:
            f.write(f"  Error listing directory: {e}\n")
        
        f.write(f"\nBackend directory check:\n")
        backend_path = os.path.join(os.getcwd(), "backend")
        f.write(f"Backend path: {backend_path}\n")
        f.write(f"Backend exists: {os.path.exists(backend_path)}\n")
        
        if os.path.exists(backend_path):
            f.write(f"Backend contents:\n")
            try:
                for item in os.listdir(backend_path):
                    f.write(f"  {item}\n")
            except Exception as e:
                f.write(f"  Error listing backend: {e}\n")
        
        f.write(f"\nImport test:\n")
        try:
            sys.path.append(backend_path)
            from main_processor import KintenProcessor
            f.write(f"✅ Successfully imported KintenProcessor\n")
            
            processor = KintenProcessor()
            f.write(f"✅ Successfully created KintenProcessor instance\n")
            
        except Exception as e:
            f.write(f"❌ Import error: {str(e)}\n")
            f.write(f"Traceback:\n")
            traceback.print_exc(file=f)
    
    print(f"Debug information written to: {log_file}")
    return 0

if __name__ == "__main__":
    exit_code = debug_flutter_app()
    sys.exit(exit_code) 