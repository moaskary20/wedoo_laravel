// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handyman_app/screens/tips_screen.dart';

void main() {
  testWidgets('Tips screen loads', (WidgetTester tester) async {
    // Test the tips screen directly
    await tester.pumpWidget(const MaterialApp(
      home: TipsScreen(
        categoryName: 'خدمات صيانة المنازل',
        categoryIcon: 'home_repair',
        categoryColor: Colors.blue,
        categoryId: 1,
      ),
    ));
    
    // Verify that the tips screen loads with Arabic text
    expect(find.text('اعرف سر الصنعة - خدمات صيانة المنازل'), findsOneWidget);
  });
}
