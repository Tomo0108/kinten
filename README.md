# Kinten（勤転）

freee等の勤怠CSVを読み込み、Excel勤怠表テンプレートへ自動転記し、PDF出力にも対応するデスクトップアプリです。処理はすべてローカルで完結します。

## 概要
CSVからExcelへの転記と、ExcelからPDFへの変換を行います。Windows/macOSに対応しています。

## 特徴
- CSV → Excel 自動転記（テンプレート準拠）
- Excel → PDF 変換（WindowsはExcel必須、macOSはExcel優先・フォールバックあり）
- 起動時に`input`/`output`/`templates`を自動作成
- データはすべてローカル処理

## 技術スタック
- フロントエンド: Flutter（Riverpod）
- バックエンド: Python（pandas, openpyxl, reportlab, xlwings ほか）

## 対応環境
- Windows 10/11
- macOS 12以降

## 配布版の使い方
### macOS
1. `package/kinten.zip` を展開
2. `kinten/kinten.app` を起動（初回のみExcel自動化の許可が必要）
3. `kinten/input` にCSVを配置、雛形は `kinten/templates`、出力は `kinten/output`

注意
- Excelがない環境では簡易PDFにフォールバック（レイアウト再現は限定的）
- Gatekeeperでブロックされる場合は右クリック→開く

### Windows
1. `kinten_windows_1.0.0.zip` をダウンロードして展開
2. 展開フォルダ内の `kinten.exe` を起動（バックエンドは `backend/kinten_backend.exe` を自動検出）
3. `input` にCSVを配置、雛形は `templates`、出力は `output`（いずれも展開フォルダ直下）

注意
- PDF変換にはMicrosoft Excel（デスクトップ版）が必要
- バックエンドは `backend/kinten_backend.exe` 同梱のためPythonは不要

## 配布パッケージ構成

Windows（`kinten_windows_1.0.0.zip`）
```
└─ （展開先）/
   ├─ kinten.exe
   ├─ backend/
   │   └─ kinten_backend.exe
   ├─ flutter_windows.dll
   ├─ permission_handler_windows_plugin.dll
   ├─ templates/
   ├─ input/（空）
   └─ output/（空）
```

## ファイル仕様
- 入力CSV名例: `勤怠詳細_従業員名_YYYY_MM.csv`
- テンプレート: `templates/勤怠表雛形_2025年版.xlsx`
- 出力Excel名例: `勤怠表_従業員名_YYYYMM.xlsx`

## プロジェクト構成（抜粋）
```
kinten/
├─ backend/                # Pythonバックエンド
├─ frontend/               # Flutterフロントエンド
├─ templates/              # Excel雛形
├─ input/                  # 入力CSV（空で配布）
├─ output/                 # 出力先（空で配布）
└─ packages/               # 生成された配布ZIP置き場（Git管理外）
```

## 開発者向け（macOS）
- フロントエンドのビルド
  ```bash
  cd frontend
  flutter build macos --release
  ```
- distへの同期
  ```bash
  bash scripts/sync_dist_macos.sh
  ```
- 配布ZIPの作成（Python不要のバックエンド同梱 or backendソース同梱）
  ```bash
  bash scripts/package_macos.sh
  ```

## 開発者向け（Windows）
- ビルド（バックエンド/フロントエンド）
  ```powershell
  .\build_all.ps1
  ```
- 配布ZIPの作成（ローカルはタイムスタンプ付ZIPを生成）
  ```powershell
  .\create_distribution.bat
  ```
- 公式リリースでは ZIP 名を `kinten_windows_1.0.0.zip` に統一

## 既知の要件・制約
- PDF変換:
  - Windows: Microsoft Excel 必須
  - macOS: Excel優先（xlwings）、Excel非導入時は簡易PDFにフォールバック
- 初回起動時:
  - macOS: 「自動化（Excel制御）」の許可が必要
- ログ:
  - macOS: `~/Library/Logs/kinten.log`

## リポジトリ運用
- 生成物はGit管理外（`.gitignore`にて `dist/**`, `packages/**` を除外）
- 個人情報を含むCSVや出力はコミットしない


