part of 'score_bloc.dart';

@immutable
sealed class ScoreEvent extends Equatable {
  const ScoreEvent();

  @override
  List<Object> get props => [];
}

class ScoreReadyEvent extends ScoreEvent {
  const ScoreReadyEvent();
}

class CountFailEvent extends ScoreEvent {
  const CountFailEvent();
}

class ScoredPointsEvent extends ScoreEvent {
  const ScoredPointsEvent(this.score);

  final int score;

  @override
  List<Object> get props => [score];
}

class ShowScoresEvent extends ScoreEvent {
  const ShowScoresEvent();
}

class DismissScoresEvent extends ScoreEvent {
  const DismissScoresEvent();
}

class NewRecordEvent extends ScoreEvent {
  const NewRecordEvent(this.score);

  final int score;

  @override
  List<Object> get props => [score];
}

class SaveRecordEvent extends ScoreEvent {
  const SaveRecordEvent(this.score, this.name);

  final String name;
  final int score;

  @override
  List<Object> get props => [score, name];
}

class ChangeRecordedNameEvent extends ScoreEvent {
  const ChangeRecordedNameEvent();
}

class SaveRecordNameEvent extends ScoreEvent {
  const SaveRecordNameEvent(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}
