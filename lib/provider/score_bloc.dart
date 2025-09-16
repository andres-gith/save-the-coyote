import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_coyote/model/models.dart';

part 'score_event.dart';

part 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  final ScoreEngine _scoreEngine;

  ScoreBloc({required ScoreEngine engine}) : _scoreEngine = engine, super(ScoreInitial()) {
    on<OnLoadScoreEvent>(onLoad);
    on<ScoreReadyEvent>(onScoreReady);
    on<CountFailEvent>(onCounterFail);
    on<ScoredPointsEvent>(onScorePoints);
    on<ShowScoresEvent>(onShowScores);
    on<DismissScoresEvent>(onDismissScores);
    on<NewRecordEvent>(onNewRecord);
    on<SaveRecordEvent>(onSaveRecord);
    on<ChangeRecordedNameEvent>(onChangedRecordedName);
    on<SaveRecordNameEvent>(onSaveRecordName);
  }

  void onScoreReady(ScoreReadyEvent event, Emitter<ScoreState> emit) {
    emit(
      ScoreReady(
        counter: _scoreEngine.counterValue,
        failCounter: _scoreEngine.failCounterValue,
        lastRecordedName: _scoreEngine.lastRecordedName,
      ),
    );
  }

  void onCounterFail(CountFailEvent event, Emitter<ScoreState> emit) async {
    await _scoreEngine.incrementCounter();
    await _scoreEngine.incrementFailCounter();
    emit(
      ScoredFail(
        counter: _scoreEngine.counterValue,
        failCounter: _scoreEngine.failCounterValue,
        lastRecordedName: _scoreEngine.lastRecordedName,
      ),
    );
  }

  void onScorePoints(ScoredPointsEvent event, Emitter<ScoreState> emit) async {
    await _scoreEngine.incrementCounter();
    final score = event.score;
    final record = _scoreEngine.recordValue;

    if (score > record) {
      add(NewRecordEvent(score));
    } else {
      _scoreEngine.saveScore(score);
      emit(
        ScoredPoints(
          counter: _scoreEngine.counterValue,
          failCounter: _scoreEngine.failCounterValue,
          lastRecordedName: _scoreEngine.lastRecordedName,
        ),
      );
    }
  }

  void onShowScores(ShowScoresEvent event, Emitter<ScoreState> emit) {
    emit(
      ScoreResults(
        minScore: _scoreEngine.minScoreValue,
        counter: _scoreEngine.counterValue,
        failCounter: _scoreEngine.failCounterValue,
        maxScores: _scoreEngine.maxScoresList,
      ),
    );
  }

  void onDismissScores(DismissScoresEvent event, Emitter<ScoreState> emit) {
    add(ScoreReadyEvent());
  }

  void onNewRecord(NewRecordEvent event, Emitter<ScoreState> emit) {
    emit(NewRecord(lastRecordedName: _scoreEngine.lastRecordedName, score: event.score));
  }

  void onSaveRecord(SaveRecordEvent event, Emitter<ScoreState> emit) async {
    _scoreEngine.recordValue = event.score;
    _scoreEngine.lastRecordedName = event.name;
    _scoreEngine.saveScore(event.score);
    emit(
      ScoredPoints(
        counter: _scoreEngine.counterValue,
        failCounter: _scoreEngine.failCounterValue,
        lastRecordedName: _scoreEngine.lastRecordedName,
      ),
    );
  }

  void onChangedRecordedName(ChangeRecordedNameEvent event, Emitter<ScoreState> emit) {
    emit(ChangeRecordedName(lastRecordedName: _scoreEngine.lastRecordedName));
  }

  void onSaveRecordName(SaveRecordNameEvent event, Emitter<ScoreState> emit) async {
    _scoreEngine.lastRecordedName = event.name;
    add(ScoreReadyEvent());
  }

  Future<void> onLoad(OnLoadScoreEvent event, Emitter<ScoreState> emit) async {
    await _scoreEngine.initialize();
    add(ScoreReadyEvent());
  }
}
