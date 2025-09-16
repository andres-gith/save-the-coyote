import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gif_view/gif_view.dart';
import 'package:save_coyote/widgets/widgets.dart';

void main() {
  group('RoadRunner Widget Tests', () {
    testWidgets('renders correctly with GifView properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoadRunner(),
          ),
        ),
      );

      // Verify GifView.asset properties
      final gifViewFinder = find.byType(GifView);
      expect(gifViewFinder, findsOneWidget);

      final GifView gifViewWidget = tester.widget<GifView>(gifViewFinder);
      expect(gifViewWidget.height, 50);
      expect(gifViewWidget.fadeDuration, const Duration(milliseconds: 100));
    });
  });
}
