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

### 2. ファイル選択
1. **勤怠CSVファイル** - freeeからエクスポートしたCSVファイルを選択
2. **Excelテンプレート** - 勤怠表テンプレートを選択
3. **出力先フォルダ** - 変換後のExcelファイルの保存先を選択

### 3. 変換実行
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

### プロジェクト構造
```
kinten/
├── backend/           # Pythonバックエンド
│   ├── csv_processor.py
│   ├── excel_processor.py
│   └── main_processor.py
├── frontend/          # Flutterフロントエンド
│   ├── lib/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── providers/
│   └── pubspec.yaml
├── assets/            # サンプルファイル
├── docs/              # ドキュメント
└── requirements.txt   # Python依存関係
```

### 開発環境のセットアップ
1. Flutter SDKのインストール
2. Python仮想環境の作成
3. 依存関係のインストール
4. IDE設定（VS Code推奨）

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

---

**Kinten（勤転）** - 勤怠データの転記を簡単に 🚀 