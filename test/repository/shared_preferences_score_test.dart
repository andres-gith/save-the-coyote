import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/repository/shared_preferences_score.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesScore', () {
    late SharedPreferencesScore sharedPreferencesScore;

    setUp(() async {
      // It's important to clear and set default values for each test
      SharedPreferences.setMockInitialValues({});
      sharedPreferencesScore = SharedPreferencesScore();
      await sharedPreferencesScore.initialize(); // Initialize for each test
    });

    test('initialize loads SharedPreferences instance', () {
      // The main check is that sharedPreferencesScore.prefs is not null.
      // This is implicitly tested by other tests, but an explicit one is fine.
      expect(sharedPreferencesScore.prefs, isNotNull);
    });

    group('CounterValue', () {
      test('getCounterValue returns 0 by default', () {
        expect(sharedPreferencesScore.getCounterValue(), 0);
      });

      test('getCounterValue returns stored value', () async {
        SharedPreferences.setMockInitialValues({SharedPreferencesScore.counterKey: 10});
        // Re-initialize to load new mock values
        await sharedPreferencesScore.initialize();
        expect(sharedPreferencesScore.getCounterValue(), 10);
      });

      test('setCounterValue stores the value', () async {
        sharedPreferencesScore.setCounterValue(5);
        // Wait for async operation to complete
        await Future.delayed(Duration.zero);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(SharedPreferencesScore.counterKey), 5);
      });
    });

    group('FailCounterValue', () {
      test('getFailCounterValue returns 0 by default', () {
        expect(sharedPreferencesScore.getFailCounterValue(), 0);
      });

      test('getFailCounterValue returns stored value', () async {
        SharedPreferences.setMockInitialValues({SharedPreferencesScore.failCounterKey: 3});
        await sharedPreferencesScore.initialize();
        expect(sharedPreferencesScore.getFailCounterValue(), 3);
      });

      test('setFailCounterValue stores the value', () async {
        sharedPreferencesScore.setFailCounterValue(2);
        await Future.delayed(Duration.zero);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(SharedPreferencesScore.failCounterKey), 2);
      });
    });

    group('MinScoreValue', () {
      test('getMinScoreValue returns null by default', () {
        expect(sharedPreferencesScore.getMinScoreValue(), isNull);
      });

      test('getMinScoreValue returns stored value', () async {
        SharedPreferences.setMockInitialValues({SharedPreferencesScore.minScoreKey: 100});
        await sharedPreferencesScore.initialize();
        expect(sharedPreferencesScore.getMinScoreValue(), 100);
      });

      test('setMinScoreValue stores the value', () async {
        sharedPreferencesScore.setMinScoreValue(200);
        await Future.delayed(Duration.zero);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(SharedPreferencesScore.minScoreKey), 200);
      });
    });

    group('LastRecordedName', () {
      test('getLastRecordedName returns empty string by default', () {
        expect(sharedPreferencesScore.getLastRecordedName(), '');
      });

      test('getLastRecordedName returns stored value', () async {
        SharedPreferences.setMockInitialValues({SharedPreferencesScore.lastRecordedNameKey: 'Player1'});
        await sharedPreferencesScore.initialize();
        expect(sharedPreferencesScore.getLastRecordedName(), 'Player1');
      });

      test('setLastRecordedName stores the value', () async {
        sharedPreferencesScore.setLastRecordedName('CoyoteFan');
        await Future.delayed(Duration.zero);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(SharedPreferencesScore.lastRecordedNameKey), 'CoyoteFan');
      });
    });

    group('RecordValue', () {
      test('getRecordValue returns 0 by default', () {
        expect(sharedPreferencesScore.getRecordValue(), 0);
      });

      test('getRecordValue returns stored value', () async {
        SharedPreferences.setMockInitialValues({SharedPreferencesScore.scoreRecordKey: 5000});
        await sharedPreferencesScore.initialize();
        expect(sharedPreferencesScore.getRecordValue(), 5000);
      });

      test('setRecordValue stores the value', () async {
        sharedPreferencesScore.setRecordValue(9999);
        await Future.delayed(Duration.zero);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(SharedPreferencesScore.scoreRecordKey), 9999);
      });
    });

    group('MaxScoresList', () {
      test('getMaxScoresList returns empty list by default', () {
        // The implementation returns List<String>.empty() which is fine.
        // Using isEmpty for broader compatibility if that changes.
        expect(sharedPreferencesScore.getMaxScoresList(), isEmpty);
      });

      test('getMaxScoresList returns stored value', () async {
        final scores = ['Player1: 100', 'Player2: 200'];
        SharedPreferences.setMockInitialValues({SharedPreferencesScore.maxScoresListKey: scores});
        await sharedPreferencesScore.initialize();
        expect(sharedPreferencesScore.getMaxScoresList(), scores);
      });

      test('setMaxScoresList stores the value', () async {
        final newScores = ['Wile E.: 50', 'Road Runner: 5000'];
        sharedPreferencesScore.setMaxScoresList(newScores);
        await Future.delayed(Duration.zero);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList(SharedPreferencesScore.maxScoresListKey), newScores);
      });
    });
  });
}
