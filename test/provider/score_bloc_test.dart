import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:save_coyote/model/models.dart'; // For ScoreEngine
import 'package:save_coyote/provider/score_bloc.dart';

// Mock ScoreEngine
class MockScoreEngine extends Mock implements ScoreEngine {}

void main() {
  late ScoreBloc scoreBloc;
  late MockScoreEngine mockScoreEngine;

  setUp(() {
    mockScoreEngine = MockScoreEngine();

    // Default stubs for ScoreEngine getters and methods
    when(() => mockScoreEngine.initialize()).thenAnswer((_) async => Future.value());
    when(() => mockScoreEngine.counterValue).thenReturn(0);
    when(() => mockScoreEngine.failCounterValue).thenReturn(0);
    when(() => mockScoreEngine.lastRecordedName).thenReturn('');
    when(() => mockScoreEngine.recordValue).thenReturn(0);
    when(() => mockScoreEngine.minScoreValue).thenReturn(null);
    when(() => mockScoreEngine.maxScoresList).thenReturn([]);

    when(() => mockScoreEngine.incrementCounter()).thenAnswer((_) async => Future.value());
    when(() => mockScoreEngine.incrementFailCounter()).thenAnswer((_) async => Future.value());
    when(() => mockScoreEngine.saveScore(any())).thenAnswer((_) async => Future.value());
    // For setters, thenAnswer must return the value being set.
    when(() => mockScoreEngine.lastRecordedName = any()).thenAnswer((invocation) => invocation.positionalArguments.first as String);
    when(() => mockScoreEngine.recordValue = any()).thenAnswer((invocation) => invocation.positionalArguments.first as int);

    scoreBloc = ScoreBloc(engine: mockScoreEngine);
  });

  tearDown(() {
    scoreBloc.close();
  });

  test('initial state is ScoreInitial', () {
    expect(ScoreBloc(engine: MockScoreEngine()).state, ScoreInitial());
  });

  blocTest<ScoreBloc, ScoreState>(
    'OnLoadScoreEvent: calls engine.initialize and emits [ScoreReady]',
    build: () {
      when(() => mockScoreEngine.counterValue).thenReturn(5);
      when(() => mockScoreEngine.failCounterValue).thenReturn(1);
      when(() => mockScoreEngine.lastRecordedName).thenReturn('LoadedPlayer');
      return scoreBloc;
    },
    act: (bloc) => bloc.add(OnLoadScoreEvent()),
    expect: () => [
      ScoreReady(counter: 5, failCounter: 1, lastRecordedName: 'LoadedPlayer'),
    ],
    verify: (_) {
      verify(() => mockScoreEngine.initialize()).called(1);
    },
  );

  blocTest<ScoreBloc, ScoreState>(
    'ScoreReadyEvent: emits [ScoreReady] with current engine values',
    setUp: () {
      when(() => mockScoreEngine.counterValue).thenReturn(10);
      when(() => mockScoreEngine.failCounterValue).thenReturn(3);
      when(() => mockScoreEngine.lastRecordedName).thenReturn('ReadyPlayer');
    },
    build: () => scoreBloc,
    act: (bloc) => bloc.add(ScoreReadyEvent()),
    expect: () => [
      ScoreReady(counter: 10, failCounter: 3, lastRecordedName: 'ReadyPlayer'),
    ],
  );

  blocTest<ScoreBloc, ScoreState>(
    'CountFailEvent: increments counters, emits [ScoredFail]',
    setUp: () {
      when(() => mockScoreEngine.counterValue).thenReturn(5);
      when(() => mockScoreEngine.failCounterValue).thenReturn(2);
      when(() => mockScoreEngine.lastRecordedName).thenReturn('FailGuy');

      when(() => mockScoreEngine.incrementCounter()).thenAnswer((_) async {
        when(() => mockScoreEngine.counterValue).thenReturn(6);
      });
      when(() => mockScoreEngine.incrementFailCounter()).thenAnswer((_) async {
        when(() => mockScoreEngine.failCounterValue).thenReturn(3);
      });
    },
    build: () => scoreBloc,
    act: (bloc) => bloc.add(CountFailEvent()),
    expect: () => [
      ScoredFail(counter: 6, failCounter: 3, lastRecordedName: 'FailGuy'),
    ],
    verify: (_) {
      verify(() => mockScoreEngine.incrementCounter()).called(1);
      verify(() => mockScoreEngine.incrementFailCounter()).called(1);
    },
  );

  group('ScoredPointsEvent', () {
    blocTest<ScoreBloc, ScoreState>(
      '  when score is NOT a new record: increments counter, saves score, emits [ScoredPoints]',
      setUp: () {
        when(() => mockScoreEngine.counterValue).thenReturn(1);
        when(() => mockScoreEngine.failCounterValue).thenReturn(0);
        when(() => mockScoreEngine.lastRecordedName).thenReturn('Hero');
        when(() => mockScoreEngine.recordValue).thenReturn(1000);

        when(() => mockScoreEngine.incrementCounter()).thenAnswer((_) async {
          when(() => mockScoreEngine.counterValue).thenReturn(2);
        });
      },
      build: () => scoreBloc,
      act: (bloc) => bloc.add(ScoredPointsEvent(500)),
      expect: () => [
        ScoredPoints(counter: 2, failCounter: 0, lastRecordedName: 'Hero'),
      ],
      verify: (_) {
        verify(() => mockScoreEngine.incrementCounter()).called(1);
        verify(() => mockScoreEngine.saveScore(500)).called(1);
      },
    );

    blocTest<ScoreBloc, ScoreState>(
      '  when score IS a new record: increments counter, emits [NewRecord]',
      setUp: () {
        when(() => mockScoreEngine.counterValue).thenReturn(4);
        when(() => mockScoreEngine.failCounterValue).thenReturn(1);
        when(() => mockScoreEngine.lastRecordedName).thenReturn('Champion');
        when(() => mockScoreEngine.recordValue).thenReturn(200);

        when(() => mockScoreEngine.incrementCounter()).thenAnswer((_) async {
          when(() => mockScoreEngine.counterValue).thenReturn(5);
        });
      },
      build: () => scoreBloc,
      act: (bloc) => bloc.add(ScoredPointsEvent(1500)),
      expect: () => [
        NewRecord(score: 1500, lastRecordedName: 'Champion'),
      ],
      verify: (_) {
        verify(() => mockScoreEngine.incrementCounter()).called(1);
        verifyNever(() => mockScoreEngine.saveScore(any()));
      },
    );
  });

  blocTest<ScoreBloc, ScoreState>(
    'ShowScoresEvent: emits [ScoreResults] with engine data',
    setUp: () {
      when(() => mockScoreEngine.minScoreValue).thenReturn(100);
      when(() => mockScoreEngine.counterValue).thenReturn(15);
      when(() => mockScoreEngine.failCounterValue).thenReturn(5);
      when(() => mockScoreEngine.maxScoresList).thenReturn(['Player1:100', 'Player2:200']);
      when(() => mockScoreEngine.lastRecordedName).thenReturn('Viewer');
    },
    build: () => scoreBloc,
    act: (bloc) => bloc.add(ShowScoresEvent()),
    expect: () => [
      ScoreResults(
        minScore: 100,
        counter: 15,
        failCounter: 5,
        maxScores: ['Player1:100', 'Player2:200'],
      ),
    ],
  );

  blocTest<ScoreBloc, ScoreState>(
    'DismissScoresEvent: emits [ScoreReady]',
    setUp: () {
      when(() => mockScoreEngine.counterValue).thenReturn(20);
      when(() => mockScoreEngine.failCounterValue).thenReturn(8);
      when(() => mockScoreEngine.lastRecordedName).thenReturn('DismissUser');
    },
    build: () => scoreBloc,
    seed: () => ScoreResults(minScore: 0, counter: 0, failCounter: 0, maxScores: [], lastRecordedName: ''),
    act: (bloc) => bloc.add(DismissScoresEvent()),
    expect: () => [
      ScoreReady(counter: 20, failCounter: 8, lastRecordedName: 'DismissUser'),
    ],
  );

  blocTest<ScoreBloc, ScoreState>(
    'NewRecordEvent: emits [NewRecord]',
    setUp: () {
      when(() => mockScoreEngine.lastRecordedName).thenReturn('RecordBreaker');
    },
    build: () => scoreBloc,
    act: (bloc) => bloc.add(NewRecordEvent(2000)),
    expect: () => [
      NewRecord(score: 2000, lastRecordedName: 'RecordBreaker'),
    ],
  );

  blocTest<ScoreBloc, ScoreState>(
    'SaveRecordEvent: sets engine properties, saves score, emits [ScoredPoints]',
    setUp: () {
      when(() => mockScoreEngine.counterValue).thenReturn(7);
      when(() => mockScoreEngine.failCounterValue).thenReturn(2);
      when(() => mockScoreEngine.lastRecordedName).thenReturn('OldName');

      when(() => mockScoreEngine.lastRecordedName = 'NewChampionName').thenAnswer((_) {
        when(() => mockScoreEngine.lastRecordedName).thenReturn('NewChampionName');
        return 'NewChampionName'; // Return the value being set
      });
      when(() => mockScoreEngine.recordValue = 2500).thenAnswer((_) {
        when(() => mockScoreEngine.recordValue).thenReturn(2500);
        return 2500; // Return the value being set
      });
    },
    build: () => scoreBloc,
    act: (bloc) => bloc.add(SaveRecordEvent(2500, 'NewChampionName')),
    expect: () => [
      ScoredPoints(counter: 7, failCounter: 2, lastRecordedName: 'NewChampionName'),
    ],
    verify: (_) {
      verify(() => mockScoreEngine.recordValue = 2500).called(1);
      verify(() => mockScoreEngine.lastRecordedName = 'NewChampionName').called(1);
      verify(() => mockScoreEngine.saveScore(2500)).called(1);
    },
  );

  blocTest<ScoreBloc, ScoreState>(
    'ChangeRecordedNameEvent: emits [ChangeRecordedName]',
    setUp: () {
      when(() => mockScoreEngine.lastRecordedName).thenReturn('ChangeMe');
    },
    build: () => scoreBloc,
    act: (bloc) => bloc.add(ChangeRecordedNameEvent()),
    expect: () => [
      ChangeRecordedName(lastRecordedName: 'ChangeMe'),
    ],
  );

  blocTest<ScoreBloc, ScoreState>(
    'SaveRecordNameEvent: sets engine.lastRecordedName, emits [ScoreReady]',
    setUp: () {
      when(() => mockScoreEngine.counterValue).thenReturn(30);
      when(() => mockScoreEngine.failCounterValue).thenReturn(10);
      when(() => mockScoreEngine.lastRecordedName).thenReturn('OldPlayerName');

      when(() => mockScoreEngine.lastRecordedName = 'NewPlayerName').thenAnswer((invocation) {
        when(() => mockScoreEngine.lastRecordedName).thenReturn('NewPlayerName');
        return 'NewPlayerName'; // Return the value being set
      });
    },
    build: () => scoreBloc,
    act: (bloc) => bloc.add(SaveRecordNameEvent('NewPlayerName')),
    expect: () => [
      ScoreReady(counter: 30, failCounter: 10, lastRecordedName: 'NewPlayerName'),
    ],
    verify: (_) {
      verify(() => mockScoreEngine.lastRecordedName = 'NewPlayerName').called(1);
    },
  );

  group('Equatable Props', () {
    test('ScoreEvent props are correct', () {
      expect(OnLoadScoreEvent().props, isEmpty);
      expect(ScoreReadyEvent().props, isEmpty);
      expect(CountFailEvent().props, isEmpty);
      expect(ScoredPointsEvent(100).props, [100]);
      expect(ShowScoresEvent().props, isEmpty);
      expect(DismissScoresEvent().props, isEmpty);
      expect(NewRecordEvent(200).props, [200]);
      expect(SaveRecordEvent(300, 'name').props, [300, 'name']);
      expect(ChangeRecordedNameEvent().props, isEmpty);
      expect(SaveRecordNameEvent('name').props, ['name']);
    });

    test('ScoreState props are correct', () {
      expect(ScoreInitial().props, [null]);
      expect(ScoreReady(counter: 1, failCounter: 1, lastRecordedName: 'A').props, [1, 1, 'A']);
      expect(ScoredPoints(counter: 2, failCounter: 2, lastRecordedName: 'B').props, [2, 2, 'B']);
      expect(ScoredFail(counter: 3, failCounter: 3, lastRecordedName: 'C').props, [3, 3, 'C']);
      final resultsState = ScoreResults(
          counter: 4, failCounter: 4, maxScores: ['s1'], minScore: 10, lastRecordedName: 'D');
      expect(resultsState.props, [['s1'], 4, 4, 10, 'D']);
      expect(NewRecord(score: 100, lastRecordedName: 'E').props, [100, 'E']);
      expect(ChangeRecordedName(lastRecordedName: 'F').props, ['F']);
    });
  });
}
