import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:save_coyote/model/score_engine.dart';
import 'package:save_coyote/model/score_model.dart';
import 'package:save_coyote/repository/score_repository.dart';

// Mock class for ScoreRepository
class MockScoreRepository extends Mock implements ScoreRepository {}

void main() {
  late ScoreEngine scoreEngine;
  late MockScoreRepository mockScoreRepository;

  setUp(() {
    mockScoreRepository = MockScoreRepository();
    scoreEngine = ScoreEngine(mockScoreRepository);

    // Default stubs for all repository methods to prevent MissingStubError
    when(() => mockScoreRepository.initialize()).thenAnswer((_) async => Future.value());
    when(() => mockScoreRepository.getCounterValue()).thenReturn(0);
    when(() => mockScoreRepository.setCounterValue(any())).thenAnswer((_) async => Future.value());
    when(() => mockScoreRepository.getFailCounterValue()).thenReturn(0);
    when(() => mockScoreRepository.setFailCounterValue(any())).thenAnswer((_) async => Future.value());
    when(() => mockScoreRepository.getMinScoreValue()).thenReturn(null);
    when(() => mockScoreRepository.setMinScoreValue(any())).thenAnswer((_) async => Future.value());
    when(() => mockScoreRepository.getLastRecordedName()).thenReturn('');
    when(() => mockScoreRepository.setLastRecordedName(any())).thenAnswer((_) async => Future.value());
    when(() => mockScoreRepository.getRecordValue()).thenReturn(0);
    when(() => mockScoreRepository.setRecordValue(any())).thenAnswer((_) async => Future.value());
    when(() => mockScoreRepository.getMaxScoresList()).thenReturn([]);
    when(() => mockScoreRepository.setMaxScoresList(any())).thenAnswer((_) async => Future.value());
  });

  group('ScoreEngine Initialization', () {
    test('initialize should call repository methods and set initial values', () async {
      when(() => mockScoreRepository.getCounterValue()).thenReturn(5);
      when(() => mockScoreRepository.getFailCounterValue()).thenReturn(2);
      when(() => mockScoreRepository.getMinScoreValue()).thenReturn(100);
      when(() => mockScoreRepository.getLastRecordedName()).thenReturn('PlayerOne');
      when(() => mockScoreRepository.getRecordValue()).thenReturn(1000);
      when(
        () => mockScoreRepository.getMaxScoresList(),
      ).thenReturn([ScoreModel(score: 1000, counter: 1, name: 'PlayerOne')]);

      await scoreEngine.initialize();

      verify(() => mockScoreRepository.initialize()).called(1);
      verify(() => mockScoreRepository.getCounterValue()).called(1);
      verify(() => mockScoreRepository.getFailCounterValue()).called(1);
      verify(() => mockScoreRepository.getMinScoreValue()).called(1);
      verify(() => mockScoreRepository.getLastRecordedName()).called(1);
      verify(() => mockScoreRepository.getRecordValue()).called(1);
      verify(() => mockScoreRepository.getMaxScoresList()).called(1);

      expect(scoreEngine.counterValue, 5);
      expect(scoreEngine.failCounterValue, 2);
      expect(scoreEngine.minScoreValue, 100);
      expect(scoreEngine.lastRecordedName, 'PlayerOne');
      expect(scoreEngine.recordValue, 1000);
      expect(scoreEngine.maxScoresList, [ScoreModel(score: 1000, counter: 1, name: 'PlayerOne')]);
    });
  });

  group('Property Accessors', () {
    setUp(() async {
      // Ensure engine is initialized before each property test for consistent state
      await scoreEngine.initialize();
    });

    test('counterValue getter and setter', () async {
      when(() => mockScoreRepository.getCounterValue()).thenReturn(10);
      scoreEngine = ScoreEngine(mockScoreRepository);
      await scoreEngine.initialize();

      expect(scoreEngine.counterValue, 10);

      scoreEngine.counterValue = 15;
      expect(scoreEngine.counterValue, 15);
      verify(() => mockScoreRepository.setCounterValue(15)).called(1);
    });

    test('failCounterValue getter and setter', () async {
      when(() => mockScoreRepository.getFailCounterValue()).thenReturn(3);
      scoreEngine = ScoreEngine(mockScoreRepository);
      await scoreEngine.initialize();

      expect(scoreEngine.failCounterValue, 3);

      scoreEngine.failCounterValue = 7;
      expect(scoreEngine.failCounterValue, 7);
      verify(() => mockScoreRepository.setFailCounterValue(7)).called(1);
    });

    test('minScoreValue getter and setter', () async {
      when(() => mockScoreRepository.getMinScoreValue()).thenReturn(50);
      scoreEngine = ScoreEngine(mockScoreRepository);
      await scoreEngine.initialize();

      expect(scoreEngine.minScoreValue, 50);

      scoreEngine.minScoreValue = 25;
      expect(scoreEngine.minScoreValue, 25);
      verify(() => mockScoreRepository.setMinScoreValue(25)).called(1);

      scoreEngine.minScoreValue = null;
      expect(scoreEngine.minScoreValue, null);
      verify(() => mockScoreRepository.setMinScoreValue(0)).called(1); // Sets to 0 if null
    });

    test('lastRecordedName getter and setter with sanitization', () async {
      when(() => mockScoreRepository.getLastRecordedName()).thenReturn('InitialName');
      scoreEngine = ScoreEngine(mockScoreRepository);
      await scoreEngine.initialize();

      expect(scoreEngine.lastRecordedName, 'InitialName');

      scoreEngine.lastRecordedName = 'Player!@#Name';
      expect(scoreEngine.lastRecordedName, 'PlayerName');
      verify(() => mockScoreRepository.setLastRecordedName('PlayerName')).called(1);

      scoreEngine.lastRecordedName = 'Valid Name123';
      expect(scoreEngine.lastRecordedName, 'Valid Name123');
      verify(() => mockScoreRepository.setLastRecordedName('Valid Name123')).called(1);
    });

    test('recordValue getter and setter', () async {
      when(() => mockScoreRepository.getRecordValue()).thenReturn(200);
      scoreEngine = ScoreEngine(mockScoreRepository);
      await scoreEngine.initialize();

      expect(scoreEngine.recordValue, 200);

      scoreEngine.recordValue = 300;
      expect(scoreEngine.recordValue, 300);
      verify(() => mockScoreRepository.setRecordValue(300)).called(1);
    });

    test('maxScoresList getter and setter', () async {
      var mockedScore = ScoreModel(score: 10, counter: 1, name: 'S1');
      when(() => mockScoreRepository.getMaxScoresList()).thenReturn([mockedScore]);
      scoreEngine = ScoreEngine(mockScoreRepository);
      await scoreEngine.initialize();

      expect(scoreEngine.maxScoresList, [mockedScore]);

      final newList = [ScoreModel(score: 20, counter: 2, name: 'S2')];
      scoreEngine.maxScoresList = newList;
      expect(scoreEngine.maxScoresList, newList);
      verify(() => mockScoreRepository.setMaxScoresList(newList)).called(1);
    });
  });

  group('incrementCounter', () {
    test('increments counter and calls repository', () async {
      when(() => mockScoreRepository.getCounterValue()).thenReturn(5);
      await scoreEngine.initialize(); // Load initial value

      await scoreEngine.incrementCounter();
      expect(scoreEngine.counterValue, 6);
      verify(() => mockScoreRepository.setCounterValue(6)).called(1);
    });
  });

  group('incrementFailCounter', () {
    test('increments failCounter and calls repository', () async {
      when(() => mockScoreRepository.getFailCounterValue()).thenReturn(1);
      await scoreEngine.initialize(); // Load initial value

      await scoreEngine.incrementFailCounter();
      expect(scoreEngine.failCounterValue, 2);
      verify(() => mockScoreRepository.setFailCounterValue(2)).called(1);
    });
  });

  group('saveScore', () {
    setUp(() async {
      // Set up initial state for saveScore tests
      when(() => mockScoreRepository.getCounterValue()).thenReturn(1); // Example counter
      when(() => mockScoreRepository.getLastRecordedName()).thenReturn('TestPlayer');
      when(() => mockScoreRepository.getMaxScoresList()).thenReturn([]);
      when(() => mockScoreRepository.getMinScoreValue()).thenReturn(null);
      await scoreEngine.initialize();
    });

    test('adds score to empty list, updates minScore', () async {
      var mockedScore = ScoreModel(score: 100, counter: 1, name: 'TestPlayer');
      await scoreEngine.saveScore(100);
      expect(scoreEngine.maxScoresList, [mockedScore]);
      verify(() => mockScoreRepository.setMaxScoresList([mockedScore])).called(1);
      expect(scoreEngine.minScoreValue, 100);
      verify(() => mockScoreRepository.setMinScoreValue(100)).called(1);
    });

    test('adds score, updates minScore if new score is lower', () async {
      // Initial minScoreValue is null from setUp -> initialize()
      // Then saveScore(200) sets it to 200
      await scoreEngine.saveScore(200);
      expect(scoreEngine.minScoreValue, 200);
      verify(() => mockScoreRepository.setMinScoreValue(200)).called(1);

      // Now save a lower score
      await scoreEngine.saveScore(150);
      expect(scoreEngine.minScoreValue, 150);
      verify(() => mockScoreRepository.setMinScoreValue(150)).called(1);
    });

    test('adds score, does not update minScore if new score is higher', () async {
      // Initial minScoreValue is null from setUp -> initialize()
      // Save 100, minScore becomes 100
      await scoreEngine.saveScore(100);
      expect(scoreEngine.minScoreValue, 100);
      verify(() => mockScoreRepository.setMinScoreValue(100)).called(1);

      // Save 150, minScore should remain 100
      await scoreEngine.saveScore(150);
      expect(scoreEngine.minScoreValue, 100);
      // Verifies that setMinScoreValue was called with 100 again (as part of _getLesserScore logic)
      verify(() => mockScoreRepository.setMinScoreValue(100)).called(1); // This is the crucial part for this test logic
    });

    test('maintains max 10 scores, sorted correctly', () async {
      // Fill with 10 scores
      for (int i = 1; i <= 10; i++) {
        await scoreEngine.saveScore(i * 10); // 10, 20, ..., 100
      }
      expect(scoreEngine.maxScoresList.length, 10);
      expect(scoreEngine.maxScoresList.first, ScoreModel(score: 100, counter: 1, name: 'TestPlayer'));
      expect(scoreEngine.maxScoresList.last, ScoreModel(score: 10, counter: 1, name: 'TestPlayer'));
      // Verify setMaxScoresList was called 10 times during the loop
      verify(() => mockScoreRepository.setMaxScoresList(any(that: isA<List<ScoreModel>>()))).called(10);

      await scoreEngine.saveScore(101); // New highest score
      expect(scoreEngine.maxScoresList.length, 10);
      expect(scoreEngine.maxScoresList.first, ScoreModel(score: 101, counter: 1, name: 'TestPlayer'));
      expect(scoreEngine.maxScoresList.last, ScoreModel(score: 20, counter: 1, name: 'TestPlayer')); // 10 is pushed out
      verify(() => mockScoreRepository.setMaxScoresList(any(that: isA<List<ScoreModel>>()))).called(1); // Called once more

      await scoreEngine.saveScore(5); // Lowest score, should not be added
      expect(scoreEngine.maxScoresList.length, 10);
      expect(scoreEngine.maxScoresList.contains(ScoreModel(score: 5, counter: 1, name: 'TestPlayer')), isFalse);
      expect(scoreEngine.maxScoresList.last, ScoreModel(score: 20, counter: 1, name: 'TestPlayer')); // Still 20
      verify(() => mockScoreRepository.setMaxScoresList(any(that: isA<List<ScoreModel>>()))).called(1); // Called once more

      await scoreEngine.saveScore(55); // Middle score
      expect(scoreEngine.maxScoresList.length, 10);
      expect(scoreEngine.maxScoresList.contains(ScoreModel(score: 55, counter: 1, name: 'TestPlayer')), isTrue);
      // The list after 101, 100, ..., 20 and then 55 is added:
      // (101, 100, 90, 80, 70, 60, 55, 50, 40, 30) -> 20 is out. New last is 30.
      expect(scoreEngine.maxScoresList.last, ScoreModel(score: 30, counter: 1, name: 'TestPlayer'));
      verify(() => mockScoreRepository.setMaxScoresList(any(that: isA<List<ScoreModel>>()))).called(1); // Called once more
    });
  });
}
