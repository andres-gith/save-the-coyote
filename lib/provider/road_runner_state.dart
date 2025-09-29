part of 'road_runner_bloc.dart';

@immutable
sealed class RoadRunnerState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class RoadRunnerIdle extends RoadRunnerState {}

final class RoadRunnerBeep extends RoadRunnerState {}
