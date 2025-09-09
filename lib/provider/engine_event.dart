part of 'engine_bloc.dart';

@immutable
sealed class EngineEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const EngineEvent();
}

class OnLoadEvent extends EngineEvent {
  const OnLoadEvent();
}

class StartFallEvent extends EngineEvent {
  const StartFallEvent();
}

class StopFallEvent extends EngineEvent {
  const StopFallEvent();
}

class ShowInstructions extends EngineEvent {
  const ShowInstructions();
}

class ShowIntroEvent extends EngineEvent {
  const ShowIntroEvent();
}

class TapRegisteredEvent extends EngineEvent {
  const TapRegisteredEvent();
}
