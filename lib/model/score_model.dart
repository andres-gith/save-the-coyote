import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class ScoreModel extends Equatable {
  final int score;
  final int counter;
  final String name;

  const ScoreModel({required this.score, required this.counter, required this.name});

  @override
  List<Object?> get props => [score, counter, name];
}
