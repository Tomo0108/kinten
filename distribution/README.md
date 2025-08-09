# 📌 Kinten（勤転）配布版

**freee勤怠CSVをExcel勤怠表テンプレートへ自動転記するデスクトップアプリ**

## 🎯 概要

Kinten（勤転）は、freee等の勤怠管理システムからエクスポートしたCSVファイルを読み込み、指定のExcel勤怠表テンプレートへ自動転記し出力する**ローカル専用**のデスクトップアプリです。

## ✨ 機能

- 🔄 **Excel転記機能**: CSV → Excel自動転記
- 📊 **PDF変換機能**: Excel → PDF自動変換
- 🎨 **ニューモフィズムデザイン**: モダンで親しみやすいUI
- 🖥️ **Windows対応**: Windows 10/11対応
- 🔒 **プライバシー重視**: ローカル処理で個人情報を保護

## 📦 セットアップ

### 前提条件
- **Python 3.13以上**がインストールされている必要があります
- Windows 10/11

### インストール手順

1. **Pythonのインストール確認**
   ```bash
   py --version
   ```
   Python 3.13以上が表示されることを確認してください。

2. **必要なライブラリのインストール**
   ```bash
   cd backend
   py -m pip install -r requirements.txt
   ```

3. **アプリの起動**
   ```bash
   cd frontend
   ./kinten.exe
   ```

## 🚀 使用方法

### Excel転記機能

1. **CSVファイルの選択**
   - 「勤怠CSVファイル」ボタンをクリック
   - freeeからエクスポートしたCSVファイルを選択

2. **テンプレートファイルの選択**
   - 「Excelテンプレート」ボタンをクリック
   - 勤怠表テンプレートを選択（デフォルト: 雛形ファイル）

3. **従業員名の入力**
   - 従業員名を入力

4. **自動転記の実行**
   - 「自動転記を実行」ボタンをクリック
   - 処理完了後、出力フォルダが自動で開きます

### PDF変換機能

1. **Excelファイルの選択**
   - 「Excelファイルを選択」ボタンをクリック
   - 変換したいExcelファイルを選択（複数選択可）

2. **PDF変換の実行**
   - 「PDFに変換」ボタンをクリック
   - 処理完了後、出力フォルダが自動で開きます

## 📁 ディレクトリ構造

```
distribution/
├── frontend/
│   ├── kinten.exe                    # メインアプリケーション
│   ├── flutter_windows.dll           # Flutterランタイム
│   └── permission_handler_windows_plugin.dll
├── backend/
│   ├── main_processor.py             # メイン処理ロジック
│   ├── csv_processor.py              # CSV処理
│   ├── excel_processor.py            # Excel処理
│   ├── pdf_converter.py              # PDF変換
│   ├── requirements.txt              # Python依存関係
│   └── kinten_backend.exe            # バックエンド実行ファイル
├── templates/
│   └── 勤怠表雛形_2025年版.xlsx       # デフォルトテンプレート
├── input/                            # 入力ファイル用
└── output/                           # 出力ファイル用
```

## 🔧 トラブルシューティング

### Pythonが見つからないエラー
```bash
# Pythonのインストール確認
py --version

# パスが通っていない場合は、Pythonを再インストールしてください
```

### ライブラリが見つからないエラー
```bash
# バックエンドディレクトリで依存関係を再インストール
cd backend
py -m pip install -r requirements.txt
```

### ファイルが見つからないエラー
- ファイルパスに日本語が含まれている場合、文字化けが原因の可能性があります
- ファイル名を英数字に変更してから試してください

## 📝 対応ファイル形式

### 入力ファイル
- **CSV**: UTF-8エンコーディング
- **Excel**: .xlsx, .xls形式

### 出力ファイル
- **Excel**: .xlsx形式
- **PDF**: .pdf形式

## 🆘 サポート

問題が発生した場合は、以下の情報を確認してください：

1. Pythonのバージョン
2. エラーメッセージの詳細
3. 使用しているファイルの形式
4. アプリのログ出力

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

