part of 'score_bloc.dart';

@immutable
sealed class ScoreEvent {}

class ScoreReadyEvent extends ScoreEvent {
  ScoreReadyEvent();
}

class CountFailEvent extends ScoreEvent {
  CountFailEvent();
}

class ScoredPointsEvent extends ScoreEvent {
  ScoredPointsEvent(this.score);

  final int score;
}

class ShowScoresEvent extends ScoreEvent {
  ShowScoresEvent();
}

class DismissScoresEvent extends ScoreEvent {
  DismissScoresEvent();
}

class NewRecordEvent extends ScoreEvent {
  NewRecordEvent(this.score);

  final int score;
}

class SaveRecordEvent extends ScoreEvent {
  SaveRecordEvent(this.score, this.name);

  final String name;
  final int score;
}

class ChangeRecordedNameEvent extends ScoreEvent {
  ChangeRecordedNameEvent();
}

class SaveRecordNameEvent extends ScoreEvent {
  SaveRecordNameEvent(this.name);

  final String name;
}
