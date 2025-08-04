# Kinten（勤転）

**freee勤怠CSVをExcel勤怠表テンプレートへ自動転記するデスクトップアプリ**

## 概要

Kinten（勤転）は、freee等の勤怠管理システムからエクスポートしたCSVファイルを読み込み、指定のExcel勤怠表テンプレートへ自動転記し出力するFlutterデスクトップアプリです。

## 特徴

- 🎨 **ニューモフィズムデザイン** - モダンで親しみやすいUI
- 🔄 **ワンクリック変換** - CSV → Excel自動転記
- 📊 **freee対応** - freeeの勤怠CSV形式に対応
- 🖥️ **クロスプラットフォーム** - Windows/macOS対応
- 🔒 **プライバシー重視** - ローカル処理で個人情報を保護

## 開発

### セットアップ

```bash
# 依存関係のインストール
flutter pub get

# 開発モードで実行
flutter run -d windows  # Windows
flutter run -d macos    # macOS
```

### ビルド

```bash
# Windows用ビルド
flutter build windows

# macOS用ビルド
flutter build macos
```

## 技術スタック

- **Flutter** - デスクトップアプリ開発
- **Riverpod** - 状態管理
- **Material Design 3** - UIフレームワーク
- **Python** - バックエンド処理（../backend/）

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
