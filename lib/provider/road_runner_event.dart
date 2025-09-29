part of 'road_runner_bloc.dart';

@immutable
sealed class RoadRunnerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class RoadRunnerTap extends RoadRunnerEvent {}
final class RoadRunnerGoBackToIdle extends RoadRunnerEvent {}