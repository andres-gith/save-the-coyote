part of 'engine_bloc.dart';

@immutable
sealed class EngineEvent {}

class StartFallEvent extends EngineEvent {
  StartFallEvent();
}

class UpdatePositionEvent extends EngineEvent {
  UpdatePositionEvent(this.position);
  final double position;
}

class StopFallEvent extends EngineEvent {
  StopFallEvent(this.position);
  final double position;
}

class ShowInstructions extends EngineEvent {
  ShowInstructions();
}

class ShowIntroEvent extends EngineEvent {
  ShowIntroEvent();
}
