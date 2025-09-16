import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/widgets/widgets.dart';

// Minimal Styles mock/definition as Counter widget uses Styles.fontStyle
class Styles {
  static const TextStyle fontStyle = TextStyle(fontFamily: 'GameFont', fontWeight: FontWeight.bold);
}

void main() {
  group('AnimatedCounter Widget Tests', () {
    late AnimationController controller;
    late Animation<double> animation;
    final TestVSync vsync = TestVSync();

    setUp(() {
      controller = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 100));
      animation = Tween<double>(begin: 0.5, end: 1.5).animate(controller);
    });

    tearDown(() {
      controller.dispose();
    });

    Future<void> pumpAnimatedCounter(WidgetTester tester, {
      required int counterVal,
      required Color color,
      required VoidCallback onTapCallback,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCounter(
              animation: animation,
              counter: counterVal,
              fontColor: color,
              onTap: onTapCallback,
            ),
          ),
        ),
      );
    }

    testWidgets('renders ScaleTransition with Counter child and passes props correctly', (WidgetTester tester) async {
      int tapCount = 0;
      const testCounter = 123;
      const testColor = Colors.purple;

      await pumpAnimatedCounter(
        tester,
        counterVal: testCounter,
        color: testColor,
        onTapCallback: () => tapCount++,
      );

      // Find the Counter widget first.
      final counterFinder = find.byType(Counter);
      expect(counterFinder, findsOneWidget, reason: "AnimatedCounter should render one Counter widget.");

      // Find the ScaleTransition that is an ancestor of this Counter and uses our specific animation.
      final scaleTransitionFinder = find.ancestor(
        of: counterFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is ScaleTransition && widget.scale == animation,
        ),
      );
      expect(scaleTransitionFinder, findsOneWidget, reason: "Expected to find one ScaleTransition wrapping Counter and using the provided animation.");

      // Verify properties passed to Counter widget
      final Counter counterWidget = tester.widget<Counter>(counterFinder);
      expect(counterWidget.counter, testCounter);
      expect(counterWidget.fontColor, testColor);

      // Verify onTap callback of Counter widget
      final textButtonFinder = find.descendant(of: counterFinder, matching: find.byType(TextButton));
      expect(textButtonFinder, findsOneWidget, reason: "Counter should display a TextButton if counter > 0");
      await tester.tap(textButtonFinder);
      expect(tapCount, 1);

      // Verify animation is passed to ScaleTransition
      final ScaleTransition scaleTransitionWidget = tester.widget<ScaleTransition>(scaleTransitionFinder);
      expect(scaleTransitionWidget.scale, animation);
    });

    testWidgets('ScaleTransition applies scale based on animation value', (WidgetTester tester) async {
      await pumpAnimatedCounter(tester, counterVal: 1, color: Colors.green, onTapCallback: () {});

      // Find the Counter widget first to locate its specific ScaleTransition.
      final counterFinder = find.byType(Counter);
      expect(counterFinder, findsOneWidget);
      
      final scaleTransitionFinder = find.ancestor(
        of: counterFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is ScaleTransition && widget.scale == animation,
        ),
      );
      expect(scaleTransitionFinder, findsOneWidget);
      
      ScaleTransition scaleTransitionWidget = tester.widget<ScaleTransition>(scaleTransitionFinder);

      controller.value = 0.0;
      await tester.pump();
      expect(scaleTransitionWidget.scale.value, animation.value);
      expect(animation.value, 0.5);

      controller.value = 0.5;
      await tester.pump();
      // Re-fetch the widget if its internal state might have changed due to pump
      scaleTransitionWidget = tester.widget<ScaleTransition>(scaleTransitionFinder);
      expect(scaleTransitionWidget.scale.value, animation.value);
      expect(animation.value, 1.0);

      controller.value = 1.0;
      await tester.pump();
      scaleTransitionWidget = tester.widget<ScaleTransition>(scaleTransitionFinder);
      expect(scaleTransitionWidget.scale.value, animation.value);
      expect(animation.value, 1.5);
    });

     testWidgets('Counter is not visible via AnimatedCounter if counter is 0', (WidgetTester tester) async {
      await pumpAnimatedCounter(
        tester,
        counterVal: 0,
        color: Colors.red,
        onTapCallback: () {},
      );
      await tester.pumpAndSettle();

      // AnimatedCounter always renders a ScaleTransition.
      // We find it by its animation instance to be specific.
      final scaleTransitionFinder = find.byWidgetPredicate(
        (widget) => widget is ScaleTransition && widget.scale == animation
      );
      expect(scaleTransitionFinder, findsOneWidget, reason: "ScaleTransition should always be present, driven by the specific animation.");

      // The Counter widget itself will make its content (TextButton) invisible.
      final counterWidgetFinder = find.byType(Counter);
      expect(counterWidgetFinder, findsOneWidget); // Counter widget is still in the tree.

      // But the TextButton inside Counter should not be found because Counter.visible is false
      expect(find.descendant(of: counterWidgetFinder, matching: find.byType(TextButton)), findsNothing);
      // And the text '0' from Counter should not be found as part of TextButton
      expect(find.text('0'), findsNothing);
    });

  });
}
