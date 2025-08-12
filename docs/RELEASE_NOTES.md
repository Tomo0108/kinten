# リリースノート

## ver1.0.1
- Flutter フロントエンドのバージョンを `1.0.1+2` に更新（`frontend/pubspec.yaml`）
- macOS 配布用スクリプト `scripts/package_macos.sh` を追加
  - `dist/` 同期後、`kinten.app` と `backend/` 一式、`templates/`、`input/`、`output/`、`requirements.txt` を同梱
  - `package/kinten.zip` を作成
- 転記処理の Python 実行経路を確認
  - `frontend/lib/providers/app_state_provider.dart` は `backend/` を `PYTHONPATH` に追加し、ランタイムに Python または `.venv/bin/python` を解決
  - Windows では `kinten_backend.exe` があれば優先実行（Python不要）

インストール/実行上の注意:
- macOS では同梱の `backend/` と `requirements.txt` を利用し、初回のみ仮想環境の作成と依存導入が必要な場合があります（`pywin32` は macOS では無視されます）。
- Windows では `kinten_backend.exe` 同梱により Python 不要。