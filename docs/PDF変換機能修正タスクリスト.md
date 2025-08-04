# PDF変換機能修正タスクリスト

## 問題の分析結果

### 1. PDF変換の上部の表記について
- 左上に不要なフォルダアイコンと戻るアイコンが隠れている
- シンプルで統一感のあるデザインが必要

### 2. 入力フォルダが選択しても表示されない
- フォルダ選択後にUIが更新されていない可能性
- 状態管理の問題

### 3. 出力フォルダの記載は不要
- UIから削除する必要がある

### 4. Excelファイル一覧が表示されない
- `getExcelFiles()`メソッドが正しく動作していない可能性
- バックエンドとの連携に問題がある可能性

## 修正タスク

### タスク1: PDF変換ヘッダーのデザイン修正 ✅
- [x] `pdf_conversion_widget.dart`の`_buildEnhancedHeader`メソッドを修正
- [x] 不要なアイコンを削除し、シンプルなデザインに変更
- [x] 統一感のあるヘッダーデザインに変更

### タスク2: 入力フォルダ表示の問題修正 ✅
- [x] フォルダ選択後の状態更新を確認
- [x] UIの即座反映を実装
- [x] フォルダパスの表示ロジックを修正

### タスク3: 出力フォルダセクションの削除 ✅
- [x] `_buildOutputFolderSection`メソッドの呼び出しを削除
- [x] 関連するUI要素を完全に削除
- [x] レイアウトの調整

### タスク4: Excelファイル一覧表示の問題修正 ✅
- [x] `getExcelFiles()`メソッドの動作確認
- [x] バックエンドとの連携テスト
- [x] ファイル一覧表示ロジックの修正
- [x] エラーハンドリングの改善
- [x] デバッグログを追加して問題の特定を容易に

### タスク5: 統合テスト ✅
- [x] 全機能の動作確認
- [x] UIの一貫性チェック
- [x] レンダリングエラーの修正
- [x] エラーケースのテスト

## 修正手順

1. まずヘッダーデザインを修正
2. 入力フォルダ表示の問題を修正
3. 出力フォルダセクションを削除
4. Excelファイル一覧表示を修正
5. 全体のテストを実行

## 修正内容の詳細

### タスク1: PDF変換ヘッダーのデザイン修正
- **修正ファイル**: `frontend/lib/widgets/pdf_conversion_widget.dart`
- **修正内容**: 
  - `_buildEnhancedHeader`メソッドから不要なアイコンコンテナを削除
  - RowレイアウトからColumnレイアウトに変更
  - シンプルで統一感のあるデザインに変更
  - フォントサイズを調整（22-26px）

### タスク2: 入力フォルダ表示の問題修正
- **修正ファイル**: `frontend/lib/widgets/pdf_conversion_widget.dart`
- **修正内容**:
  - `_loadSettings`メソッドで空文字列チェックを追加
  - フォルダ選択後に`Future.delayed`を使用してExcelファイル取得を遅延実行
  - UIの即座反映を改善

### タスク3: 出力フォルダセクションの削除
- **修正ファイル**: `frontend/lib/widgets/pdf_conversion_widget.dart`
- **修正内容**:
  - `_buildOutputFolderSection`メソッドの呼び出しを削除
  - `_buildOutputFolderSection`メソッド自体を完全に削除
  - レイアウトの調整

### タスク4: Excelファイル一覧表示の問題修正
- **修正ファイル**: `frontend/lib/providers/app_state_provider.dart`
- **修正内容**:
  - `getExcelFiles`メソッドにデバッグログを追加
  - `_callGetExcelFilesBackend`メソッドに詳細なデバッグログを追加
  - Pythonプロセスの実行結果を詳細にログ出力
  - エラーハンドリングの改善

### タスク5: レンダリングエラーの修正
- **修正ファイル**: 
  - `frontend/lib/widgets/pdf_conversion_widget.dart`
  - `frontend/lib/screens/home_screen.dart`
- **修正内容**:
  - `ListView.builder`の`shrinkWrap: true`を削除し、固定高さを設定
  - `SingleChildScrollView`を削除してレイアウト競合を回避
  - タブビューに`SingleChildScrollView`を追加
  - コンテナに明示的な高さを設定
  - レイアウトの安定性を向上

### タスク6: エラーケースのテストと改善
- **修正ファイル**: 
  - `frontend/lib/providers/app_state_provider.dart`
  - `frontend/lib/widgets/pdf_conversion_widget.dart`
- **修正内容**:
  - フォルダ存在チェックの追加
  - Pythonバックエンドのエラーハンドリング改善
  - 特定エラーパターンの検出と適切なメッセージ表示
  - フォルダ選択のキャンセル処理改善
  - エラーメッセージの詳細表示機能追加
  - ステータス表示の改善（成功ケース追加）

## 注意事項

- 各タスクは順番に実行する
- 修正後は必ずテストを実行する
- エラーが発生した場合はログを確認する
- UIの一貫性を保つ
- デバッグログを活用して問題の特定を行う 