# macOS 開発ルール（Kinten）

このドキュメントは、macOS 上で Kinten（フロントエンド＋Python バックエンド）の開発・ビルド・動作確認を行うための実務ルールです。Windows 版の安定性を損なわない前提で、Mac 版の作業を進めるための基準を定めます。

## 対象ブランチ
- Mac 全機能対応ブランチ: `feature/macos-full-support`
  - Windows 版の安定運用は既存ブランチ（例: `cursor/fix-pdf-conversion-for-cross-platform-compatibility-8ecc`）で維持
  - Mac 向けのコード変更・調整は必ず `feature/macos-full-support` 上で実施

## 必須要件（ソフトウェア）
- Apple Silicon/Intel Mac（macOS 12 以降推奨）
- Flutter SDK（macOS デスクトップ対応有効）
  - `flutter doctor -v` がグリーンであること
  - `flutter config --enable-macos-desktop`
- Xcode（Command Line Tools を含む）
- Python 3.x（3.10〜3.13 目安）
- Microsoft Excel for Mac（デスクトップ版）
  - PDF 変換は Excel アプリ必須（Excel が無い環境ではエラー終了）
  - 初回実行時に「自動化の許可（Automation）」ダイアログが出る場合があるため許可すること
  - システム設定 > プライバシーとセキュリティ > 自動化 で `kinten.app`（後述）または使用ターミナルに対する Excel 制御を許可

## リポジトリ運用ルール
- Mac 向けの仕様追加・調整は `feature/macos-full-support` にコミット
- PR 作成時は「Mac 全機能対応」範囲に限定（UI/UX 変更は事前合意がある場合のみ）
- コミットメッセージは一行で簡潔に（例: `docs: macOS開発ルール追加`）

## ディレクトリとビルド成果物
- 既存 Windows 版は `dist/` を使用中
- Mac 版は基本的に `.app` が成果物
  - Flutter ビルド出力: `frontend/build/macos/Build/Products/Release/kinten.app`
- 配布作業例（暫定）
  - `dist/` 直下に Mac 用をまとめる場合: `dist/macos/kinten.app`
  - 併せてバックエンドの `backend/` と `requirements.txt` を同フォルダに配置（必要に応じて）
  - 実運用の配布レイアウトは今後 `feature/macos-full-support` 内で最終化

## Python 環境（macOS）
- 仮想環境の作成
  ```bash
  cd /path/to/kinten
  python3 -m venv venv
  source venv/bin/activate
  python3 -m pip install --upgrade pip
  ```
- 依存ライブラリのインストール
  - Windows 専用の `pywin32` は macOS ではインストール不可のため除外
  - 方法A（個別指定）：
    ```bash
    pip install openpyxl==3.1.2 pandas==2.2.0 numpy==1.26.4 \
               reportlab==4.2.5 xlsxwriter==3.2.0 Pillow==10.4.0
    ```
  - 方法B（requirements.txt から除外して一括）：
    ```bash
    # zsh/bash のプロセス置換が使える場合
    pip install -r <(grep -v 'pywin32' requirements.txt)

    # 使えない場合のフォールバック
    grep -v 'pywin32' requirements.txt > requirements_mac.txt
    pip install -r requirements_mac.txt
    ```

## フロントエンド（Flutter）
- 事前準備
  ```bash
  flutter doctor -v
  flutter config --enable-macos-desktop
  ```
- 実行（開発）
  ```bash
  cd frontend
  flutter run -d macos
  ```
  - 備考: 実行ディレクトリは `frontend/` を想定
- ビルド（リリース）
  ```bash
  cd frontend
  flutter build macos --release
  # 出力: frontend/build/macos/Build/Products/Release/kinten.app
  ```

## バックエンド（Python）実行要件（Mac）
- Kinten の PDF 変換は macOS でも Excel（デスクトップ版）が必須
  - 未インストール時は「Excelがインストールされていません」エラーで停止
- バックエンドは Flutter アプリから `python3` 経由で `backend/` を直接呼び出し
  - PATH に `python3` があること
  - 依存ライブラリ（openpyxl/pandas/xlsxwriter/Pillow 等）が導入済であること
- 自動化許可（Automation）
  - 初回に `kinten.app`（もしくは実行しているターミナル）→ Excel 制御の許可が求められる場合あり

## 動作確認フロー（Mac）
1. venv 構築＋依存導入（上記手順）
2. Excel for Mac の導入確認（起動できること）
3. Flutter アプリを実行して以下を確認
   - CSV → Excel 転記が成功すること
   - PDF 変換タブの注意文が表示されること
   - PDF 変換が成功すること（Excel アプリが自動起動し、PDF が生成される）
   - Excel 未導入環境では適切なエラーメッセージが表示されること

## トラブルシューティング（Mac）
- Excel の自動化で止まる/失敗する
  - システム設定 > プライバシーとセキュリティ > 自動化 を確認し、`kinten.app`/ターミナルからの Excel 制御を許可
  - Excel を一度手動起動してライセンス/EULA 初期設定を完了させる
- Python 依存の導入で失敗する
  - `pywin32` は macOS では不要なので requirements から除外してインストール
  - `pip cache purge` 後に再試行
- Gatekeeper による実行ブロック
  - 右クリック（control+クリック）> 開く で初回実行を許可

## 守るべき制約
- 既存 Windows 版のビルド・挙動を壊す変更は不可
- UI/UX（レイアウト・色・フォント・間隔など）の変更は、事前合意がある場合のみ
- ライブラリ・SDK のバージョン変更は事前合意がある場合のみ

## 今後の改善タスク（Mac）
- 配布レイアウト（`dist/` 配下の macOS 版構成）を確定・自動化スクリプト化
- Flutter 側のパス解決（`kinten.app` 内部からの `backend/` 参照）を安定化
- CI（GitHub Actions 等）での macOS ビルドパイプライン整備

---
最終更新: 2025-08-10
