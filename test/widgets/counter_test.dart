import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/widgets/widgets.dart';

// Minimal Styles mock/definition if not directly importable for test environment
// This is only needed if `Styles.fontStyle` itself causes issues in test.
class Styles {
  static const TextStyle fontStyle = TextStyle(fontFamily: 'GameFont', fontWeight: FontWeight.bold); // Example definition
}

void main() {
  group('Counter Widget Tests', () {
    testWidgets('is visible and displays counter when counter > 0', (WidgetTester tester) async {
      int tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Counter(counter: 5, fontColor: Colors.blue, onTap: () => tapCount++),
          ),
        ),
      );

      final counterTextFinder = find.text('5');
      expect(counterTextFinder, findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      final Text textWidget = tester.widget<Text>(counterTextFinder);
      expect(textWidget.style?.color, Colors.blue);
      expect(textWidget.style?.fontSize, 40.0);

      await tester.tap(find.byType(TextButton));
      expect(tapCount, 1);
    });

    testWidgets('is not visible (TextButton not found) when counter is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Counter(counter: 0, fontColor: Colors.red, onTap: () {}),
          ),
        ),
      );

      // The TextButton is wrapped in Visibility, so it shouldn't be found
      expect(find.byType(TextButton), findsNothing);
      // Also, the text itself should not be found as part of the button
      expect(find.text('0'), findsNothing);
    });

    testWidgets('is not visible (TextButton not found) when counter < 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Counter(counter: -1, fontColor: Colors.green, onTap: () {}),
          ),
        ),
      );

      expect(find.byType(TextButton), findsNothing);
      expect(find.text('-1'), findsNothing);
    });

    testWidgets('onTap callback is triggered', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Counter(
              counter: 1,
              fontColor: Colors.black,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      await tester.pump(); // Allow for state changes if any

      expect(tapped, isTrue);
    });
  });
}
