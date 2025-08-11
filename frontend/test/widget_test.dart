import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kinten/main.dart';
import 'package:kinten/widgets/neumorphic_button.dart';

void main() {
  group('Kinten App Tests', () {
    testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
      // アプリをビルド
      await tester.pumpWidget(const ProviderScope(child: KintenApp()));

      // アプリが正常に起動することを確認（エラーが発生しない）
      expect(find.byType(MaterialApp), findsOneWidget);
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
  });
}
