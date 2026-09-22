import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('App renders login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('PaperCraft'), findsOneWidget);
    expect(find.text('Log In'), findsWidgets);
  });
}
