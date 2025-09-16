import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:save_coyote/provider/engine_bloc.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:save_coyote/l10n/app_localizations.dart';
import 'package:save_coyote/widgets/widgets.dart';

// Mocks
class MockEngineBloc extends MockBloc<EngineEvent, EngineState> implements EngineBloc {}

// Mock for AppLocalizations (needed for MaterialApp setup)
// This mock is still useful if the REAL InstructionsText (or other widgets in the tree) uses AppLocalizations.
class MockAppLocalizations implements AppLocalizations {
  @override
  String get instructionsTitle => 'Mock Title';

  @override
  String get instructionsDescription => 'Mock Description';
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final rawMemberName = invocation.memberName.toString();
    final methodName = rawMemberName.substring(8, rawMemberName.length - 2);
    throw UnimplementedError(
      '$methodName is not implemented in MockAppLocalizations for instructions_widget_test.'
    );
  }
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
  late MockAppLocalizations mockLocalizations; 

  setUpAll(() {
    registerFallbackValue(StartFallEvent());
  });

  setUp(() {
    mockEngineBloc = MockEngineBloc();
    mockLocalizations = MockAppLocalizations(); 
    when(() => mockEngineBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpInstructionsWidget(WidgetTester tester, {required EngineState initialState}) async {
    when(() => mockEngineBloc.state).thenReturn(initialState);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', ''), 
        localizationsDelegates: [
          _MockAppLocalizationsDelegate(mockLocalizations),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        home: Scaffold(
          body: InstructionsWidget(engineBloc: mockEngineBloc),
        ),
      ),
    );
  }

  group('InstructionsWidget Tests', () {
    testWidgets('renders REAL InstructionsText when EngineBloc state is Instructions', (WidgetTester tester) async {
      await pumpInstructionsWidget(tester, initialState: EngineInitial());
      await pumpInstructionsWidget(tester, initialState: Instructions());

      // Now find.byType(InstructionsText) refers to the REAL InstructionsText from lib/
      expect(find.byType(InstructionsText), findsOneWidget);
      expect(find.byType(SizedBox), findsNothing); 
    });

    testWidgets('renders SizedBox when EngineBloc state is not Instructions', (WidgetTester tester) async {
      await pumpInstructionsWidget(tester, initialState: EngineInitial());

      expect(find.byType(InstructionsText), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders SizedBox for another non-Instructions state', (WidgetTester tester) async {
      await pumpInstructionsWidget(tester, initialState: const CoyoteFalling(0.3));

      expect(find.byType(InstructionsText), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('REAL InstructionsText onTap callback adds StartFallEvent to EngineBloc', (WidgetTester tester) async {
      await pumpInstructionsWidget(tester, initialState: EngineInitial());
      await pumpInstructionsWidget(tester, initialState: Instructions());

      // Find the REAL InstructionsText widget
      final instructionsTextFinder = find.byType(InstructionsText);
      expect(instructionsTextFinder, findsOneWidget, 
          reason: "The real InstructionsText should be rendered by InstructionsWidget.");

      // The REAL InstructionsText uses a GestureDetector for taps.
      // Find the GestureDetector within the REAL InstructionsText.
      final gestureDetectorFinder = find.descendant(
        of: instructionsTextFinder,
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetectorFinder, findsOneWidget, 
          reason: "The real InstructionsText should contain a GestureDetector for tap handling.");

      await tester.tap(gestureDetectorFinder);
      await tester.pump();

      verify(() => mockEngineBloc.add(StartFallEvent())).called(1);
    });
  });
}
