// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:elderlink/main.dart';

void main() {
  testWidgets('Splash screen shows app name and tagline', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ElderLinkApp());

    // Verify that the splash screen shows the App Name and tagline.
    expect(find.text('ElderLink'), findsOneWidget);
    expect(find.text('Connected Elderly Assistance'), findsOneWidget);

    // Wait for splash timer to avoid "Timer still pending" error
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
