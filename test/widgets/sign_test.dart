import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/widgets/widgets.dart'; // Assuming Styles is available via widgets.dart or a direct import if needed

// If Styles.fontStyle is not directly available, you might need to mock or define it.
// For simplicity, this test assumes Styles.fontStyle provides a basic TextStyle.
// If 'package:save_coyote/styles/styles.dart' (or similar) is where Styles lives, import it.
// import 'package:save_coyote/styles/styles.dart'; 

void main() {
  // A helper function to pump the Sign widget with necessary ancestors
  Future<void> pumpSign(WidgetTester tester, {required String title, double? fontSize, Color? fontColor}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Sign(title: title, fontSize: fontSize ?? 32, fontColor: fontColor ?? Colors.red),
        ),
      ),
    );
  }

  group('Sign Widget Tests', () {
    testWidgets('renders correctly with custom title, fontSize, and fontColor', (WidgetTester tester) async {
      const String testTitle = 'Test Title';
      const double testFontSize = 24.0;
      const Color testFontColor = Colors.blue;

      await pumpSign(tester, title: testTitle, fontSize: testFontSize, fontColor: testFontColor);

      // Verify Image.asset
      expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/sign.png'), findsOneWidget);

      // Verify Text widget with title
      final textFinder = find.text(testTitle);
      expect(textFinder, findsOneWidget);

      // Verify style of the Text widget
      final Text textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, testFontSize);
      expect(textWidget.style?.color, testFontColor);
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('renders with default fontSize and fontColor when not provided', (WidgetTester tester) async {
      const String testTitle = 'Default Style Title';

      // Pump with only title, relying on default parameters in pumpSign or Sign widget itself
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Sign(title: testTitle), // Directly use Sign widget defaults
          ),
        ),
      );
      await tester.pumpAndSettle(); // Ensure any style resolution is complete

      // Verify Image.asset
      expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/sign.png'), findsOneWidget);

      // Verify Text widget with title
      final textFinder = find.text(testTitle);
      expect(textFinder, findsOneWidget);

      // Verify default style of the Text widget
      final Text textWidget = tester.widget<Text>(textFinder);
      // Accessing Styles.fontStyle might require it to be defined or mocked if not directly importable/accessible
      // For this test, we directly check the default values defined in the Sign widget constructor
      expect(textWidget.style?.fontSize, 32.0); // Default fontSize from Sign widget
      expect(textWidget.style?.color, Colors.red);   // Default fontColor from Sign widget
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('Stack and Positioned widgets are used for layout', (WidgetTester tester) async {
      const String layoutTestTitle = 'Layout Test';
      await pumpSign(tester, title: layoutTestTitle);

      // 1. Find the Sign widget itself
      final signFinder = find.byType(Sign);
      expect(signFinder, findsOneWidget, reason: "Should find the Sign widget");

      // 2. Find the Stack widget that is a descendant of the Sign widget
      final stackInSignFinder = find.descendant(
        of: signFinder,
        matching: find.byType(Stack),
      );
      expect(stackInSignFinder, findsOneWidget, reason: "Sign widget should contain one Stack widget");

      // 3. Verify the Text (inside a Positioned) is within that specific Stack
      final positionedTextFinder = find.widgetWithText(Positioned, layoutTestTitle);
      expect(positionedTextFinder, findsOneWidget, reason: "Should find a Positioned widget with title '$layoutTestTitle'");

      // Check if the found Positioned widget is a descendant of the Stack found within Sign
      expect(
        find.descendant(of: stackInSignFinder, matching: positionedTextFinder),
        findsOneWidget,
        reason: "The Positioned widget with text '$layoutTestTitle' should be a descendant of the Stack within the Sign widget."
      );
    });
  });
}

// Minimal Styles mock/definition if not directly importable for test environment
// This is only needed if `Styles.fontStyle` itself causes issues in test.
// If `Sign` widget directly uses `TextStyle().copyWith(...)` it may not be needed.
class Styles {
  static const TextStyle fontStyle = TextStyle(fontFamily: 'GameFont', fontWeight: FontWeight.bold); // Example definition
}
