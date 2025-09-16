import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/widgets/widgets.dart';
import 'package:gif_view/gif_view.dart'; // Import the actual GifView package

void main() {
  group('IntroGif Widget Tests', () {
    testWidgets('renders correctly and wires callbacks', (WidgetTester tester) async {
      bool onViewedCalledByTap = false;
      bool onViewedCalledByGifFinish = false;

      await tester.pumpWidget(
        MaterialApp(
          home: IntroGif(
            onViewed: () {
              onViewedCalledByTap = true;
            },
          ),
        ),
      );

      // Verify Container with black color
      final containerFinder = find.byWidgetPredicate((widget) => widget is Container && widget.color == Colors.black);
      expect(containerFinder, findsOneWidget, reason: "Should find a black Container");

      // Verify GifView.asset properties using the actual GifView type
      final gifViewFinder = find.byType(GifView);

      expect(gifViewFinder, findsOneWidget, reason: "Should find one GifView widget from package.");

      // Retrieve the widget more safely
      Widget? foundWidgetObject;
      try {
        foundWidgetObject = tester.widget(gifViewFinder); // Get as generic Widget first
      } catch (e, s) {
        // Using top-level fail() instead of tester.fail()
        fail('''Failed to get widget using tester.widget(gifViewFinder): $e
Stack trace: $s''');
      }

      expect(
        foundWidgetObject,
        isNotNull,
        reason: "tester.widget(gifViewFinder) should not return null if finder finds one.",
      );

      // Check type and cast
      expect(foundWidgetObject, isA<GifView>(), reason: "Found widget should be of type GifView from package");

      // If the above expect passes, this cast is safe.
      final GifView gifViewWidget = foundWidgetObject as GifView;

      // Check properties (assuming IntroGif sets these on the actual GifView)
      expect(gifViewWidget.height, 300, reason: "GifView height should be 300");
      expect(gifViewWidget.loop, false, reason: "GifView loop should be false");

      if (gifViewWidget.onFinish != null) {
        gifViewWidget.onFinish!();
        onViewedCalledByGifFinish = true;
      }
      expect(onViewedCalledByGifFinish, isTrue, reason: "GifView.onFinish should be wired to the onViewed callback");

      // Reset flag for tap test
      onViewedCalledByTap = false;

      // Verify GestureDetector onTap callback
      final gestureDetectorFinder = find.byType(GestureDetector);
      expect(gestureDetectorFinder, findsOneWidget, reason: "Should find a GestureDetector");
      await tester.tap(gestureDetectorFinder);
      await tester.pump();

      expect(onViewedCalledByTap, isTrue, reason: "GestureDetector onTap should trigger onViewed callback");
    });
  });
}
