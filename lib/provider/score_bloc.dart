import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_coyote/helper/score_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'score_event.dart';

part 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  late SharedPreferences prefs;
  static const String failCounterKey = 'fail';
  static const String counterKey = 'counter';
  static const String maxScoresListKey = 'maxScoreList';
  static const String minScoreKey = 'minScore';
  static const String lastRecordedNameKey = 'lastRecordedName';
  static const String scoreRecordKey = 'record';

  ScoreBloc() : super(ScoreInitial()) {
    on<ScoreEvent>((event, emit) async {
      final String? lastRecordedName = _getLastRecordedName();
      switch (event.runtimeType) {
        case const (ScoreReadyEvent):
          emit(ScoreReady(counter: _getCounterValue(), failCounter: _getFailCounterValue(), lastRecordedName: lastRecordedName));
          break;
        case const (CountFailEvent):
          await _incrementCounter();
          await _incrementFailCounter();
          emit(ScoredFail(counter: _getCounterValue(), failCounter: _getFailCounterValue(), lastRecordedName: lastRecordedName));
          break;
        case const (ScoredPointsEvent):
          await _incrementCounter();
          final score = (event as ScoredPointsEvent).score;
          final record = _getRecord();
          if (score > record) {
            add(NewRecordEvent(score));
          } else {
            _saveScore(score);
            final counter = _getCounterValue();
            emit(ScoredPoints(counter: counter, failCounter: _getFailCounterValue(), lastRecordedName: lastRecordedName));
          }
          break;
        case const (ShowScoresEvent):
          final failCount = _getFailCounterValue();
          final counter = _getCounterValue();
          final maxScores = _getMaxScoresList();
          final minScore = _getMinScoreValue();
          emit(ScoreResults(minScore: minScore, counter: counter, failCounter: failCount, maxScores: maxScores));
          break;
        case const (DismissScoresEvent):
          add(ScoreReadyEvent());
          break;
        case const (NewRecordEvent):
          final score = (event as NewRecordEvent).score;
          final lastRecordedName = _getLastRecordedName();
          emit(NewRecord(lastRecordedName: lastRecordedName, score: score));
          break;
        case const (SaveRecordEvent):
          final saveEvent = event as SaveRecordEvent;
          final int score = saveEvent.score;
          await _setRecord(score);
          await _setLastRecordedName(saveEvent.name);
          add(ScoredPointsEvent(score));
          break;
        case const (ChangeRecordedNameEvent):
          final lastRecordedName = _getLastRecordedName();
          emit(ChangeRecordedName(lastRecordedName: lastRecordedName));
          break;
        case const (SaveRecordNameEvent):
          final name = (event as SaveRecordNameEvent).name;
          await _setLastRecordedName(name);
          add(ScoreReadyEvent());
          break;
      }
    });
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    add(ScoreReadyEvent());
  }

  int _getCounterValue() {
    return prefs.getInt(counterKey) ?? 0;
  }

  int _getFailCounterValue() {
    return prefs.getInt(failCounterKey) ?? 0;
  }

  int? _getMinScoreValue() {
    return prefs.getInt(minScoreKey);
  }

  List<String> _getMaxScoresList() {
    return prefs.getStringList(maxScoresListKey) ?? List<String>.empty();
  }

  Future<void> _incrementCounter() async {
    final count = _getCounterValue();
    await prefs.setInt(counterKey, count + 1);
  }

  Future<void> _incrementFailCounter() async {
    final failCount = _getFailCounterValue();
    await prefs.setInt(failCounterKey, failCount + 1);
  }

  Future<void> _setMinScore(int score) async {
    await prefs.setInt(minScoreKey, score);
  }

  Future<void> _setMaxScoresList(List<String> scores) async {
    await prefs.setStringList(maxScoresListKey, scores);
  }

  int _getRecord() {
    return prefs.getInt(scoreRecordKey) ?? 0;
  }

  Future<void> _setRecord(int score) async {
    await prefs.setInt(scoreRecordKey, score);
  }

  String? _getLastRecordedName() {
    return prefs.getString(lastRecordedNameKey);
  }

  Future<void> _setLastRecordedName(String name) async {
    await prefs.setString(lastRecordedNameKey, name);
  }

  Future<void> _saveScore(int score) async {
    final List<String> scoreResults = _getMaxScoresList();
    final counter = _getCounterValue();
    final String? lastRecordedName = _getLastRecordedName();
    final newScoreResults = ScoreHelper.addValue(scoreResults, score, counter, lastRecordedName ?? '');
    await _setMaxScoresList(newScoreResults);
    await _setMinScore(ScoreHelper.getLesserScore(_getMinScoreValue(), score));
  }
}
