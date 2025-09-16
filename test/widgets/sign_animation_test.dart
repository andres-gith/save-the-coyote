import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:save_coyote/l10n/app_localizations.dart';
import 'package:save_coyote/provider/engine_bloc.dart';
import 'package:save_coyote/widgets/widgets.dart';

// Mocks
class MockEngineBloc extends MockBloc<EngineEvent, EngineState> implements EngineBloc {}

// Minimal Styles mock
class Styles {
  static Color colorBrown = const Color(0xFFA24C1D); // Restored original
  static Color colorRed = Colors.red.shade400;      // Restored original
}
// Mock for AppLocalizations
class MockAppLocalizations implements AppLocalizations {
  final String youFailedText;
  MockAppLocalizations({this.youFailedText = 'YOU FAILED'});

  @override
  String get youFailed => youFailedText;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Custom delegate for providing mock localizations
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

void main() {
  late MockEngineBloc mockEngineBloc;
  late MockAppLocalizations mockAppLocalizations;
  const double testBottomPosition = 50.0;

  setUpAll(() {
    registerFallbackValue(OnLoadEvent());
  });

  setUp(() {
    mockEngineBloc = MockEngineBloc();
    mockAppLocalizations = MockAppLocalizations();
    when(() => mockEngineBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpSignAnimation(WidgetTester tester, {required EngineState initialState}) async {
    when(() => mockEngineBloc.state).thenReturn(initialState);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [_MockAppLocalizationsDelegate(mockAppLocalizations)],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: Stack(
            children: [
              SignAnimation(engineBloc: mockEngineBloc, bottom: testBottomPosition),
            ],
          ),
        ),
      ),
    );
  }

  group('SignAnimation Widget Tests', () {
    testWidgets('renders AnimatedSign with score when state is CoyoteSaved', (WidgetTester tester) async {
      const score = 987;
      await pumpSignAnimation(tester, initialState: const CoyoteSaved(0.1, score));
      await tester.pumpAndSettle();

      final animatedSignFinder = find.byType(AnimatedSign);
      expect(animatedSignFinder, findsOneWidget);
      final AnimatedSign animatedSign = tester.widget(animatedSignFinder);
      expect(animatedSign.title, '$score!');
      expect(animatedSign.fontSize, 52.0);
      expect(animatedSign.fontColor, Styles.colorBrown);

      final positionedFinder = find.ancestor(
        of: animatedSignFinder,
        matching: find.byType(Positioned),
      );
      expect(positionedFinder, findsOneWidget, reason: "Expected to find a Positioned widget parenting the AnimatedSign");
      final Positioned positionedWidget = tester.widget<Positioned>(positionedFinder);
      expect(positionedWidget.bottom, testBottomPosition);
    });

    testWidgets('renders AnimatedSign with fail message when state is CoyoteNotSaved', (WidgetTester tester) async {
      const String mockFailMsg = 'Try Again!';
      mockAppLocalizations = MockAppLocalizations(youFailedText: mockFailMsg);
      await pumpSignAnimation(tester, initialState: const CoyoteNotSaved());
      await tester.pumpAndSettle();

      final animatedSignFinder = find.byType(AnimatedSign);
      expect(animatedSignFinder, findsOneWidget);
      final AnimatedSign animatedSign = tester.widget(animatedSignFinder);
      expect(animatedSign.title, mockFailMsg);
      expect(animatedSign.fontSize, 30.0);
      expect(animatedSign.fontColor, Styles.colorRed);

      final positionedFinder = find.ancestor(
        of: animatedSignFinder,
        matching: find.byType(Positioned),
      );
      expect(positionedFinder, findsOneWidget);
      final Positioned positionedWidget = tester.widget<Positioned>(positionedFinder);
      expect(positionedWidget.bottom, testBottomPosition);
    });

    testWidgets('AnimatedSign is not visible when state is CoyoteFalling', (WidgetTester tester) async {
      await pumpSignAnimation(tester, initialState: const CoyoteFalling(0.5));
      await tester.pumpAndSettle();

      final visibilityFinder = find.byType(Visibility);
      expect(visibilityFinder, findsOneWidget);
      final Visibility visibilityWidget = tester.widget<Visibility>(visibilityFinder);
      expect(visibilityWidget.visible, isFalse);
      expect(find.byType(AnimatedSign), findsNothing);
    });
  });
}
