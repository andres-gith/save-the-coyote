import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_coyote/model/models.dart';

part 'engine_event.dart';

part 'engine_state.dart';

class EngineBloc extends Bloc<EngineEvent, EngineState> {
  final CoyoteFallingEngine _coyoteFallingEngine = CoyoteFallingEngine();

  EngineBloc() : super(EngineInitial()) {
    on<OnLoadEvent>(_onLoad);
    on<StartFallEvent>(_onStartFall);
    on<StopFallEvent>(_onStopFall);
    on<ShowInstructions>(_onShowInstructions);
    on<ShowIntroEvent>(_onShowIntroEvent);
    on<TapRegisteredEvent>(_onTapRegistered);
  }

  Future<void> _onLoad(OnLoadEvent event, Emitter emit) async {
    add(ShowIntroEvent());
    await emit.onEach(
      _coyoteFallingEngine.fallingStream,
      onData: (double position) {
        if (position < 1.0) {
          emit(CoyoteFalling(position));
        } else {
          emit(CoyoteFell());
        }
      },
    );
  }

  Future<void> _onStartFall(StartFallEvent event, Emitter emit) async {
    _coyoteFallingEngine.startFalling();
  }

  Future<void> _onStopFall(StopFallEvent event, Emitter emit) async {
    _coyoteFallingEngine.stopFalling();
    if (state is EngineRunning && (state as EngineRunning).position < 1.0) {
      emit(CoyoteSaved((state as EngineRunning).position, _calculateScore((state as EngineRunning).position)));
    } else {
      emit(CoyoteNotSaved());
    }
  }

  Future<void> _onShowInstructions(ShowInstructions event, Emitter emit) async {
    emit(Instructions());
  }

  Future<void> _onShowIntroEvent(ShowIntroEvent event, Emitter emit) async {
    emit(IntroScreen());
  }

  Future<void> _onTapRegistered(TapRegisteredEvent event, Emitter emit) async {
    if (state is CoyoteFalling) {
      add(StopFallEvent());
    } else if (state is CoyoteStopped) {
      add(StartFallEvent());
    }
  }

  int _calculateScore(double position) {
    return (position * 1000).clamp(0, 1000).toInt();
  }

  void dispose() {
    _coyoteFallingEngine.dispose();
  }
}
