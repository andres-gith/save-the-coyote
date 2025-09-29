part of 'score_bloc.dart';

@immutable
sealed class ScoreState extends Equatable {
  const ScoreState({this.lastRecordedName});

  final String? lastRecordedName;

  @override
  List<Object?> get props => [lastRecordedName];
}

final class ScoreInitial extends ScoreState {}

final class ScoreReady extends ScoreState {
  const ScoreReady({super.lastRecordedName, required this.counter, required this.failCounter});

  final int counter;
  final int failCounter;

  @override
  List<Object?> get props => [counter, failCounter, lastRecordedName];
}

final class ScoredPoints extends ScoreReady {
  const ScoredPoints({super.lastRecordedName, required super.counter, required super.failCounter});
}

final class ScoredFail extends ScoreReady {
  const ScoredFail({super.lastRecordedName, required super.counter, required super.failCounter});
}

final class ScoreResults extends ScoreState {
  const ScoreResults({
    super.lastRecordedName,
    this.minScore,
    required this.counter,
    required this.failCounter,
    required this.maxScores,
  });

  final List<ScoreModel> maxScores;
  final int counter;
  final int failCounter;
  final int? minScore;

  @override
  List<Object?> get props => [maxScores, counter, failCounter, minScore, lastRecordedName];
}

final class NewRecord extends ScoreState {
  const NewRecord({super.lastRecordedName, required this.score});

  final int score;

  @override
  List<Object?> get props => [score, lastRecordedName];
}

final class ChangeRecordedName extends ScoreState {
  const ChangeRecordedName({super.lastRecordedName});

  @override
  List<Object?> get props => [lastRecordedName];
}