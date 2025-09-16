import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/widgets/widgets.dart';

void main() {
  group('BackgroundImage Widget Tests', () {
    const Key testChildKey = Key('test_child');
    const Widget testChild = SizedBox(key: testChildKey, width: 50, height: 50);

    testWidgets('renders RepaintBoundary, Container, and child correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BackgroundImage(child: testChild),
        ),
      );

      // 1. Ensure the child is present first, as it anchors our search.
      final childFinder = find.byKey(testChildKey);
      expect(childFinder, findsOneWidget);

      // 2. Find the Container that is an ancestor of our specific child.
      final containerFinder = find.ancestor(
        of: childFinder,
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget, reason: "Expected to find a Container parenting the testChild");

      // Get the actual instance of the Container widget we found.
      final Container specificContainerWidget = tester.widget<Container>(containerFinder);

      // 3. Find the RepaintBoundary whose child is our specificContainerWidget.
      final repaintBoundaryFinder = find.byWidgetPredicate(
        (Widget widget) => widget is RepaintBoundary && widget.child == specificContainerWidget,
        description: 'RepaintBoundary that directly parents the specific Container',
      );
      expect(repaintBoundaryFinder, findsOneWidget, reason: "Expected to find a RepaintBoundary directly parenting the identified Container");
    });

    testWidgets('Container has correct DecorationImage properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BackgroundImage(child: testChild),
        ),
      );

      // Find the specific Container that parents our testChildKey.
      final containerFinder = find.ancestor(
        of: find.byKey(testChildKey),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget, reason: "Could not find the specific Container for the BackgroundImage");

      final Container containerWidget = tester.widget<Container>(containerFinder);
      expect(containerWidget.decoration, isA<BoxDecoration>());

      final boxDecoration = containerWidget.decoration as BoxDecoration;
      expect(boxDecoration.image, isA<DecorationImage>());

      final decorationImage = boxDecoration.image as DecorationImage;
      expect(decorationImage.image, isA<AssetImage>());
      expect((decorationImage.image as AssetImage).assetName, 'assets/background2.png');
      expect(decorationImage.fit, BoxFit.cover);
      expect(decorationImage.alignment, Alignment.topCenter);
    });
  });
}
