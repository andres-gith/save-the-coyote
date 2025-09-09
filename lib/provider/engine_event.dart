part of 'engine_bloc.dart';

@immutable
sealed class EngineEvent {}

class OnLoadEvent extends EngineEvent {
  OnLoadEvent();
}

class StartFallEvent extends EngineEvent {
  StartFallEvent();
}

class StopFallEvent extends EngineEvent {
  StopFallEvent();
}

class ShowInstructions extends EngineEvent {
  ShowInstructions();
}

class ShowIntroEvent extends EngineEvent {
  ShowIntroEvent();
}

class TapRegisteredEvent extends EngineEvent {
  TapRegisteredEvent();
}
