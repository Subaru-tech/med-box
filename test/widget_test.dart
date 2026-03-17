// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_notice_board/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartNoticeBoardApp());

    // Verify that the splash screen shows the App Name.
    expect(find.text('Digital Notice Board'), findsOneWidget);
    expect(find.text('Smart Information System'), findsOneWidget);

    // Verify presence of logo icon
    expect(find.byIcon(Icons.developer_board), findsOneWidget);

    // Wait for splash timer to avoid "Timer still pending" error
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
