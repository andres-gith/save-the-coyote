part of 'engine_bloc.dart';

@immutable
sealed class EngineState extends Equatable {
  @override
  List<Object?> get props => [];

  const EngineState();
}

const double _failPosition = 1.0; // Position indicating failure to save the coyote
final class EngineInitial extends EngineState {}

final class Instructions extends EngineState {}
final class IntroScreen extends EngineState {}

final class EngineRunning extends EngineState {
  const EngineRunning(this.position);

  final double position;

  @override
  List<Object?> get props => [position];
}

final class CoyoteFalling extends EngineRunning {
  const CoyoteFalling(super.position);
}

final class CoyoteStopped extends EngineRunning {
  const CoyoteStopped(super.position);
}

final class CoyoteFell extends EngineRunning {
  const CoyoteFell() : super(_failPosition);
}

final class CoyoteSaved extends CoyoteStopped {
  const CoyoteSaved(super.position, this.score);
  final int score;
}

final class CoyoteNotSaved extends CoyoteStopped {
  const CoyoteNotSaved() : super(_failPosition);
}