import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/widgets/widgets.dart';

void main() {
  testWidgets('Coyote widget renders correctly', (WidgetTester tester) async {
    // Build the Coyote widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Coyote(),
        ),
      ),
    );

    // Verify that an Image widget is present
    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);

    // Verify the image asset path and height
    final Image imageWidget = tester.widget<Image>(imageFinder);
    expect((imageWidget.image as AssetImage).assetName, 'assets/coyote_falling.png');
    expect(imageWidget.height, 50);

    // Verify that the Image is wrapped in a RepaintBoundary
    final repaintBoundaryFinder = find.byWidgetPredicate(
      (Widget widget) => widget is RepaintBoundary && widget.child == imageWidget,
      description: 'RepaintBoundary that directly parents the specific Image widget',
    );
    expect(repaintBoundaryFinder, findsOneWidget);
  });
}
