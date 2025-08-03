import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kinten/main.dart';
import 'package:kinten/screens/home_screen.dart';
import 'package:kinten/widgets/neumorphic_button.dart';

void main() {
  group('Kinten App Tests', () {
    testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
      // アプリをビルド
      await tester.pumpWidget(const ProviderScope(child: KintenApp()));

      // アプリタイトルが表示されることを確認
      expect(find.text('Kinten（勤転）'), findsOneWidget);
      expect(find.text('freee勤怠CSV → Excel自動転記'), findsOneWidget);
    });

    testWidgets('ファイル選択セクションが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: KintenApp()));

      // ファイル選択関連の要素が表示されることを確認
      expect(find.text('ファイル選択'), findsOneWidget);
      expect(find.text('勤怠CSVファイル'), findsOneWidget);
      expect(find.text('Excelテンプレート'), findsOneWidget);
      expect(find.text('出力先フォルダ'), findsOneWidget);
    });

    testWidgets('NeumorphicButtonが正常に動作する', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeumorphicButton(
              onPressed: () => buttonPressed = true,
              child: const Text('テストボタン'),
            ),
          ),
        ),
      );

      // ボタンが表示されることを確認
      expect(find.text('テストボタン'), findsOneWidget);

      // ボタンをタップ
      await tester.tap(find.text('テストボタン'));
      await tester.pump();

      // ボタンが押されたことを確認
      expect(buttonPressed, true);
    });

    testWidgets('無効なボタンは押せない', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeumorphicButton(
              onPressed: null, // 無効
              child: const Text('無効ボタン'),
            ),
          ),
        ),
      );

      // ボタンが表示されることを確認
      expect(find.text('無効ボタン'), findsOneWidget);

      // ボタンをタップしても何も起こらないことを確認
      await tester.tap(find.text('無効ボタン'));
      await tester.pump();
      
      // エラーが発生しないことを確認
      expect(find.text('無効ボタン'), findsOneWidget);
    });

    testWidgets('HomeScreenのUI要素が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: HomeScreen())));

      // 主要なUI要素が表示されることを確認
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.text('変換して保存'), findsOneWidget);
    });
  });
}
