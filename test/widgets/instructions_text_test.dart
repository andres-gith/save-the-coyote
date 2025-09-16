import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/l10n/app_localizations.dart';
import 'package:save_coyote/widgets/widgets.dart';

// Helper function to pump the widget with necessary ancestors
Future<void> pumpInstructionsText(
  WidgetTester tester, {
  required VoidCallback onTap,
  Locale locale = const Locale('en'), // Default to 'en', or any supported locale
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: InstructionsText(onTap: onTap),
      ),
    ),
  );
  // Pump once for the widget to be built and another time for the localizations to be resolved.
  await tester.pump();
}

void main() {
  group('InstructionsText Widget Tests', () {
    late bool tapCalled;

    setUp(() {
      tapCalled = false;
    });

    testWidgets('calls onTap callback when tapped', (WidgetTester tester) async {
      await pumpInstructionsText(tester, onTap: () => tapCalled = true);
      
      expect(tapCalled, isFalse, reason: "onTap callback was called prematurely.");
      
      await tester.tap(find.byType(InstructionsText));
      await tester.pump(); // Process the tap
      
      expect(tapCalled, isTrue, reason: "onTap callback was not called after tap.");
    });

    testWidgets('renders with correct container properties', (WidgetTester tester) async {
      await pumpInstructionsText(tester, onTap: () => tapCalled = true);
      
      final containerFinder = find.descendant(
        of: find.byType(InstructionsText),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget);
      
      final Container containerWidget = tester.widget<Container>(containerFinder);
      expect(containerWidget.color, Colors.black54);
      expect(containerWidget.alignment, Alignment.center);
      expect(containerWidget.padding, const EdgeInsets.all(16.0));
    });
  });
}
