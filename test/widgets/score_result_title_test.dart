import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/widgets/widgets.dart'; // Assuming ScoreResultTitle is part of widgets.dart

// Minimal Styles mock/definition
class Styles {
  static const TextStyle fontStyle = TextStyle(fontFamily: 'TestFont', fontWeight: FontWeight.normal);
  static Color colorBrown = Color(0xFFA24C1D); // Example color
}

void main() {
  group('ScoreResultTitle Widget Tests', () {
    const String testTitle = 'Test Score Title';

    Future<void> pumpWidget(WidgetTester tester, String title) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreResultTitle(title: title),
          ),
        ),
      );
    }

    testWidgets('renders Align with Alignment.center', (WidgetTester tester) async {
      await pumpWidget(tester, testTitle);

      final alignFinder = find.byType(Align);
      expect(alignFinder, findsOneWidget);

      final Align alignWidget = tester.widget<Align>(alignFinder);
      expect(alignWidget.alignment, Alignment.center);
    });

    testWidgets('renders AutoSizeText with correct title, style, and maxLines', (WidgetTester tester) async {
      await pumpWidget(tester, testTitle);

      final autoSizeTextFinder = find.byType(AutoSizeText);
      expect(autoSizeTextFinder, findsOneWidget);

      final AutoSizeText autoSizeTextWidget = tester.widget<AutoSizeText>(autoSizeTextFinder);
      expect(autoSizeTextWidget.data, testTitle);
      expect(autoSizeTextWidget.maxLines, 1);

      // Verify style properties
      expect(autoSizeTextWidget.style, isNotNull);
      expect(autoSizeTextWidget.style?.fontSize, 20.0); // Overridden
      expect(autoSizeTextWidget.style?.color, Styles.colorBrown); // Overridden
    });

    testWidgets('AutoSizeText is a child of Align', (WidgetTester tester) async {
      await pumpWidget(tester, testTitle);

      expect(find.descendant(of: find.byType(Align), matching: find.byType(AutoSizeText)), findsOneWidget);
    });
  });
}
