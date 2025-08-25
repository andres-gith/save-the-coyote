
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'engine_event.dart';

part 'engine_state.dart';

class EngineBloc extends Bloc<EngineEvent, EngineState> {
  EngineBloc() : super(EngineInitial()) {
    on<EngineEvent>((event, emit) {
      switch (event.runtimeType) {
        case const (StartFallEvent):
          emit(CoyoteFalling(0.0));
          break;
        case const (UpdatePositionEvent):
          final position = (event as UpdatePositionEvent).position;
          if (position < 1.0) {
            emit(CoyoteFalling(position));
          } else {
            emit(FailedToSaveCoyote());
          }
          break;
        case const (StopFallEvent):
          final stopEvent = event as StopFallEvent;
          if (stopEvent.position < 1.0) {
            emit(CoyoteSaved(stopEvent.position, calculateScore(stopEvent.position)));
          } else {
            emit(CoyoteNotSaved());
          }
          break;
        case const (ShowInstructions):
          emit(Instructions());
          break;
        case const (ShowIntroEvent):
          emit(IntroScreen());
          break;
      }
    });
  }

  int calculateScore(double position) {
    return (position * 1000).clamp(0, 1000).toInt();
  }

  void initialize() {
    add(ShowIntroEvent());
  }
}
