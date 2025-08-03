# 📌 Kinten（勤転）

**freee勤怠CSVをExcel勤怠表テンプレートへ自動転記するデスクトップアプリ**

## 🎯 概要

Kinten（勤転）は、freee等の勤怠管理システムからエクスポートしたCSVファイルを読み込み、指定のExcel勤怠表テンプレートへ自動転記し出力する**ローカル専用**のデスクトップアプリです。

## ✨ 特徴

- 🎨 **ニューモフィズムデザイン** - モダンで親しみやすいUI
- 🔄 **ワンクリック変換** - CSV → Excel自動転記
- 📊 **freee対応** - freeeの勤怠CSV形式に対応
- 🖥️ **クロスプラットフォーム** - Windows/macOS対応
- 🚀 **高速処理** - Pythonバックエンドによる効率的な処理
- 🔒 **プライバシー重視** - ローカル処理で個人情報を保護

## 🛠️ 技術スタック

### フロントエンド
- **Flutter** - デスクトップアプリ開発
- **Riverpod** - 状態管理
- **Material Design 3** - UIフレームワーク

### バックエンド
- **Python 3.13** - データ処理
- **pandas** - CSVデータ処理
- **openpyxl** - Excelファイル操作

## 📦 インストール

### 前提条件
- Flutter SDK (3.0.0以上)
- Python 3.13以上
- Windows 10/11 または macOS

### Flutterのインストール

#### Windows
```bash
# 1. Flutterをダウンロード
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip" -OutFile "flutter.zip"

# 2. 展開
Expand-Archive -Path "flutter.zip" -DestinationPath "C:\flutter" -Force

# 3. PATHに追加
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\flutter\bin", [EnvironmentVariableTarget]::User)

# 4. 確認
flutter --version
```

#### macOS
```bash
# Homebrewを使用
brew install flutter

# または手動インストール
# https://docs.flutter.dev/get-started/install/macos
```

### セットアップ手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/your-username/kinten.git
   cd kinten
   ```

2. **Python環境のセットアップ**
   ```bash
   # 仮想環境の作成
   py -m venv venv
   
   # 仮想環境のアクティベート
   .\venv\Scripts\Activate.ps1  # Windows
   source venv/bin/activate     # macOS
   
   # 依存関係のインストール
   pip install -r requirements.txt
   ```

3. **Flutter依存関係のインストール**
   ```bash
   cd frontend
   flutter pub get
   ```

## 🚀 使用方法

### 1. Flutterのインストール確認
```bash
flutter --version
```

### 2. アプリの起動

#### 開発モード
```bash
cd frontend
flutter run -d windows  # Windows
flutter run -d macos    # macOS
```

#### ビルド済みアプリの実行
```bash
# Windows
.\frontend\build\windows\x64\runner\Release\frontend.exe

# または、エクスプローラーで以下をダブルクリック
# frontend\build\windows\x64\runner\Release\frontend.exe
```

### 3. ファイル選択
1. **勤怠CSVファイル** - freeeからエクスポートしたCSVファイルを選択
2. **Excelテンプレート** - 勤怠表テンプレートを選択
3. **出力先フォルダ** - 変換後のExcelファイルの保存先を選択

### 4. 変換実行
「変換して保存」ボタンをクリックして処理を開始

## 📁 ファイル形式

### 入力CSVファイル
- **ファイル名形式**: `勤怠詳細_従業員名_YYYY_MM.csv`
- **必須列**: 日付, 始業時刻, 終業時刻, 勤怠種別, 総勤務時間

### Excelテンプレート
- **初期シート名**: 「勤務表」
- **セル配置**:
  - G6: 従業員名
  - F5: 年
  - H5: 月
  - A11以降: 勤怠データ

### 出力ファイル
- **ファイル名**: `勤怠表_従業員名_YYYYMM.xlsx`
- **シート名**: `勤怠表_YYYYMM`

## 📂 プロジェクト構造

```
kinten/
├── .git/                    # Gitリポジトリ
├── .history/                # エディタ履歴
├── assets/                  # アセットファイル（.gitkeep）
├── backend/                 # Pythonバックエンド
│   ├── __init__.py
│   ├── csv_processor.py     # CSV処理
│   ├── excel_processor.py   # Excel処理
│   ├── main_processor.py    # メイン処理
│   └── create_sample_template.py
├── docs/                    # ドキュメント
│   └── README.md           # プロジェクトドキュメント
├── frontend/                # Flutterフロントエンド
│   ├── lib/
│   │   ├── main.dart
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── pubspec.yaml
│   └── README.md
├── input/                   # 入力ファイル（.gitkeep）
├── output/                  # 出力ファイル
│   ├── .gitkeep
│   └── 2025_06/            # 月別出力フォルダ
├── templates/               # テンプレートファイル
│   └── 勤怠表雛形_2025年版.xlsx
├── venv/                    # Python仮想環境
├── .gitignore              # Git除外設定
├── check_environment.ps1   # 環境チェックスクリプト
├── kinten_要件.md          # 要件定義
├── pyrightconfig.json      # Python設定
├── README.md               # このファイル
├── requirements.txt        # Python依存関係
├── タスクリスト.md         # 開発タスク
└── デザイン要件.md         # デザイン要件
```

## 🔒 プライバシーとセキュリティ

- **ローカル処理**: すべてのデータ処理はローカルで実行
- **個人情報保護**: 個人情報を含むファイルは`.gitignore`で除外
- **データ保持**: 処理後のデータは指定された出力フォルダにのみ保存

## 🧪 テスト

### Pythonバックエンドテスト
```bash
cd backend
python -m pytest tests/
```

### Flutterテスト
```bash
cd frontend
flutter test
```

## 📝 開発

### 開発環境のセットアップ
1. Flutter SDKのインストール
2. Python仮想環境の作成
3. 依存関係のインストール
4. IDE設定（VS Code推奨）

### 環境チェック
```bash
# 環境チェックスクリプトの実行
.\check_environment.ps1
```

## 🤝 貢献

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🆘 サポート

問題や質問がある場合は、[Issues](https://github.com/your-username/kinten/issues)で報告してください。

## 📈 ロードマップ

- [ ] 複数ファイル一括処理
- [ ] カスタムテンプレート対応
- [ ] データ検証機能強化
- [ ] プラグイン機能
- [ ] クラウド同期機能

## 📋 関連ドキュメント

- [要件定義](kinten_要件.md) - プロジェクトの要件
- [デザイン要件](デザイン要件.md) - UI/UXデザイン仕様
- [タスクリスト](タスクリスト.md) - 開発タスク一覧
- [プロジェクトドキュメント](docs/README.md) - 詳細ドキュメント

---

**Kinten（勤転）** - 勤怠データの転記を簡単に 🚀 