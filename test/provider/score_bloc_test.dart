import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:save_coyote/provider/score_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ScoreBloc', () {
    late ScoreBloc scoreBloc;

    // Default values for SharedPreferences
    final Map<String, Object> defaultMockValues = {
      ScoreBloc.counterKey: 0,
      ScoreBloc.failCounterKey: 0,
      ScoreBloc.maxScoresListKey: <String>[],
      ScoreBloc.minScoreKey: 0, // Nullable int
      ScoreBloc.lastRecordedNameKey: '',
      ScoreBloc.scoreRecordKey: 0,
    };

    setUp(() {
      // It's crucial to reset mock values for each test to ensure test independence.
      SharedPreferences.setMockInitialValues(Map<String, Object>.from(defaultMockValues));
      scoreBloc = ScoreBloc();
      // scoreBloc.initialize() will be called in tests that require it,
      // as it's an async method and blocTest handles act phase.
    });

    tearDown(() {
      scoreBloc.close();
    });

    test('initial state is ScoreInitial', () {
      expect(scoreBloc.state, ScoreInitial());
    });

    blocTest<ScoreBloc, ScoreState>(
      'emits [ScoreReady] with default values when initialize() is called',
      build: () {
        SharedPreferences.setMockInitialValues(Map<String, Object>.from(defaultMockValues));
        return ScoreBloc();
      },
      act: (bloc) async {
        await bloc.initialize();
      },
      expect: () => [
        ScoreReady(counter: 0, failCounter: 0, lastRecordedName: ''),
      ],
    );

    blocTest<ScoreBloc, ScoreState>(
      'emits [ScoreReady] when ScoreReadyEvent is added',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          ScoreBloc.counterKey: 5,
          ScoreBloc.failCounterKey: 2,
          ScoreBloc.lastRecordedNameKey: 'PlayerX',
          // Ensure other keys used by ScoreReady are present if not default
          ScoreBloc.maxScoresListKey: <String>[],
          ScoreBloc.minScoreKey: 0,
          ScoreBloc.scoreRecordKey: 0,
        });
        scoreBloc = ScoreBloc();
        await scoreBloc.initialize(); // Ensure prefs are loaded for the bloc instance
      },
      build: () => scoreBloc,
      act: (bloc) => bloc.add(ScoreReadyEvent()),
      expect: () => [
        ScoreReady(counter: 5, failCounter: 2, lastRecordedName: 'PlayerX'),
      ],
    );

    group('CountFailEvent', () {
      blocTest<ScoreBloc, ScoreState>(
        'increments counters and emits [ScoredFail]',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            ScoreBloc.counterKey: 10,
            ScoreBloc.failCounterKey: 3,
            ScoreBloc.lastRecordedNameKey: 'Tester',
            ScoreBloc.maxScoresListKey: <String>[],
            ScoreBloc.minScoreKey: 0,
            ScoreBloc.scoreRecordKey: 0,
          });
          scoreBloc = ScoreBloc();
          await scoreBloc.initialize();
        },
        build: () => scoreBloc,
        seed: () => ScoreReady(counter: 10, failCounter: 3, lastRecordedName: 'Tester'),
        act: (bloc) => bloc.add(CountFailEvent()),
        expect: () => [
          ScoredFail(counter: 11, failCounter: 4, lastRecordedName: 'Tester'),
        ],
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getInt(ScoreBloc.counterKey), 11);
          expect(prefs.getInt(ScoreBloc.failCounterKey), 4);
        },
      );
    });

    group('ScoredPointsEvent', () {
      blocTest<ScoreBloc, ScoreState>(
        'when score is NOT a new record, increments counter, saves score, emits [ScoredPoints]',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            ScoreBloc.counterKey: 1,
            ScoreBloc.failCounterKey: 0,
            ScoreBloc.scoreRecordKey: 1000,
            ScoreBloc.maxScoresListKey: <String>['1000|1|Hero'],
            ScoreBloc.minScoreKey: 1000,
            ScoreBloc.lastRecordedNameKey: 'Hero',
          });
          scoreBloc = ScoreBloc();
          await scoreBloc.initialize();
        },
        build: () => scoreBloc,
        seed: () => ScoreReady(counter: 1, failCounter: 0, lastRecordedName: 'Hero'),
        act: (bloc) => bloc.add(ScoredPointsEvent(500)),
        expect: () => [
          ScoredPoints(counter: 2, failCounter: 0, lastRecordedName: 'Hero'),
        ],
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getInt(ScoreBloc.counterKey), 2);
          final maxScores = prefs.getStringList(ScoreBloc.maxScoresListKey);
          expect(maxScores, isNotEmpty);
          expect(maxScores!.first, contains('1000|1|Hero'));
          expect(prefs.getInt(ScoreBloc.minScoreKey), 500);
        },
      );

      blocTest<ScoreBloc, ScoreState>(
        'when score IS a new record, increments counter, emits [NewRecord]',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            ScoreBloc.counterKey: 4,
            ScoreBloc.failCounterKey: 1,
            ScoreBloc.scoreRecordKey: 200,
            ScoreBloc.lastRecordedNameKey: 'Champion',
            ScoreBloc.maxScoresListKey: <String>[],
            ScoreBloc.minScoreKey: 0,
          });
          scoreBloc = ScoreBloc();
          await scoreBloc.initialize();
        },
        build: () => scoreBloc,
        seed: () => ScoreReady(counter: 4, failCounter: 1, lastRecordedName: 'Champion'),
        act: (bloc) => bloc.add(ScoredPointsEvent(1500)),
        expect: () => [
          NewRecord(score: 1500, lastRecordedName: 'Champion'),
        ],
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getInt(ScoreBloc.counterKey), 5);
          expect(prefs.getInt(ScoreBloc.scoreRecordKey), 200); // Record not updated yet
        },
      );
    });

    blocTest<ScoreBloc, ScoreState>(
      'emits [NewRecord] when NewRecordEvent is added',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          ScoreBloc.lastRecordedNameKey: 'Legend',
          ScoreBloc.counterKey: 0, // ensure all required keys for state are present
          ScoreBloc.failCounterKey: 0,
          ScoreBloc.maxScoresListKey: <String>[],
          ScoreBloc.minScoreKey: 0,
          ScoreBloc.scoreRecordKey: 0,
        });
        scoreBloc = ScoreBloc();
        await scoreBloc.initialize();
      },
      build: () => scoreBloc,
      seed: () => ScoreReady(counter: 0, failCounter: 0, lastRecordedName: 'Legend'),
      act: (bloc) => bloc.add(NewRecordEvent(2000)),
      expect: () => [
        NewRecord(score: 2000, lastRecordedName: 'Legend'),
      ],
    );

    group('SaveRecordEvent', () {
      blocTest<ScoreBloc, ScoreState>(
        'sets record, updates name, then emits [ScoredPoints]',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            ScoreBloc.counterKey: 7,
            ScoreBloc.failCounterKey: 2,
            ScoreBloc.scoreRecordKey: 100,
            ScoreBloc.maxScoresListKey: <String>[],
            ScoreBloc.minScoreKey: 100,
            ScoreBloc.lastRecordedNameKey: 'OldName',
          });
          scoreBloc = ScoreBloc();
          await scoreBloc.initialize();
        },
        build: () => scoreBloc,
        seed: () => ScoreReady(counter: 7, failCounter: 2, lastRecordedName: 'OldName'),
        act: (bloc) => bloc.add(SaveRecordEvent(2500, 'NewChampionName')),
        expect: () => [
          ScoredPoints(counter: 8, failCounter: 2, lastRecordedName: 'NewChampionName'),
        ],
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getInt(ScoreBloc.scoreRecordKey), 2500);
          expect(prefs.getString(ScoreBloc.lastRecordedNameKey), 'NewChampionName');
          expect(prefs.getInt(ScoreBloc.counterKey), 8);
          final maxScores = prefs.getStringList(ScoreBloc.maxScoresListKey);
          expect(maxScores, isNotEmpty);
          expect(maxScores!.first, contains('2500'));
          expect(prefs.getInt(ScoreBloc.minScoreKey), 100);
        },
      );
    });

    blocTest<ScoreBloc, ScoreState>(
      'emits [ScoreResults] when ShowScoresEvent is added',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          ScoreBloc.counterKey: 15,
          ScoreBloc.failCounterKey: 5,
          ScoreBloc.maxScoresListKey: ['Game1: 100', 'Game2: 200'],
          ScoreBloc.minScoreKey: 100,
          ScoreBloc.lastRecordedNameKey: 'PlayerScoreViewer',
          ScoreBloc.scoreRecordKey: 0,
        });
        scoreBloc = ScoreBloc();
        await scoreBloc.initialize();
      },
      build: () => scoreBloc,
      seed: () => ScoreReady(counter: 15, failCounter: 5, lastRecordedName: 'PlayerScoreViewer'),
      act: (bloc) => bloc.add(ShowScoresEvent()),
      expect: () => [
        ScoreResults(
          counter: 15,
          failCounter: 5,
          maxScores: ['Game1: 100', 'Game2: 200'],
          minScore: 100,
        ),
      ],
    );

    blocTest<ScoreBloc, ScoreState>(
      'emits [ScoreReady] when DismissScoresEvent is added',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          ScoreBloc.counterKey: 20,
          ScoreBloc.failCounterKey: 8,
          ScoreBloc.lastRecordedNameKey: 'DismissUser',
          ScoreBloc.maxScoresListKey: <String>[],
          ScoreBloc.minScoreKey: 0,
          ScoreBloc.scoreRecordKey: 0,
        });
        scoreBloc = ScoreBloc();
        await scoreBloc.initialize();
      },
      build: () => scoreBloc,
      seed: () => ScoreResults(counter: 20, failCounter: 8, maxScores: [], minScore: null, lastRecordedName: 'DismissUser'),
      act: (bloc) => bloc.add(DismissScoresEvent()),
      expect: () => [
        ScoreReady(counter: 20, failCounter: 8, lastRecordedName: 'DismissUser'),
      ],
    );

    blocTest<ScoreBloc, ScoreState>(
      'emits [ChangeRecordedName] when ChangeRecordedNameEvent is added',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          ScoreBloc.lastRecordedNameKey: 'CurrentPlayer',
          ScoreBloc.counterKey: 0,
          ScoreBloc.failCounterKey: 0,
          ScoreBloc.maxScoresListKey: <String>[],
          ScoreBloc.minScoreKey: 0,
          ScoreBloc.scoreRecordKey: 0,
        });
        scoreBloc = ScoreBloc();
        await scoreBloc.initialize();
      },
      build: () => scoreBloc,
      seed: () => ScoreReady(counter: 0, failCounter: 0, lastRecordedName: 'CurrentPlayer'),
      act: (bloc) => bloc.add(ChangeRecordedNameEvent()),
      expect: () => [
        ChangeRecordedName(lastRecordedName: 'CurrentPlayer'),
      ],
    );

    blocTest<ScoreBloc, ScoreState>(
      'updates name and emits [ScoreReady] when SaveRecordNameEvent is added',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          ScoreBloc.counterKey: 30,
          ScoreBloc.failCounterKey: 10,
          ScoreBloc.lastRecordedNameKey: 'OldPlayerName',
          ScoreBloc.maxScoresListKey: <String>[],
          ScoreBloc.minScoreKey: 0,
          ScoreBloc.scoreRecordKey: 0,
        });
        scoreBloc = ScoreBloc();
        await scoreBloc.initialize();
      },
      build: () => scoreBloc,
      seed: () => ScoreReady(counter: 30, failCounter: 10, lastRecordedName: 'OldPlayerName'),
      act: (bloc) => bloc.add(SaveRecordNameEvent('NewPlayerName')),
      expect: () => [
        ScoreReady(counter: 30, failCounter: 10, lastRecordedName: 'NewPlayerName'),
      ],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(ScoreBloc.lastRecordedNameKey), 'NewPlayerName');
      },
    );

    group('Equatable Props', () {
      test('ScoreEvent props', () {
        expect(ScoreReadyEvent().props, []);
        expect(CountFailEvent().props, []);
        expect(ScoredPointsEvent(100).props, [100]);
        expect(ShowScoresEvent().props, []);
        expect(DismissScoresEvent().props, []);
        expect(NewRecordEvent(200).props, [200]);
        expect(SaveRecordEvent(300, 'name').props, [300, 'name']);
        expect(ChangeRecordedNameEvent().props, []);
        expect(SaveRecordNameEvent('name').props, ['name']);
      });

      test('ScoreState props', () {
        expect(ScoreInitial().props, [null]);
        
        final readyState = ScoreReady(counter: 1, failCounter: 1, lastRecordedName: 'A');
        expect(readyState.props, [1, 1, 'A']);

        final scoredPoints = ScoredPoints(counter: 2, failCounter: 2, lastRecordedName: 'B');
        expect(scoredPoints.props, [2, 2, 'B']);

        final scoredFail = ScoredFail(counter: 3, failCounter: 3, lastRecordedName: 'C');
        expect(scoredFail.props, [3, 3, 'C']);

        final resultsState = ScoreResults(
          counter: 4,
          failCounter: 4,
          maxScores: ['s1'],
          minScore: 10,
          lastRecordedName: 'D',
        );
        expect(resultsState.props, [['s1'], 4, 4, 10, 'D']);

        final newRecordState = NewRecord(score: 100, lastRecordedName: 'E');
        expect(newRecordState.props, [100, 'E']);
        
        final changeNameState = ChangeRecordedName(lastRecordedName: 'F');
        expect(changeNameState.props, ['F']);
      });
    });
  });
}
