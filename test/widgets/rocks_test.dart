import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/widgets/widgets.dart';

void main() {
  testWidgets('Rocks widget renders correctly', (WidgetTester tester) async {
    // Build the Rocks widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Rocks(),
        ),
      ),
    );

    // Verify that an Image widget is present
    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);

    // Verify the image asset path and height
    final Image imageWidget = tester.widget<Image>(imageFinder);
    expect((imageWidget.image as AssetImage).assetName, 'assets/rocks.png');
    expect(imageWidget.height, 300);
  });
}
