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
1. Windows端末で PowerShell を開き、`scripts/package_windows.ps1` を実行して `package/kinten_windows.zip` を作成
2. 展開後、`kinten/kinten.exe` を起動
3. `kinten/input` にCSVを配置、雛形は `kinten/templates`、出力は `kinten/output`

注意
- PDF変換にはMicrosoft Excel（デスクトップ版）が必要
- バックエンドは `kinten_backend.exe` 同梱のためPythonは不要（同時に `backend/` ソースも同梱され、フォールバックとして利用可能）

## 配布パッケージ構成
```
kinten.zip
└─ kinten/
   ├─ kinten.app（macOS）または kinten.exe（Windows）
   ├─ kinten_backend（macOS）/ kinten_backend.exe（Windows）
   ├─ backend/
   ├─ templates/
   ├─ input/（空）
   ├─ output/（空）
   └─ requirements.txt
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
├─ scripts/                # 同期/パッケージングスクリプト
└─ package/                # 生成された配布ZIP置き場（Git管理外）
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
- 配布ZIPの作成（Flutterリリースビルド + PyInstaller同梱）
  ```powershell
  scripts\package_windows.ps1
  ```

## 既知の要件・制約
- PDF変換:
  - Windows: Microsoft Excel 必須
  - macOS: Excel優先（xlwings）、Excel非導入時は簡易PDFにフォールバック
- 初回起動時:
  - macOS: 「自動化（Excel制御）」の許可が必要
- ログ:
  - macOS: `~/Library/Logs/kinten.log`

## リポジトリ運用
- 生成物はGit管理外（`.gitignore`にて `dist/**`, `package/**` を除外）
- 個人情報を含むCSVや出力はコミットしない


