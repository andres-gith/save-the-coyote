import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/widgets/widgets.dart';
import 'dart:math' as math;

// Minimal Styles mock/definition if not directly importable for test environment
// Used by the Sign widget
class Styles {
  static const TextStyle fontStyle = TextStyle(fontFamily: 'GameFont', fontWeight: FontWeight.bold);
  static Color colorYellow = Colors.yellow; // Example, if Sign uses it by default or through params
}

void main() {
  group('AnimatedSign Widget Tests', () {
    late AnimationController controller;
    late Animation<double> animation;

    // Use a TestVSync for the AnimationController
    final TestVSync vsync = TestVSync();

    setUp(() {
      controller = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 100));
      animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    });

    tearDown(() {
      controller.dispose();
    });

    Future<void> pumpAnimatedSign(WidgetTester tester, {
      required String title,
      required double fontSize,
      required Color fontColor,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSign(
              animation: animation,
              title: title,
              fontSize: fontSize,
              fontColor: fontColor,
            ),
          ),
        ),
      );
    }

    testWidgets('renders Sign widget with correct parameters', (WidgetTester tester) async {
      const String testTitle = "Falling!";
      const double testFontSize = 22.0;
      const Color testFontColor = Colors.orange;

      await pumpAnimatedSign(tester, title: testTitle, fontSize: testFontSize, fontColor: testFontColor);

      // Verify that Sign widget is present
      final signFinder = find.byType(Sign);
      expect(signFinder, findsOneWidget);

      // Verify parameters passed to Sign widget
      final Sign signWidget = tester.widget<Sign>(signFinder);
      expect(signWidget.title, testTitle);
      expect(signWidget.fontSize, testFontSize);
      expect(signWidget.fontColor, testFontColor);
    });

    testWidgets('AnimatedBuilder and Transform are used and transform changes with animation', (WidgetTester tester) async {
      await pumpAnimatedSign(tester, title: "AnimTest", fontSize: 20, fontColor: Colors.green);

      // Verify the specific AnimatedBuilder controlled by _animation is present
      final animatedBuilderFinder = find.byWidgetPredicate(
        (widget) => widget is AnimatedBuilder && widget.animation == animation,
        description: "AnimatedBuilder driven by the specific test animation"
      );
      expect(animatedBuilderFinder, findsOneWidget);

      // Find the Sign widget first
      final signFinder = find.byType(Sign);
      expect(signFinder, findsOneWidget, reason: "A single Sign widget should be present.");

      // Find the specific Transform widget that is an ancestor of the Sign widget
      // and has the alignment property set by AnimatedSign.
      final transformFinder = find.ancestor(
        of: signFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is Transform && widget.alignment == Alignment.bottomCenter,
          description: "Transform with alignment: Alignment.bottomCenter, parenting a Sign widget"
        )
      );
      expect(transformFinder, findsOneWidget, 
          reason: "Expected to find one specific Transform widget parenting the Sign widget.");

      // Check initial transform (animation value = 0.0)
      Transform transformWidget = tester.widget<Transform>(transformFinder);
      Matrix4 initialTransform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(0.0 * math.pi);
      expect(transformWidget.transform, equals(initialTransform));
      expect(transformWidget.alignment, Alignment.bottomCenter); // Already checked by finder, but good for clarity

      // Advance the animation
      controller.value = 0.5; // Corresponds to 90 degrees rotation (pi / 2)
      await tester.pump(); // Rebuild with new animation value

      transformWidget = tester.widget<Transform>(transformFinder);
      Matrix4 halfWayTransform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(0.5 * math.pi);
      expect(transformWidget.transform, equals(halfWayTransform));

       // Advance the animation to end
      controller.value = 1.0; // Corresponds to 180 degrees rotation (pi)
      await tester.pump(); 

      transformWidget = tester.widget<Transform>(transformFinder);
      Matrix4 endTransform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(1.0 * math.pi);
      expect(transformWidget.transform, equals(endTransform));
    });
  });
}
