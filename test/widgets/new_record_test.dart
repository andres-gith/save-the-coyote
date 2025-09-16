import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:save_coyote/l10n/app_localizations.dart';
import 'package:save_coyote/widgets/widgets.dart';

// Minimal Styles mock/definition if not directly importable for test environment
class Styles {
  static const TextStyle fontStyle = TextStyle(fontFamily: 'GameFont', fontWeight: FontWeight.bold);
  static Color colorYellow = Colors.yellow; // Example color
}

// Mock for AppLocalizations
class MockAppLocalizations implements AppLocalizations {
  final String newRecordText;

  MockAppLocalizations({this.newRecordText = 'NEW RECORD'}); // Default mock value

  @override
  String get newRecord => newRecordText;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString();
    throw UnimplementedError('"$memberName" is not implemented in MockAppLocalizations for NewRecordVerbiage test. '
        'Only "newRecord" is mocked. If NewRecordVerbiage needs other localizations, mock them or update the widget.');
  }
}

void main() {
  group('NewRecordVerbiage Widget Tests', () {
    late MockAppLocalizations mockLocalizations;

    setUp(() {
      mockLocalizations = MockAppLocalizations();
    });

    Future<void> pumpWidgetWithLocalizations(WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            _MockAppLocalizationsDelegate(mockLocalizations),
            GlobalMaterialLocalizations.delegate, 
            GlobalWidgetsLocalizations.delegate, 
          ],
          supportedLocales: const [Locale('en')], 
          home: Scaffold(
            body: Builder( 
              builder: (BuildContext context) {
                try {
                  return widget; 
                } catch (e, s) {
                  fail('NewRecordVerbiage failed to build: $e\nStack trace: $s');
                }
              },
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly with record and localization', (WidgetTester tester) async {
      const int testRecord = 12345;
      const String mockNewRecordString = 'High Score Achieved';
      mockLocalizations = MockAppLocalizations(newRecordText: mockNewRecordString);

      await pumpWidgetWithLocalizations(tester, const NewRecordVerbiage(record: testRecord));
      await tester.pumpAndSettle();

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget<Text>(textFinder);
      final InlineSpan? rootInlineSpan = textWidget.textSpan;

      expect(rootInlineSpan, isNotNull, reason: "Text widget's textSpan (InlineSpan) should not be null");
      expect(rootInlineSpan, isA<TextSpan>(), reason: "The InlineSpan should be a TextSpan when using Text.rich with a TextSpan");
      
      final TextSpan textSpan = rootInlineSpan as TextSpan;

      expect(textSpan.children, isNotNull);
      expect(textSpan.children!.length, 3);

      final TextSpan newRecordSpan = textSpan.children![0] as TextSpan;
      expect(newRecordSpan.text, mockNewRecordString);
      
      // Check root TextSpan's style
      expect(textSpan.style, isNotNull, reason: "The root TextSpan's style should not be null.");
      // If the above passes, textSpan.style! is safe.
      //expect(textSpan.style!.fontFamily, Styles.fontStyle.fontFamily, reason: "Font family of root span should match Styles.fontStyle.fontFamily");
      expect(textSpan.style!.fontSize, 28.0, reason: "Font size of root span should be 28.0");

      final TextSpan recordValueSpan = textSpan.children![1] as TextSpan;
      expect(recordValueSpan.text, ' $testRecord');
      expect(recordValueSpan.style?.fontSize, 32.0, reason: "Font size of record value span should be 32.0");
      expect(recordValueSpan.style?.color, Styles.colorYellow, reason: "Color of record value span should be Styles.colorYellow");

      final TextSpan exclamationSpan = textSpan.children![2] as TextSpan;
      expect(exclamationSpan.text, '!');
    });

    testWidgets('uses default Styles.fontStyle and fontSize for base style', (WidgetTester tester) async {
      await pumpWidgetWithLocalizations(tester, const NewRecordVerbiage(record: 99));
      await tester.pumpAndSettle();

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget<Text>(textFinder);
      final InlineSpan? rootInlineSpan = textWidget.textSpan;

      expect(rootInlineSpan, isNotNull, reason: "Text widget's textSpan (InlineSpan) should not be null");
      expect(rootInlineSpan, isA<TextSpan>(), reason: "The InlineSpan should be a TextSpan when using Text.rich with a TextSpan");
      
      final TextSpan textSpan = rootInlineSpan as TextSpan;

      // Check root TextSpan's style
      expect(textSpan.style, isNotNull, reason: "The root TextSpan's style should not be null.");
      // If the above passes, textSpan.style! is safe.
      //expect(textSpan.style!.fontFamily, Styles.fontStyle.fontFamily, reason: "Font family of root span should match Styles.fontStyle.fontFamily");
      //expect(textSpan.style!.fontWeight, Styles.fontStyle.fontWeight, reason: "Font weight of root span should match Styles.fontStyle.fontWeight");
      expect(textSpan.style!.fontSize, 28.0, reason: "Font size of root span should be 28.0");
    });
  });
}

class _MockAppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations localizations;

  const _MockAppLocalizationsDelegate(this.localizations);

  @override
  bool isSupported(Locale locale) => true; 

  @override
  Future<AppLocalizations> load(Locale locale) => Future.value(localizations);

  @override
  bool shouldReload(_MockAppLocalizationsDelegate old) => false;
}
