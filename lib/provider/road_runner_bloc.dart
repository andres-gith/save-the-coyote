
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'road_runner_event.dart';

part 'road_runner_state.dart';

class RoadRunnerBloc extends Bloc<RoadRunnerEvent, RoadRunnerState> {
  RoadRunnerBloc() : super(RoadRunnerIdle()) {
    on<RoadRunnerGoBackToIdle>(onRoadRunnerGoBackToIdle);
    on<RoadRunnerTap>(onRoadRunnerTap);
  }

  void onRoadRunnerTap(RoadRunnerTap event, Emitter<RoadRunnerState> emit) {
    emit(RoadRunnerBeep());
  }

  void onRoadRunnerGoBackToIdle(RoadRunnerGoBackToIdle event, Emitter<RoadRunnerState> emit) {
    emit(RoadRunnerIdle());
  }
}
