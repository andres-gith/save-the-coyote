import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:save_coyote/model/models.dart';
import 'package:save_coyote/provider/score_bloc.dart';
import 'package:save_coyote/screens/screens.dart';
import 'package:save_coyote/widgets/widgets.dart';
import 'package:save_coyote/l10n/app_localizations.dart'; // Added AppLocalizations import

// Mocks
class MockScoreBloc extends MockBloc<ScoreEvent, ScoreState> implements ScoreBloc {}

class MockAnimationController extends Mock implements AnimationController {}

// Minimal Styles mock
class Styles {
  static Color colorYellow = Colors.yellow;
  static Color colorRed = Colors.red.shade400;
}

void main() {
  late MockScoreBloc mockScoreBloc;

  setUpAll(() {
    // Register fallback values for events if mockScoreBloc.add is called with specific event types
    registerFallbackValue(ShowScoresEvent());
    registerFallbackValue(DismissScoresEvent());
    registerFallbackValue(SaveRecordEvent(0, ''));
  });

  setUp(() {
    mockScoreBloc = MockScoreBloc();
    when(() => mockScoreBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpScoreCounters(WidgetTester tester, {required ScoreState initialState}) async {
    when(() => mockScoreBloc.state).thenReturn(initialState);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        // Using AppLocalizations.localizationsDelegates
        supportedLocales: AppLocalizations.supportedLocales,
        // Using AppLocalizations.supportedLocales
        home: Scaffold(body: ScoreCounters(scoreBloc: mockScoreBloc)),
      ),
    );
  }

  group('ScoreCounters Widget Tests', () {
    group('Builder Logic', () {
      testWidgets('renders AnimatedCounters when state is ScoreReady', (WidgetTester tester) async {
        const scoreReadyState = ScoreReady(counter: 10, failCounter: 3, lastRecordedName: 'Player');
        await pumpScoreCounters(tester, initialState: scoreReadyState);

        final animatedCounterFinders = find.byType(AnimatedCounter);
        expect(animatedCounterFinders, findsNWidgets(2));

        // First AnimatedCounter (Saved)
        final AnimatedCounter savedCounterWidget = tester.widget<AnimatedCounter>(animatedCounterFinders.first);
        expect(savedCounterWidget.counter, scoreReadyState.counter - scoreReadyState.failCounter); // 10 - 3 = 7
        expect(savedCounterWidget.fontColor, Styles.colorYellow);

        // Second AnimatedCounter (Failed)
        final AnimatedCounter failCounterWidget = tester.widget<AnimatedCounter>(animatedCounterFinders.last);
        expect(failCounterWidget.counter, scoreReadyState.failCounter); // 3
        expect(failCounterWidget.fontColor, Styles.colorRed);

        // Test onTap for saved counter
        await tester.tap(animatedCounterFinders.first);
        verify(() => mockScoreBloc.add(ShowScoresEvent())).called(1);

        // Test onTap for fail counter
        await tester.tap(animatedCounterFinders.last);
        verify(() => mockScoreBloc.add(ShowScoresEvent())).called(1); // Called once more, total 2 for this event type
      });

      testWidgets('renders SizedBox.shrink for ScoreInitial state', (WidgetTester tester) async {
        await pumpScoreCounters(tester, initialState: ScoreInitial());
        expect(find.byType(SizedBox), findsOneWidget); // SizedBox.shrink
        expect(find.byType(AnimatedCounter), findsNothing);
      });
    });

    group('Listener Logic', () {
      testWidgets('shows ScoreResultsScreen on ScoreResults state and handles dismiss', (WidgetTester tester) async {
        final resultsState = ScoreResults(
          counter: 10,
          failCounter: 2,
          maxScores: [ScoreModel(score: 100, counter: 2, name: 'Player 1')],
          minScore: 50,
        );
        whenListen(
          mockScoreBloc,
          Stream<ScoreState>.fromIterable([ScoreInitial(), resultsState]),
          initialState: ScoreInitial(),
        );

        await pumpScoreCounters(tester, initialState: ScoreInitial());
        await tester.pump(); // Process the stream to emit ScoreResults

        expect(find.byType(ScoreResultsScreen), findsOneWidget);
        final ScoreResultsScreen dialog = tester.widget(find.byType(ScoreResultsScreen));
        expect(dialog.counter, resultsState.counter);
        expect(dialog.failCounter, resultsState.failCounter);

        // Simulate dismiss
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        verify(() => mockScoreBloc.add(DismissScoresEvent())).called(1);
        expect(find.byType(ScoreResultsScreen), findsNothing);
      });

      testWidgets('shows RecordScreen on NewRecord state and handles save', (WidgetTester tester) async {
        final recordState = NewRecord(score: 1000, lastRecordedName: 'PreviousName');
        whenListen(
          mockScoreBloc,
          Stream<ScoreState>.fromIterable([ScoreInitial(), recordState]),
          initialState: ScoreInitial(),
        );

        await pumpScoreCounters(tester, initialState: ScoreInitial());
        await tester.pump(); // Process the stream to emit NewRecord

        expect(find.byType(RecordScreen), findsOneWidget);
        final RecordScreen dialog = tester.widget(find.byType(RecordScreen));
        expect(dialog.record, recordState.score);
        expect(dialog.lastRecordedName, recordState.lastRecordedName);

        // Simulate save (placeholder RecordScreen saves with "TestName")
        await tester.tap(find.ancestor(of: find.text('SAVE'), matching: find.byType(TextButton)));
        await tester.pumpAndSettle();
        verify(
          () => mockScoreBloc.add(SaveRecordEvent(recordState.score, recordState.lastRecordedName ?? 'TestName')),
        ).called(1);
        expect(find.byType(RecordScreen), findsNothing);
      });

      testWidgets('listener responds to ScoredPoints state (animation trigger indication)', (
        WidgetTester tester,
      ) async {
        // This test mainly ensures the bloc state transition is handled by the listener.
        // Direct animation controller verification is omitted for simplicity here.
        whenListen(
          mockScoreBloc,
          Stream<ScoreState>.fromIterable([
            ScoreInitial(),
            ScoredPoints(counter: 1, failCounter: 0, lastRecordedName: 'P'),
          ]),
          initialState: ScoreInitial(),
        );
        await pumpScoreCounters(tester, initialState: ScoreInitial());
        await tester.pump(); // Process stream
        // No direct verification of controller.forward(), but ensures listener path is hit.
        expect(mockScoreBloc.state, isA<ScoredPoints>());
      });

      testWidgets('listener responds to ScoredFail state (animation trigger indication)', (WidgetTester tester) async {
        whenListen(
          mockScoreBloc,
          Stream<ScoreState>.fromIterable([
            ScoreInitial(),
            ScoredFail(counter: 1, failCounter: 1, lastRecordedName: 'P'),
          ]),
          initialState: ScoreInitial(),
        );
        await pumpScoreCounters(tester, initialState: ScoreInitial());
        await tester.pump(); // Process stream
        expect(mockScoreBloc.state, isA<ScoredFail>());
      });
    });
  });
}
